import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/content.dart';

enum BiopsyRequestAnswer { requested, notRequested }

enum JourneyStepStatus {
  completed,
  current,
  next,
  later,
  mayBeNeeded,
  notNeeded,
  exploration,
}

class PlannedStep {
  final StepContent content;
  final JourneyStepStatus status;
  final String statusLabel;

  const PlannedStep(this.content, this.status, this.statusLabel);
}

class JourneyPlan {
  final String headline;
  final List<PlannedStep> steps;
  final bool canAdvance;
  final bool isExploration;

  const JourneyPlan({
    required this.headline,
    required this.steps,
    required this.canAdvance,
    this.isExploration = false,
  });
}

sealed class JourneyView {
  const JourneyView();
}

final class IntroductionView extends JourneyView {
  const IntroductionView();
}

final class OnboardingView extends JourneyView {
  final bool canCancel;

  const OnboardingView({required this.canCancel});
}

final class PostColposcopyDecisionView extends JourneyView {
  final bool canCancel;

  const PostColposcopyDecisionView({required this.canCancel});
}

final class ActiveJourneyView extends JourneyView {
  final JourneyPlan plan;

  const ActiveJourneyView(this.plan);
}

final class ExplorationView extends JourneyView {
  final JourneyPlan plan;
  final bool hasPreservedProgress;

  const ExplorationView({
    required this.plan,
    required this.hasPreservedProgress,
  });
}

sealed class JourneyActionResult {
  const JourneyActionResult();
}

final class JourneyActionSucceeded extends JourneyActionResult {
  const JourneyActionSucceeded();
}

final class JourneyActionFailed extends JourneyActionResult {
  final String message;
  final bool canRetry;

  const JourneyActionFailed(this.message, {this.canRetry = true});
}

final class JourneyLoadFailure implements Exception {
  final Object cause;

  const JourneyLoadFailure(this.cause);
}

enum _CurrentJourneyStep {
  preventiveCollection('coleta-do-preventivo', 0),
  result('resultado', 1),
  referral('encaminhamento', 2),
  colposcopy('colposcopia', 3),
  biopsy('biopsia', 4),
  followUpAfterBiopsy('acompanhamento-apos-biopsia', 5),
  followUpWithoutBiopsy('acompanhamento-sem-biopsia', 5);

  const _CurrentJourneyStep(this.persistedId, this.planIndex);

  final String persistedId;
  final int planIndex;

  static _CurrentJourneyStep? fromPersistedId(String value) {
    for (final step in values) {
      if (step.persistedId == value) return step;
    }
    return null;
  }
}

/// Owns the current care-journey state and publishes views ready to render.
///
/// Callers express user intent. Mapping, migration, transition ordering,
/// persistence and [JourneyPlan] derivation remain inside the implementation.
final class JourneySession extends ChangeNotifier {
  JourneySession._({
    required _JourneyPreferences preferences,
    required JourneyView initialView,
    _CurrentJourneyStep? currentStep,
  })  : _preferences = preferences,
        _view = initialView,
        _currentStep = currentStep;

  static const _currentStepIdKey = 'journey_current_step_id';
  static const _legacyCurrentStepIndexKey = 'journey_current_step_index';
  static const _legacySituationIndexKey = 'journey_situation_index';
  static const _introductionCompletedKey = 'introduction_completed';

  static const _journeyStepIds = [
    'primeiros-cuidados',
    'resultado',
    'encaminhamento',
    'colposcopia',
    'biopsia',
    'acompanhamento',
  ];

  final _JourneyPreferences _preferences;
  _CurrentJourneyStep? _currentStep;
  JourneyView _view;
  JourneyView? _cancelView;
  bool _isSaving = false;

  JourneyView get view => _view;
  bool get isSaving => _isSaving;

  static Future<JourneySession> restore() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      return _restoreFrom(_SharedPreferencesJourneyPreferences(preferences));
    } catch (error) {
      throw JourneyLoadFailure(error);
    }
  }

  @visibleForTesting
  static Future<JourneySession> restoreForTesting({
    Map<String, Object> initialValues = const {},
    Set<String> failingWrites = const {},
  }) {
    return _restoreFrom(
      _MemoryJourneyPreferences(
        initialValues: initialValues,
        failingWrites: failingWrites,
      ),
    );
  }

  static Future<JourneySession> _restoreFrom(
    _JourneyPreferences preferences,
  ) async {
    try {
      final hasStoredProgress = preferences.read(_currentStepIdKey) != null ||
          preferences.read(_legacyCurrentStepIndexKey) != null ||
          preferences.read(_legacySituationIndexKey) != null;
      var introductionCompleted =
          preferences.read(_introductionCompletedKey) == true;

      // Existing installations predate the introduction preference. A stored
      // journey proves the person already entered the app.
      if (!introductionCompleted && hasStoredProgress) {
        introductionCompleted = await preferences.writeBool(
          _introductionCompletedKey,
          true,
        );
        if (!introductionCompleted) {
          throw StateError('Could not migrate introduction preference.');
        }
      }

      if (!introductionCompleted) {
        return JourneySession._(
          preferences: preferences,
          initialView: const IntroductionView(),
        );
      }

      final currentStep = await _restoreCurrentStep(preferences);
      return JourneySession._(
        preferences: preferences,
        currentStep: currentStep,
        initialView: currentStep == null
            ? const OnboardingView(canCancel: false)
            : ActiveJourneyView(_buildActivePlan(currentStep)),
      );
    } catch (error) {
      throw JourneyLoadFailure(error);
    }
  }

  static Future<_CurrentJourneyStep?> _restoreCurrentStep(
    _JourneyPreferences preferences,
  ) async {
    final storedId = preferences.read(_currentStepIdKey);
    if (storedId is String) {
      final currentStep = _CurrentJourneyStep.fromPersistedId(storedId);
      if (currentStep != null) return currentStep;

      await preferences.remove(_currentStepIdKey);
      await preferences.remove(_legacyCurrentStepIndexKey);
      await preferences.remove(_legacySituationIndexKey);
      return null;
    }

    _CurrentJourneyStep? migratedStep;
    final legacyCurrentStep = preferences.read(_legacyCurrentStepIndexKey);
    if (legacyCurrentStep is int) {
      migratedStep = _stepForLegacyCurrentIndex(legacyCurrentStep);
    } else {
      final legacySituation = preferences.read(_legacySituationIndexKey);
      if (legacySituation is int) {
        migratedStep = _stepForLegacySituation(legacySituation);
      }
    }

    if (migratedStep == null) {
      await preferences.remove(_legacyCurrentStepIndexKey);
      await preferences.remove(_legacySituationIndexKey);
      return null;
    }

    final migrated = await preferences.writeString(
      _currentStepIdKey,
      migratedStep.persistedId,
    );
    if (!migrated) {
      throw StateError('Could not migrate journey progress.');
    }

    await preferences.remove(_legacyCurrentStepIndexKey);
    await preferences.remove(_legacySituationIndexKey);
    return migratedStep;
  }

  static _CurrentJourneyStep? _stepForLegacyCurrentIndex(int index) {
    return switch (index) {
      // The previous app stored index 0 for “Não sei — quero ver tudo”. It
      // represented exploration, not a confirmed current stage.
      0 => null,
      1 => _CurrentJourneyStep.result,
      2 => _CurrentJourneyStep.referral,
      3 => _CurrentJourneyStep.colposcopy,
      4 => _CurrentJourneyStep.biopsy,
      5 => _CurrentJourneyStep.followUpAfterBiopsy,
      _ => null,
    };
  }

  static _CurrentJourneyStep? _stepForLegacySituation(int index) {
    return switch (index) {
      0 => _CurrentJourneyStep.result,
      1 || 2 => _CurrentJourneyStep.referral,
      3 => _CurrentJourneyStep.colposcopy,
      4 => _CurrentJourneyStep.biopsy,
      // “Não sei — quero ver tudo” was not a confirmed current step.
      _ => null,
    };
  }

  Future<JourneyActionResult> finishIntroduction() async {
    if (_isSaving) return _busyFailure;

    final previousView = _view;
    _setSaving(true);
    try {
      final saved = await _preferences.writeBool(
        _introductionCompletedKey,
        true,
      );
      if (!saved) {
        _view = previousView;
        return _persistenceFailure;
      }

      _view = const OnboardingView(canCancel: false);
      return const JourneyActionSucceeded();
    } catch (_) {
      _view = previousView;
      return _persistenceFailure;
    } finally {
      _setSaving(false);
    }
  }

  Future<JourneyActionResult> chooseSituation(OnboardingAnswer answer) async {
    if (_isSaving) return _busyFailure;

    if (answer == OnboardingAnswer.explore) {
      _cancelView = null;
      _view = ExplorationView(
        plan: _buildExplorationPlan(),
        hasPreservedProgress: _currentStep != null,
      );
      notifyListeners();
      return const JourneyActionSucceeded();
    }

    if (answer == OnboardingAnswer.postColposcopy) {
      _cancelView ??= _view;
      _view = const PostColposcopyDecisionView(canCancel: true);
      notifyListeners();
      return const JourneyActionSucceeded();
    }

    final nextStep = switch (answer) {
      OnboardingAnswer.preventiveCollected => _CurrentJourneyStep.result,
      OnboardingAnswer.alteredResult ||
      OnboardingAnswer.referred =>
        _CurrentJourneyStep.referral,
      OnboardingAnswer.awaitingColposcopy => _CurrentJourneyStep.colposcopy,
      OnboardingAnswer.postColposcopy ||
      OnboardingAnswer.explore =>
        throw StateError('Handled above.'),
    };
    return _commitCurrentStep(nextStep);
  }

  Future<JourneyActionResult> advance() async {
    if (_isSaving) return _busyFailure;

    final currentStep = _currentStep;
    if (currentStep == null) {
      return const JourneyActionFailed(
        'Defina onde você está antes de avançar.',
        canRetry: false,
      );
    }

    if (currentStep == _CurrentJourneyStep.colposcopy) {
      _cancelView = _view;
      _view = const PostColposcopyDecisionView(canCancel: true);
      notifyListeners();
      return const JourneyActionSucceeded();
    }

    final nextStep = switch (currentStep) {
      _CurrentJourneyStep.preventiveCollection => _CurrentJourneyStep.result,
      _CurrentJourneyStep.result => _CurrentJourneyStep.referral,
      _CurrentJourneyStep.referral => _CurrentJourneyStep.colposcopy,
      _CurrentJourneyStep.biopsy => _CurrentJourneyStep.followUpAfterBiopsy,
      _CurrentJourneyStep.followUpAfterBiopsy ||
      _CurrentJourneyStep.followUpWithoutBiopsy =>
        null,
      _CurrentJourneyStep.colposcopy => throw StateError('Handled above.'),
    };

    if (nextStep == null) {
      return const JourneyActionFailed(
        'Você já está na última etapa da jornada.',
        canRetry: false,
      );
    }
    return _commitCurrentStep(nextStep);
  }

  Future<JourneyActionResult> resolvePostColposcopy(
    BiopsyRequestAnswer answer,
  ) {
    if (_view is! PostColposcopyDecisionView) {
      return Future.value(
        const JourneyActionFailed(
          'Esta decisão não está disponível agora.',
          canRetry: false,
        ),
      );
    }

    return _commitCurrentStep(
      answer == BiopsyRequestAnswer.requested
          ? _CurrentJourneyStep.biopsy
          : _CurrentJourneyStep.followUpWithoutBiopsy,
    );
  }

  void beginCurrentStageSelection() {
    if (_isSaving) return;
    _cancelView = _view;
    _view = const OnboardingView(canCancel: true);
    notifyListeners();
  }

  void returnToActiveJourney() {
    if (_isSaving || _currentStep == null) return;
    _cancelView = null;
    _view = ActiveJourneyView(_buildActivePlan(_currentStep!));
    notifyListeners();
  }

  void cancelTransientView() {
    if (_isSaving) return;
    final fallback = _cancelView;
    if (fallback == null) return;

    _cancelView = null;
    _view = fallback;
    notifyListeners();
  }

  Future<JourneyActionResult> _commitCurrentStep(
    _CurrentJourneyStep nextStep,
  ) async {
    if (_isSaving) return _busyFailure;

    final previousView = _view;
    final previousStep = _currentStep;
    _setSaving(true);
    try {
      final saved = await _preferences.writeString(
        _currentStepIdKey,
        nextStep.persistedId,
      );
      if (!saved) {
        _view = previousView;
        _currentStep = previousStep;
        return _persistenceFailure;
      }

      _currentStep = nextStep;
      _cancelView = null;
      _view = ActiveJourneyView(_buildActivePlan(nextStep));
      return const JourneyActionSucceeded();
    } catch (_) {
      _view = previousView;
      _currentStep = previousStep;
      return _persistenceFailure;
    } finally {
      _setSaving(false);
    }
  }

  void _setSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }

  static const _busyFailure = JourneyActionFailed(
    'Aguarde a alteração atual terminar.',
    canRetry: false,
  );
  static const _persistenceFailure = JourneyActionFailed(
    'Não foi possível salvar. Tente novamente.',
  );

  static JourneyPlan _buildActivePlan(_CurrentJourneyStep currentStep) {
    final currentIndex = currentStep.planIndex;
    return JourneyPlan(
      headline: _headlineFor(currentStep),
      canAdvance: currentIndex < _journeyStepIds.length - 1,
      steps: List.generate(_journeyStepIds.length, (index) {
        final content = stepContents[_journeyStepIds[index]]!;
        final status = _activeStatusFor(index, currentStep);
        return PlannedStep(content, status, _labelFor(status, currentIndex));
      }),
    );
  }

  static JourneyPlan _buildExplorationPlan() {
    return JourneyPlan(
      headline: 'Explore todos os passos, sem marcar uma etapa atual.',
      canAdvance: false,
      isExploration: true,
      steps: List.generate(_journeyStepIds.length, (index) {
        final status = index == 4
            ? JourneyStepStatus.mayBeNeeded
            : JourneyStepStatus.exploration;
        return PlannedStep(
          stepContents[_journeyStepIds[index]]!,
          status,
          _labelFor(status, -1),
        );
      }),
    );
  }

  static JourneyStepStatus _activeStatusFor(
    int stepIndex,
    _CurrentJourneyStep currentStep,
  ) {
    final currentIndex = currentStep.planIndex;
    if (stepIndex == currentIndex) return JourneyStepStatus.current;

    if (stepIndex == 4) {
      if (currentStep == _CurrentJourneyStep.followUpWithoutBiopsy) {
        return JourneyStepStatus.notNeeded;
      }
      if (currentIndex < 4) return JourneyStepStatus.mayBeNeeded;
    }

    if (stepIndex < currentIndex) return JourneyStepStatus.completed;
    if (stepIndex == currentIndex + 1) return JourneyStepStatus.next;
    return JourneyStepStatus.later;
  }

  static String _labelFor(JourneyStepStatus status, int currentIndex) {
    return switch (status) {
      JourneyStepStatus.completed => 'Concluído',
      JourneyStepStatus.current =>
        currentIndex == 0 ? 'Comece por aqui' : 'Você está aqui',
      JourneyStepStatus.next => 'Próxima etapa',
      JourneyStepStatus.later => 'Depois',
      JourneyStepStatus.mayBeNeeded => 'Pode ser necessária',
      JourneyStepStatus.notNeeded => 'Biópsia não necessária',
      JourneyStepStatus.exploration => 'Conheça esta etapa',
    };
  }

  static String _headlineFor(_CurrentJourneyStep step) {
    return switch (step) {
      _CurrentJourneyStep.preventiveCollection =>
        'Veja o caminho completo, com calma.',
      _CurrentJourneyStep.result =>
        'Você fez o preventivo. Agora é aguardar o resultado.',
      _CurrentJourneyStep.referral =>
        'Seu exame teve uma alteração. Vamos juntas no próximo passo.',
      _CurrentJourneyStep.colposcopy =>
        'A colposcopia é o seu próximo passo. Saber o que esperar ajuda.',
      _CurrentJourneyStep.biopsy =>
        'A biópsia foi solicitada. Vamos entender esta etapa.',
      _CurrentJourneyStep.followUpAfterBiopsy ||
      _CurrentJourneyStep.followUpWithoutBiopsy =>
        'Você chegou ao acompanhamento. O cuidado continua.',
    };
  }
}

abstract interface class _JourneyPreferences {
  Object? read(String key);
  Future<bool> writeBool(String key, bool value);
  Future<bool> writeString(String key, String value);
  Future<bool> remove(String key);
}

final class _SharedPreferencesJourneyPreferences
    implements _JourneyPreferences {
  final SharedPreferences _preferences;

  const _SharedPreferencesJourneyPreferences(this._preferences);

  @override
  Object? read(String key) => _preferences.get(key);

  @override
  Future<bool> writeBool(String key, bool value) {
    return _preferences.setBool(key, value);
  }

  @override
  Future<bool> writeString(String key, String value) {
    return _preferences.setString(key, value);
  }

  @override
  Future<bool> remove(String key) => _preferences.remove(key);
}

final class _MemoryJourneyPreferences implements _JourneyPreferences {
  _MemoryJourneyPreferences({
    required Map<String, Object> initialValues,
    required Set<String> failingWrites,
  })  : _values = Map.of(initialValues),
        _failingWrites = Set.of(failingWrites);

  final Map<String, Object> _values;
  final Set<String> _failingWrites;

  @override
  Object? read(String key) => _values[key];

  @override
  Future<bool> writeBool(String key, bool value) async {
    if (_failingWrites.contains(key)) return false;
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> writeString(String key, String value) async {
    if (_failingWrites.contains(key)) return false;
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    if (_failingWrites.contains(key)) return false;
    _values.remove(key);
    return true;
  }
}
