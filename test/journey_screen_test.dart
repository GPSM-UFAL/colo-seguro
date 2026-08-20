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
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.3)),
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
      find.text('Definir onde estou'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Definir onde estou'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Definir onde estou')).dy,
      greaterThan(
          tester.getBottomLeft(find.text(plan.steps.last.content.title)).dy),
    );
    expect(find.text(plan.steps.last.content.title), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('detalhe exploratório permite avançar e voltar entre etapas', (
    tester,
  ) async {
    final journey = await JourneySession.restoreForTesting(
      initialValues: const {'introduction_completed': true},
    );
    addTearDown(journey.dispose);
    await journey.chooseSituation(JourneySituation.explore);
    final plan = (journey.view as ExplorationView).plan;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: JourneyScreen(plan: plan)),
      ),
    );

    await tester.tap(find.text(plan.steps.first.content.title));
    await tester.pumpAndSettle();
    expect(find.text('Voltar para todas as etapas'), findsOneWidget);
    expect(find.text('Etapa 1 de ${plan.steps.length}'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Próxima etapa'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Próxima etapa'));
    await tester.pumpAndSettle();
    expect(find.text(plan.steps[1].content.title), findsOneWidget);
    expect(find.text('Etapa 2 de ${plan.steps.length}'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Etapa anterior'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Etapa anterior'));
    await tester.pumpAndSettle();
    expect(find.text(plan.steps.first.content.title), findsOneWidget);
    expect(find.text('Etapa 1 de ${plan.steps.length}'), findsOneWidget);
    expect(find.text('Voltar para todas as etapas'), findsOneWidget);
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
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.3)),
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
