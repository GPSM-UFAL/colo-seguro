import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:acolher_app/domain/journey_definition.dart';
import 'package:acolher_app/screens/journey_screen.dart';
import 'package:acolher_app/services/journey_session.dart';

void main() {
  testWidgets('modo de exploração lista etapas sem linha do tempo', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final journey = await JourneySession.restoreForTesting(
      initialValues: const {'introduction_completed': true},
    );
    addTearDown(journey.dispose);
    await journey.chooseSituation(JourneySituation.explore);
    final plan = (journey.view as ExplorationView).plan;

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.3),
          ),
          child: child!,
        ),
        home: Scaffold(
          body: JourneyScreen(
            plan: plan,
            onDefineCurrentStage: () {},
            onReturnToJourney: () {},
          ),
        ),
      ),
    );

    expect(find.text('Todas as etapas'), findsOneWidget);
    expect(find.text('Meu caminho'), findsNothing);
    expect(find.text('Voltar ao meu caminho'), findsOneWidget);
    expect(find.text('Definir onde estou'), findsOneWidget);
    final actionsBottom = <double>[
      tester.getBottomLeft(find.text('Voltar ao meu caminho')).dy,
      tester.getBottomLeft(find.text('Definir onde estou')).dy,
    ].reduce((first, second) => first > second ? first : second);
    expect(
      tester.getTopLeft(find.text('Todas as etapas')).dy,
      greaterThan(actionsBottom),
    );
    expect(find.byType(ListTile), findsWidgets);
    expect(find.text('Conheça esta etapa'), findsNothing);
    expect(find.text('Pode ser necessária'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_TimelineDot',
      ),
      findsNothing,
    );
    await tester.scrollUntilVisible(
      find.text(plan.steps.last.content.title),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(plan.steps.last.content.title), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Resultado dos Exames não transborda em uma tela Android estreita',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final journey = await JourneySession.restoreForTesting(
        initialValues: const {
          'introduction_completed': true,
          'journey_current_step_id': 'resultado',
        },
      );
      addTearDown(journey.dispose);
      final plan = (journey.view as ActiveJourneyView).plan;

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.3),
            ),
            child: child!,
          ),
          home: Scaffold(
            body: JourneyScreen(plan: plan, onAdvanceStep: () {}),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Passei para a próxima etapa'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
