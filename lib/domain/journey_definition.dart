/// The structural definition of the care journey.
///
/// This module is deliberately free of Flutter and persistence. It owns the
/// stable identities, ordering, legal transitions and the validated
/// association between visible stages and editorial content.
enum JourneySituation {
  preventiveCollected,
  alteredResult,
  referred,
  awaitingColposcopy,
  postColposcopy,
  explore,
}

enum BiopsyRequestAnswer { requested, notRequested }

enum JourneyStageId {
  preventiveCollection,
  result,
  referral,
  colposcopy,
  biopsy,
  followUp,
}

enum JourneyStageStatus {
  completed,
  current,
  next,
  later,
  mayBeNeeded,
  notNeeded,
  exploration,
}

final class EditorialEntry<T> {
  const EditorialEntry(this.id, this.content);

  final String id;
  final T content;
}

final class StoredJourneyState {
  const StoredJourneyState({
    this.currentIdentity,
    this.legacyCurrentIndex,
    this.legacySituationIndex,
  });

  final String? currentIdentity;
  final int? legacyCurrentIndex;
  final int? legacySituationIndex;
}

sealed class RestoredJourney {
  const RestoredJourney();
}

final class NoJourneyProgress extends RestoredJourney {
  const NoJourneyProgress({required this.shouldDiscardStoredValues});

  final bool shouldDiscardStoredValues;
}

final class CurrentJourneyProgress extends RestoredJourney {
  const CurrentJourneyProgress({
    required this.position,
    required this.needsCanonicalWrite,
  });

  final JourneyPosition position;
  final bool needsCanonicalWrite;
}

sealed class JourneyOutcome {
  const JourneyOutcome();
}

final class MoveToJourneyPosition extends JourneyOutcome {
  const MoveToJourneyPosition(this.position);

  final JourneyPosition position;
}

final class ShowJourneyExploration extends JourneyOutcome {
  const ShowJourneyExploration();
}

final class RequestPostColposcopyDecision extends JourneyOutcome {
  const RequestPostColposcopyDecision();
}

final class JourneyAlreadyComplete extends JourneyOutcome {
  const JourneyAlreadyComplete();
}

final class JourneyPosition {
  const JourneyPosition._(this._kind);

  final _JourneyPositionKind _kind;

  String get persistedIdentity => _kind.persistedIdentity;
  JourneyStageId get visibleStage => _kind.visibleStage;

  @override
  bool operator ==(Object other) =>
      other is JourneyPosition && other._kind == _kind;

  @override
  int get hashCode => _kind.hashCode;

  @override
  String toString() => 'JourneyPosition($persistedIdentity)';
}

final class JourneyStage<T> {
  const JourneyStage({
    required this.id,
    required this.content,
    required this.status,
  });

  final JourneyStageId id;
  final T content;
  final JourneyStageStatus status;
}

final class JourneyStructure<T> {
  JourneyStructure({
    required Iterable<JourneyStage<T>> stages,
    required this.canAdvance,
    required this.isExploration,
    this.currentPosition,
  }) : stages = List.unmodifiable(stages);

  final List<JourneyStage<T>> stages;
  final bool canAdvance;
  final bool isExploration;
  final JourneyPosition? currentPosition;
}

final class JourneyDefinitionError implements Exception {
  JourneyDefinitionError(Iterable<String> violations)
      : violations = List.unmodifiable(violations);

  final List<String> violations;

  @override
  String toString() => 'Invalid JourneyDefinition: ${violations.join('; ')}';
}

final class JourneyDefinition<T> {
  JourneyDefinition._(this._contentById);

  factory JourneyDefinition.validated(Iterable<EditorialEntry<T>> editorial) {
    final contentById = <String, T>{};
    final violations = <String>[];

    for (final entry in editorial) {
      if (contentById.containsKey(entry.id)) {
        violations.add('Duplicate editorial content id "${entry.id}".');
      } else {
        contentById[entry.id] = entry.content;
      }
    }

    final requiredIds = _stageOrder.map(_contentIdFor).toSet();
    final suppliedIds = contentById.keys.toSet();
    for (final missing in requiredIds.difference(suppliedIds)) {
      violations.add('Missing editorial content id "$missing".');
    }
    for (final extra in suppliedIds.difference(requiredIds)) {
      violations.add('Unknown editorial content id "$extra".');
    }

    _validateDefinition(violations);
    if (violations.isNotEmpty) throw JourneyDefinitionError(violations);

    return JourneyDefinition._(Map.unmodifiable(contentById));
  }

  final Map<String, T> _contentById;

  RestoredJourney restore(StoredJourneyState stored) {
    final currentIdentity = stored.currentIdentity;
    if (currentIdentity != null) {
      final kind = _currentPositionByIdentity[currentIdentity];
      return kind == null
          ? const NoJourneyProgress(shouldDiscardStoredValues: true)
          : CurrentJourneyProgress(
              position: _position(kind),
              needsCanonicalWrite: false,
            );
    }

    final legacyCurrentIndex = stored.legacyCurrentIndex;
    if (legacyCurrentIndex != null) {
      final kind = _positionForLegacyCurrentIndex(legacyCurrentIndex);
      return kind == null
          ? const NoJourneyProgress(shouldDiscardStoredValues: true)
          : CurrentJourneyProgress(
              position: _position(kind),
              needsCanonicalWrite: true,
            );
    }

    final legacySituationIndex = stored.legacySituationIndex;
    if (legacySituationIndex != null) {
      final kind = _positionForLegacySituation(legacySituationIndex);
      return kind == null
          ? const NoJourneyProgress(shouldDiscardStoredValues: true)
          : CurrentJourneyProgress(
              position: _position(kind),
              needsCanonicalWrite: true,
            );
    }

    return const NoJourneyProgress(shouldDiscardStoredValues: false);
  }

  JourneyOutcome choose(JourneySituation situation) {
    return switch (situation) {
      JourneySituation.preventiveCollected =>
        MoveToJourneyPosition(_position(_JourneyPositionKind.result)),
      JourneySituation.alteredResult ||
      JourneySituation.referred =>
        MoveToJourneyPosition(_position(_JourneyPositionKind.referral)),
      JourneySituation.awaitingColposcopy =>
        MoveToJourneyPosition(_position(_JourneyPositionKind.colposcopy)),
      JourneySituation.postColposcopy => const RequestPostColposcopyDecision(),
      JourneySituation.explore => const ShowJourneyExploration(),
    };
  }

  JourneyOutcome advance(JourneyPosition from) {
    return switch (from._kind) {
      _JourneyPositionKind.preventiveCollection =>
        MoveToJourneyPosition(_position(_JourneyPositionKind.result)),
      _JourneyPositionKind.result =>
        MoveToJourneyPosition(_position(_JourneyPositionKind.referral)),
      _JourneyPositionKind.referral =>
        MoveToJourneyPosition(_position(_JourneyPositionKind.colposcopy)),
      _JourneyPositionKind.colposcopy => const RequestPostColposcopyDecision(),
      _JourneyPositionKind.biopsy => MoveToJourneyPosition(
          _position(_JourneyPositionKind.followUpAfterBiopsy),
        ),
      _JourneyPositionKind.followUpAfterBiopsy ||
      _JourneyPositionKind.followUpWithoutBiopsy =>
        const JourneyAlreadyComplete(),
    };
  }

  JourneyOutcome resolvePostColposcopy(BiopsyRequestAnswer answer) {
    return MoveToJourneyPosition(
      _position(
        answer == BiopsyRequestAnswer.requested
            ? _JourneyPositionKind.biopsy
            : _JourneyPositionKind.followUpWithoutBiopsy,
      ),
    );
  }

  JourneyStructure<T> activeStructure(JourneyPosition current) {
    return JourneyStructure(
      currentPosition: current,
      canAdvance: advance(current) is! JourneyAlreadyComplete,
      isExploration: false,
      stages: List.generate(_stageOrder.length, (index) {
        final stage = _stageOrder[index];
        return JourneyStage(
          id: stage,
          content: _contentById[_contentIdFor(stage)] as T,
          status: _activeStatusFor(index, current),
        );
      }),
    );
  }

  JourneyStructure<T> explorationStructure() {
    return JourneyStructure(
      canAdvance: false,
      isExploration: true,
      stages: List.generate(_stageOrder.length, (index) {
        final stage = _stageOrder[index];
        return JourneyStage(
          id: stage,
          content: _contentById[_contentIdFor(stage)] as T,
          status: stage == JourneyStageId.biopsy
              ? JourneyStageStatus.mayBeNeeded
              : JourneyStageStatus.exploration,
        );
      }),
    );
  }

  JourneyStageStatus _activeStatusFor(
    int stageIndex,
    JourneyPosition current,
  ) {
    final currentIndex = current._kind.planIndex;
    if (stageIndex == currentIndex) return JourneyStageStatus.current;

    if (_stageOrder[stageIndex] == JourneyStageId.biopsy) {
      if (current._kind == _JourneyPositionKind.followUpWithoutBiopsy) {
        return JourneyStageStatus.notNeeded;
      }
      if (currentIndex < _stageOrder.indexOf(JourneyStageId.biopsy)) {
        return JourneyStageStatus.mayBeNeeded;
      }
    }

    if (stageIndex < currentIndex) return JourneyStageStatus.completed;
    if (stageIndex == currentIndex + 1) return JourneyStageStatus.next;
    return JourneyStageStatus.later;
  }
}

enum _JourneyPositionKind {
  preventiveCollection(
    persistedIdentity: 'coleta-do-preventivo',
    visibleStage: JourneyStageId.preventiveCollection,
    planIndex: 0,
  ),
  result(
    persistedIdentity: 'resultado',
    visibleStage: JourneyStageId.result,
    planIndex: 1,
  ),
  referral(
    persistedIdentity: 'encaminhamento',
    visibleStage: JourneyStageId.referral,
    planIndex: 2,
  ),
  colposcopy(
    persistedIdentity: 'colposcopia',
    visibleStage: JourneyStageId.colposcopy,
    planIndex: 3,
  ),
  biopsy(
    persistedIdentity: 'biopsia',
    visibleStage: JourneyStageId.biopsy,
    planIndex: 4,
  ),
  followUpAfterBiopsy(
    persistedIdentity: 'acompanhamento-apos-biopsia',
    visibleStage: JourneyStageId.followUp,
    planIndex: 5,
  ),
  followUpWithoutBiopsy(
    persistedIdentity: 'acompanhamento-sem-biopsia',
    visibleStage: JourneyStageId.followUp,
    planIndex: 5,
  );

  const _JourneyPositionKind({
    required this.persistedIdentity,
    required this.visibleStage,
    required this.planIndex,
  });

  final String persistedIdentity;
  final JourneyStageId visibleStage;
  final int planIndex;
}

const _stageOrder = [
  JourneyStageId.preventiveCollection,
  JourneyStageId.result,
  JourneyStageId.referral,
  JourneyStageId.colposcopy,
  JourneyStageId.biopsy,
  JourneyStageId.followUp,
];

final _currentPositionByIdentity = {
  for (final kind in _JourneyPositionKind.values) kind.persistedIdentity: kind,
};

JourneyPosition _position(_JourneyPositionKind kind) => JourneyPosition._(kind);

String _contentIdFor(JourneyStageId stage) => switch (stage) {
      JourneyStageId.preventiveCollection => 'primeiros-cuidados',
      JourneyStageId.result => 'resultado',
      JourneyStageId.referral => 'encaminhamento',
      JourneyStageId.colposcopy => 'colposcopia',
      JourneyStageId.biopsy => 'biopsia',
      JourneyStageId.followUp => 'acompanhamento',
    };

_JourneyPositionKind? _positionForLegacyCurrentIndex(int index) {
  return switch (index) {
    0 => null,
    1 => _JourneyPositionKind.result,
    2 => _JourneyPositionKind.referral,
    3 => _JourneyPositionKind.colposcopy,
    4 => _JourneyPositionKind.biopsy,
    5 => _JourneyPositionKind.followUpAfterBiopsy,
    _ => null,
  };
}

_JourneyPositionKind? _positionForLegacySituation(int index) {
  return switch (index) {
    0 => _JourneyPositionKind.result,
    1 || 2 => _JourneyPositionKind.referral,
    3 => _JourneyPositionKind.colposcopy,
    4 => _JourneyPositionKind.biopsy,
    _ => null,
  };
}

void _validateDefinition(List<String> violations) {
  final identities = <String>{};
  for (final kind in _JourneyPositionKind.values) {
    if (!identities.add(kind.persistedIdentity)) {
      violations.add(
        'Duplicate persisted identity "${kind.persistedIdentity}".',
      );
    }
    if (!_stageOrder.contains(kind.visibleStage)) {
      violations.add(
        'Position "${kind.persistedIdentity}" has no visible stage.',
      );
    }
    if (_stageOrder[kind.planIndex] != kind.visibleStage) {
      violations.add(
        'Position "${kind.persistedIdentity}" has an invalid plan index.',
      );
    }
  }

  if (_JourneyPositionKind.followUpAfterBiopsy.visibleStage !=
          JourneyStageId.followUp ||
      _JourneyPositionKind.followUpWithoutBiopsy.visibleStage !=
          JourneyStageId.followUp) {
    violations.add('Both follow-up positions must share one visible stage.');
  }
}
