import 'package:flutter_test/flutter_test.dart';

import 'package:acolher_app/domain/journey_definition.dart';

void main() {
  group('Definição da Jornada', () {
    test('valida a associação editorial inteira ao inicializar', () {
      expect(
        () => JourneyDefinition.validated(const [
          EditorialEntry('primeiros-cuidados', 'coleta'),
          EditorialEntry('resultado', 'resultado'),
          EditorialEntry('encaminhamento', 'encaminhamento'),
          EditorialEntry('colposcopia', 'colposcopia'),
          EditorialEntry('biopsia', 'biopsia'),
          EditorialEntry('biopsia', 'duplicada'),
          EditorialEntry('fora-da-jornada', 'extra'),
        ]),
        throwsA(
          isA<JourneyDefinitionError>().having(
            (error) => error.violations,
            'violations',
            containsAll([
              'Duplicate editorial content id "biopsia".',
              'Missing editorial content id "acompanhamento".',
              'Unknown editorial content id "fora-da-jornada".',
            ]),
          ),
        ),
      );
    });

    test('restaura todas as identidades atuais sem migração', () {
      final definition = _definition();
      const expectedStages = {
        'coleta-do-preventivo': JourneyStageId.preventiveCollection,
        'resultado': JourneyStageId.result,
        'encaminhamento': JourneyStageId.referral,
        'colposcopia': JourneyStageId.colposcopy,
        'biopsia': JourneyStageId.biopsy,
        'acompanhamento-apos-biopsia': JourneyStageId.followUp,
        'acompanhamento-sem-biopsia': JourneyStageId.followUp,
      };

      for (final entry in expectedStages.entries) {
        final restored = definition.restore(
          StoredJourneyState(currentIdentity: entry.key),
        ) as CurrentJourneyProgress;

        expect(restored.position.persistedIdentity, entry.key);
        expect(restored.position.visibleStage, entry.value);
        expect(restored.needsCanonicalWrite, isFalse);
      }
    });

    test('interpreta identidades legadas e rejeita valores desconhecidos', () {
      final definition = _definition();
      const legacyCurrent = {
        1: 'resultado',
        2: 'encaminhamento',
        3: 'colposcopia',
        4: 'biopsia',
        5: 'acompanhamento-apos-biopsia',
      };
      const legacySituations = {
        0: 'resultado',
        1: 'encaminhamento',
        2: 'encaminhamento',
        3: 'colposcopia',
        4: 'biopsia',
      };

      for (final entry in legacyCurrent.entries) {
        final restored = definition.restore(
          StoredJourneyState(legacyCurrentIndex: entry.key),
        ) as CurrentJourneyProgress;
        expect(restored.position.persistedIdentity, entry.value);
        expect(restored.needsCanonicalWrite, isTrue);
      }
      for (final entry in legacySituations.entries) {
        final restored = definition.restore(
          StoredJourneyState(legacySituationIndex: entry.key),
        ) as CurrentJourneyProgress;
        expect(restored.position.persistedIdentity, entry.value);
        expect(restored.needsCanonicalWrite, isTrue);
      }

      expect(
        definition.restore(const StoredJourneyState(legacyCurrentIndex: 0)),
        isA<NoJourneyProgress>().having(
          (result) => result.shouldDiscardStoredValues,
          'shouldDiscardStoredValues',
          isTrue,
        ),
      );
      expect(
        definition.restore(
          const StoredJourneyState(currentIdentity: 'desconhecida'),
        ),
        isA<NoJourneyProgress>().having(
          (result) => result.shouldDiscardStoredValues,
          'shouldDiscardStoredValues',
          isTrue,
        ),
      );
    });

    test('mapeia todas as situações sem persistir a escolha', () {
      final definition = _definition();

      expect(
        _movedIdentity(
          definition.choose(JourneySituation.preventiveCollected),
        ),
        'resultado',
      );
      expect(
        _movedIdentity(definition.choose(JourneySituation.alteredResult)),
        'encaminhamento',
      );
      expect(
        _movedIdentity(definition.choose(JourneySituation.referred)),
        'encaminhamento',
      );
      expect(
        _movedIdentity(
          definition.choose(JourneySituation.awaitingColposcopy),
        ),
        'colposcopia',
      );
      expect(
        definition.choose(JourneySituation.postColposcopy),
        isA<RequestPostColposcopyDecision>(),
      );
      expect(
        definition.choose(JourneySituation.explore),
        isA<ShowJourneyExploration>(),
      );
    });

    test('expõe todo o grafo legal por resultados estruturais', () {
      final definition = _definition();

      expect(
        _movedIdentity(definition.advance(_position(definition, 'resultado'))),
        'encaminhamento',
      );
      expect(
        _movedIdentity(
          definition.advance(_position(definition, 'encaminhamento')),
        ),
        'colposcopia',
      );
      expect(
        definition.advance(_position(definition, 'colposcopia')),
        isA<RequestPostColposcopyDecision>(),
      );
      expect(
        _movedIdentity(
          definition.resolvePostColposcopy(BiopsyRequestAnswer.requested),
        ),
        'biopsia',
      );
      expect(
        _movedIdentity(
          definition.resolvePostColposcopy(BiopsyRequestAnswer.notRequested),
        ),
        'acompanhamento-sem-biopsia',
      );
      expect(
        _movedIdentity(definition.advance(_position(definition, 'biopsia'))),
        'acompanhamento-apos-biopsia',
      );
      expect(
        definition.advance(
          _position(definition, 'acompanhamento-apos-biopsia'),
        ),
        isA<JourneyAlreadyComplete>(),
      );
      expect(
        definition.advance(
          _position(definition, 'acompanhamento-sem-biopsia'),
        ),
        isA<JourneyAlreadyComplete>(),
      );
    });

    test('projeta toda posição com uma única etapa atual', () {
      final definition = _definition();
      const identities = [
        'coleta-do-preventivo',
        'resultado',
        'encaminhamento',
        'colposcopia',
        'biopsia',
        'acompanhamento-apos-biopsia',
        'acompanhamento-sem-biopsia',
      ];

      for (final identity in identities) {
        final structure = definition.activeStructure(
          _position(definition, identity),
        );
        expect(structure.stages, hasLength(6));
        expect(
          structure.stages
              .where((stage) => stage.status == JourneyStageStatus.current),
          hasLength(1),
        );
        expect(
          structure.stages.map((stage) => stage.content),
          [
            'coleta',
            'resultado',
            'encaminhamento',
            'colposcopia',
            'biopsia',
            'acompanhamento'
          ],
        );
      }
    });

    test('preserva os dois caminhos internos de Acompanhamento', () {
      final definition = _definition();
      final afterBiopsy = definition.activeStructure(
        _position(definition, 'acompanhamento-apos-biopsia'),
      );
      final withoutBiopsy = definition.activeStructure(
        _position(definition, 'acompanhamento-sem-biopsia'),
      );

      expect(
        afterBiopsy.currentPosition!.visibleStage,
        JourneyStageId.followUp,
      );
      expect(
        withoutBiopsy.currentPosition!.visibleStage,
        JourneyStageId.followUp,
      );
      expect(
        _stage(afterBiopsy, JourneyStageId.biopsy).status,
        JourneyStageStatus.completed,
      );
      expect(
        _stage(withoutBiopsy, JourneyStageId.biopsy).status,
        JourneyStageStatus.notNeeded,
      );
    });

    test('Modo de exploração não inventa Etapa atual', () {
      final structure = _definition().explorationStructure();

      expect(structure.isExploration, isTrue);
      expect(structure.canAdvance, isFalse);
      expect(structure.currentPosition, isNull);
      expect(
        structure.stages
            .where((stage) => stage.status == JourneyStageStatus.current),
        isEmpty,
      );
      expect(
        _stage(structure, JourneyStageId.biopsy).status,
        JourneyStageStatus.mayBeNeeded,
      );
    });
  });
}

JourneyDefinition<String> _definition() {
  return JourneyDefinition.validated(const [
    EditorialEntry('primeiros-cuidados', 'coleta'),
    EditorialEntry('resultado', 'resultado'),
    EditorialEntry('encaminhamento', 'encaminhamento'),
    EditorialEntry('colposcopia', 'colposcopia'),
    EditorialEntry('biopsia', 'biopsia'),
    EditorialEntry('acompanhamento', 'acompanhamento'),
  ]);
}

JourneyPosition _position(
  JourneyDefinition<String> definition,
  String identity,
) {
  return (definition.restore(
    StoredJourneyState(currentIdentity: identity),
  ) as CurrentJourneyProgress)
      .position;
}

String _movedIdentity(JourneyOutcome outcome) {
  return (outcome as MoveToJourneyPosition).position.persistedIdentity;
}

JourneyStage<String> _stage(
  JourneyStructure<String> structure,
  JourneyStageId id,
) {
  return structure.stages.singleWhere((stage) => stage.id == id);
}
