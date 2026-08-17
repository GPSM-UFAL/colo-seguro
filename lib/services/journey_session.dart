import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/content.dart';
import '../domain/journey_definition.dart';

class PlannedStep {
  final StepContent content;
  final JourneyStageStatus status;
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

/// Owns the persisted and transient session state for the care journey.
///
/// [JourneyDefinition] owns structural meaning. This module sequences storage,
/// publishes views only after successful writes and keeps transient navigation.
final class JourneySession extends ChangeNotifier {
  JourneySession._({
    required JourneyDefinition<StepContent> definition,
    required _JourneyPreferences preferences,
    required JourneyView initialView,
    JourneyPosition? currentPosition,
  })  : _definition = definition,
        _preferences = preferences,
        _view = initialView,
        _currentPosition = currentPosition;

  static const _currentStepIdKey = 'journey_current_step_id';
  static const _legacyCurrentStepIndexKey = 'journey_current_step_index';
  static const _legacySituationIndexKey = 'journey_situation_index';
  static const _introductionCompletedKey = 'introduction_completed';

  static final JourneyDefinition<StepContent> _appDefinition =
      JourneyDefinition.validated(
    stepContents.values.map(
      (content) => EditorialEntry(content.id, content),
    ),
  );

  final JourneyDefinition<StepContent> _definition;
  final _JourneyPreferences _preferences;
  JourneyPosition? _currentPosition;
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
      final definition = _appDefinition;
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
          definition: definition,
          preferences: preferences,
          initialView: const IntroductionView(),
        );
      }

      final currentPosition = await _restoreCurrentPosition(
        definition,
        preferences,
      );
      return JourneySession._(
        definition: definition,
        preferences: preferences,
        currentPosition: currentPosition,
        initialView: currentPosition == null
            ? const OnboardingView(canCancel: false)
            : ActiveJourneyView(
                _buildActivePlan(definition, currentPosition),
              ),
      );
    } catch (error) {
      throw JourneyLoadFailure(error);
    }
  }

  static Future<JourneyPosition?> _restoreCurrentPosition(
    JourneyDefinition<StepContent> definition,
    _JourneyPreferences preferences,
  ) async {
    final currentIdentity = preferences.read(_currentStepIdKey);
    final legacyCurrentIndex = preferences.read(_legacyCurrentStepIndexKey);
    final legacySituationIndex = preferences.read(_legacySituationIndexKey);
    final restored = definition.restore(
      StoredJourneyState(
        currentIdentity: currentIdentity is String ? currentIdentity : null,
        legacyCurrentIndex:
            legacyCurrentIndex is int ? legacyCurrentIndex : null,
        legacySituationIndex:
            legacySituationIndex is int ? legacySituationIndex : null,
      ),
    );

    switch (restored) {
      case NoJourneyProgress(:final shouldDiscardStoredValues):
        if (shouldDiscardStoredValues) {
          await _removeStoredProgress(preferences);
        }
        return null;
      case CurrentJourneyProgress(
          :final position,
          :final needsCanonicalWrite,
        ):
        if (!needsCanonicalWrite) return position;

        final migrated = await preferences.writeString(
          _currentStepIdKey,
          position.persistedIdentity,
        );
        if (!migrated) {
          throw StateError('Could not migrate journey progress.');
        }
        await preferences.remove(_legacyCurrentStepIndexKey);
        await preferences.remove(_legacySituationIndexKey);
        return position;
    }
  }

  static Future<void> _removeStoredProgress(
    _JourneyPreferences preferences,
  ) async {
    await preferences.remove(_currentStepIdKey);
    await preferences.remove(_legacyCurrentStepIndexKey);
    await preferences.remove(_legacySituationIndexKey);
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

  Future<JourneyActionResult> chooseSituation(
    JourneySituation situation,
  ) async {
    if (_isSaving) return _busyFailure;

    return switch (_definition.choose(situation)) {
      ShowJourneyExploration() => _showExploration(),
      RequestPostColposcopyDecision() => _showPostColposcopyDecision(),
      MoveToJourneyPosition(:final position) =>
        _commitCurrentPosition(position),
      JourneyAlreadyComplete() => throw StateError(
          'Choosing a situation cannot complete the journey.',
        ),
    };
  }

  Future<JourneyActionResult> advance() async {
    if (_isSaving) return _busyFailure;

    final currentPosition = _currentPosition;
    if (currentPosition == null) {
      return const JourneyActionFailed(
        'Defina onde você está antes de avançar.',
        canRetry: false,
      );
    }

    return switch (_definition.advance(currentPosition)) {
      MoveToJourneyPosition(:final position) =>
        _commitCurrentPosition(position),
      RequestPostColposcopyDecision() => _showPostColposcopyDecision(),
      JourneyAlreadyComplete() => Future.value(
          const JourneyActionFailed(
            'Você já está na última etapa da jornada.',
            canRetry: false,
          ),
        ),
      ShowJourneyExploration() => throw StateError(
          'Advancing cannot enter exploration.',
        ),
    };
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

    final outcome = _definition.resolvePostColposcopy(answer);
    if (outcome case MoveToJourneyPosition(:final position)) {
      return _commitCurrentPosition(position);
    }
    throw StateError('Resolving the post-colposcopy decision must move.');
  }

  void beginCurrentStageSelection() {
    if (_isSaving) return;
    _cancelView = _view;
    _view = const OnboardingView(canCancel: true);
    notifyListeners();
  }

  void returnToActiveJourney() {
    final currentPosition = _currentPosition;
    if (_isSaving || currentPosition == null) return;
    _cancelView = null;
    _view = ActiveJourneyView(
      _buildActivePlan(_definition, currentPosition),
    );
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

  Future<JourneyActionResult> _showExploration() {
    _cancelView = null;
    _view = ExplorationView(
      plan: _buildExplorationPlan(_definition),
      hasPreservedProgress: _currentPosition != null,
    );
    notifyListeners();
    return Future.value(const JourneyActionSucceeded());
  }

  Future<JourneyActionResult> _showPostColposcopyDecision() {
    _cancelView ??= _view;
    _view = const PostColposcopyDecisionView(canCancel: true);
    notifyListeners();
    return Future.value(const JourneyActionSucceeded());
  }

  Future<JourneyActionResult> _commitCurrentPosition(
    JourneyPosition nextPosition,
  ) async {
    if (_isSaving) return _busyFailure;

    final previousView = _view;
    final previousPosition = _currentPosition;
    _setSaving(true);
    try {
      final saved = await _preferences.writeString(
        _currentStepIdKey,
        nextPosition.persistedIdentity,
      );
      if (!saved) {
        _view = previousView;
        _currentPosition = previousPosition;
        return _persistenceFailure;
      }

      _currentPosition = nextPosition;
      _cancelView = null;
      _view = ActiveJourneyView(
        _buildActivePlan(_definition, nextPosition),
      );
      return const JourneyActionSucceeded();
    } catch (_) {
      _view = previousView;
      _currentPosition = previousPosition;
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

  static JourneyPlan _buildActivePlan(
    JourneyDefinition<StepContent> definition,
    JourneyPosition currentPosition,
  ) {
    final structure = definition.activeStructure(currentPosition);
    return JourneyPlan(
      headline: journeyHeadlineFor(currentPosition.visibleStage),
      canAdvance: structure.canAdvance,
      steps: [
        for (final stage in structure.stages)
          PlannedStep(
            stage.content,
            stage.status,
            journeyStatusLabelFor(
              stage.status,
              isFirstStage: stage.id == JourneyStageId.preventiveCollection,
            ),
          ),
      ],
    );
  }

  static JourneyPlan _buildExplorationPlan(
    JourneyDefinition<StepContent> definition,
  ) {
    final structure = definition.explorationStructure();
    return JourneyPlan(
      headline: journeyExplorationHeadline,
      canAdvance: structure.canAdvance,
      isExploration: true,
      steps: [
        for (final stage in structure.stages)
          PlannedStep(
            stage.content,
            stage.status,
            journeyStatusLabelFor(stage.status),
          ),
      ],
    );
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
