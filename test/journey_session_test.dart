import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:acolher_app/data/content.dart';
import 'package:acolher_app/services/journey_session.dart';

void main() {
  const introductionKey = 'introduction_completed';
  const currentStepIdKey = 'journey_current_step_id';
  const legacyCurrentStepKey = 'journey_current_step_index';
  const legacySituationKey = 'journey_situation_index';

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('primeiro acesso começa na introdução', () async {
    final journey = await JourneySession.restore();
    addTearDown(journey.dispose);

    expect(journey.view, isA<IntroductionView>());

    final result = await journey.finishIntroduction();

    expect(result, isA<JourneyActionSucceeded>());
    expect(journey.view, isA<OnboardingView>());
    expect(
      (journey.view as OnboardingView).canCancel,
      isFalse,
    );
    expect(
      (await SharedPreferences.getInstance()).getBool(introductionKey),
      isTrue,
    );
  });

  test('restaura identidade estável e deriva plano completo', () async {
    SharedPreferences.setMockInitialValues({
      introductionKey: true,
      currentStepIdKey: 'colposcopia',
    });

    final journey = await JourneySession.restore();
    addTearDown(journey.dispose);
    final view = journey.view as ActiveJourneyView;

    expect(_currentStep(view.plan).content.id, 'colposcopia');
    expect(view.plan.canAdvance, isTrue);
    final biopsy = _step(view.plan, 'biopsia');
    expect(biopsy.status, JourneyStepStatus.mayBeNeeded);
    expect(biopsy.statusLabel, 'Pode ser necessária');
  });

  test('migra índice antigo para identidade estável', () async {
    SharedPreferences.setMockInitialValues({legacyCurrentStepKey: 3});

    final journey = await JourneySession.restore();
    addTearDown(journey.dispose);
    final preferences = await SharedPreferences.getInstance();

    expect(journey.view, isA<ActiveJourneyView>());
    expect(
      _currentStep((journey.view as ActiveJourneyView).plan).content.id,
      'colposcopia',
    );
    expect(preferences.getString(currentStepIdKey), 'colposcopia');
    expect(preferences.containsKey(legacyCurrentStepKey), isFalse);
    expect(preferences.getBool(introductionKey), isTrue);
  });

  test('situação antiga de exploração não inventa etapa atual', () async {
    SharedPreferences.setMockInitialValues({legacySituationKey: 5});

    final journey = await JourneySession.restore();
    addTearDown(journey.dispose);
    final preferences = await SharedPreferences.getInstance();

    expect(journey.view, isA<OnboardingView>());
    expect(preferences.containsKey(currentStepIdKey), isFalse);
    expect(preferences.containsKey(legacySituationKey), isFalse);
    expect(preferences.getBool(introductionKey), isTrue);
  });

  test('índice atual legado de exploração não inventa etapa atual', () async {
    SharedPreferences.setMockInitialValues({legacyCurrentStepKey: 0});

    final journey = await JourneySession.restore();
    addTearDown(journey.dispose);
    final preferences = await SharedPreferences.getInstance();

    expect(journey.view, isA<OnboardingView>());
    expect(preferences.containsKey(currentStepIdKey), isFalse);
    expect(preferences.containsKey(legacyCurrentStepKey), isFalse);
    expect(preferences.getBool(introductionKey), isTrue);
  });

  test('identidade desconhecida retorna ao onboarding', () async {
    SharedPreferences.setMockInitialValues({
      introductionKey: true,
      currentStepIdKey: 'etapa-inexistente',
    });

    final journey = await JourneySession.restore();
    addTearDown(journey.dispose);

    expect(journey.view, isA<OnboardingView>());
    expect(
      (await SharedPreferences.getInstance()).containsKey(currentStepIdKey),
      isFalse,
    );
  });

  test('já fez colposcopia exige decisão antes de persistir', () async {
    SharedPreferences.setMockInitialValues({introductionKey: true});
    final journey = await JourneySession.restore();
    addTearDown(journey.dispose);

    final pending = await journey.chooseSituation(
      OnboardingAnswer.postColposcopy,
    );
    expect(pending, isA<JourneyActionSucceeded>());
    expect(journey.view, isA<PostColposcopyDecisionView>());
    expect(
      (await SharedPreferences.getInstance()).containsKey(currentStepIdKey),
      isFalse,
    );

    final resolved = await journey.resolvePostColposcopy(
      BiopsyRequestAnswer.notRequested,
    );
    expect(resolved, isA<JourneyActionSucceeded>());

    final plan = (journey.view as ActiveJourneyView).plan;
    expect(_currentStep(plan).content.id, 'acompanhamento');
    expect(_step(plan, 'biopsia').status, JourneyStepStatus.notNeeded);
    expect(
      _step(plan, 'biopsia').statusLabel,
      'Biópsia não necessária',
    );
    expect(
      (await SharedPreferences.getInstance()).getString(currentStepIdKey),
      'acompanhamento-sem-biopsia',
    );
  });

  test('avançar da colposcopia abre decisão sem escrita', () async {
    SharedPreferences.setMockInitialValues({
      introductionKey: true,
      currentStepIdKey: 'colposcopia',
    });
    final journey = await JourneySession.restore();
    addTearDown(journey.dispose);

    final result = await journey.advance();

    expect(result, isA<JourneyActionSucceeded>());
    expect(journey.view, isA<PostColposcopyDecisionView>());
    expect(
      (await SharedPreferences.getInstance()).getString(currentStepIdKey),
      'colposcopia',
    );
  });

  test('modo de exploração preserva progresso persistido', () async {
    SharedPreferences.setMockInitialValues({
      introductionKey: true,
      currentStepIdKey: 'resultado',
    });
    final journey = await JourneySession.restore();
    addTearDown(journey.dispose);

    journey.beginCurrentStageSelection();
    await journey.chooseSituation(OnboardingAnswer.explore);

    final exploration = journey.view as ExplorationView;
    expect(exploration.hasPreservedProgress, isTrue);
    expect(exploration.plan.isExploration, isTrue);
    expect(
      exploration.plan.steps.where(
        (step) => step.status == JourneyStepStatus.current,
      ),
      isEmpty,
    );

    journey.returnToActiveJourney();
    expect(
      _currentStep((journey.view as ActiveJourneyView).plan).content.id,
      'resultado',
    );

    final restored = await JourneySession.restore();
    addTearDown(restored.dispose);
    expect(
      _currentStep((restored.view as ActiveJourneyView).plan).content.id,
      'resultado',
    );
  });

  test('falha de escrita mantém etapa e plano anteriores', () async {
    final journey = await JourneySession.restoreForTesting(
      initialValues: const {
        introductionKey: true,
        currentStepIdKey: 'resultado',
      },
      failingWrites: const {currentStepIdKey},
    );
    addTearDown(journey.dispose);
    final previousView = journey.view;

    final result = await journey.advance();

    expect(result, isA<JourneyActionFailed>());
    expect(journey.view, same(previousView));
    expect(
      _currentStep((journey.view as ActiveJourneyView).plan).content.id,
      'resultado',
    );
    expect(journey.isSaving, isFalse);
  });

  test('segunda transição é rejeitada enquanto uma escrita está ativa',
      () async {
    final journey = await JourneySession.restoreForTesting(
      initialValues: const {
        introductionKey: true,
        currentStepIdKey: 'resultado',
      },
    );
    addTearDown(journey.dispose);

    final firstTransition = journey.advance();
    final secondResult = await journey.advance();
    final firstResult = await firstTransition;

    expect(firstResult, isA<JourneyActionSucceeded>());
    expect(secondResult, isA<JourneyActionFailed>());
    expect(
      _currentStep((journey.view as ActiveJourneyView).plan).content.id,
      'encaminhamento',
    );
  });

  test('falha ao concluir introdução mantém a introdução', () async {
    final journey = await JourneySession.restoreForTesting(
      failingWrites: const {introductionKey},
    );
    addTearDown(journey.dispose);

    final result = await journey.finishIntroduction();

    expect(result, isA<JourneyActionFailed>());
    expect(journey.view, isA<IntroductionView>());
  });
}

PlannedStep _currentStep(JourneyPlan plan) {
  return plan.steps.singleWhere(
    (step) => step.status == JourneyStepStatus.current,
  );
}

PlannedStep _step(JourneyPlan plan, String id) {
  return plan.steps.singleWhere((step) => step.content.id == id);
}
