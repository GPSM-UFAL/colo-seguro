import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';

import 'package:acolher_app/screens/post_colposcopy_decision_screen.dart';
import 'package:acolher_app/services/audio_service.dart';
import 'package:acolher_app/services/journey_session.dart';
import 'package:acolher_app/widgets/audio_button.dart';

class _FakeAudioController implements AudioController {
  final _states = StreamController<PlayerState>.broadcast();
  int stopCalls = 0;

  @override
  String? get currentFile => null;

  @override
  bool get isPlaying => false;

  @override
  Stream<PlayerState> get playerStateStream => _states.stream;

  @override
  Future<bool> toggle(String fileName) async => true;

  @override
  Future<void> stop() async {
    stopCalls++;
  }

  Future<void> dispose() => _states.close();
}

void main() {
  testWidgets('Depois da colposcopia oferece a explicação em áudio', (
    tester,
  ) async {
    final audio = _FakeAudioController();
    addTearDown(audio.dispose);
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final journey = await JourneySession.restoreForTesting(
      initialValues: const {
        'introduction_completed': true,
        'journey_current_step_id': 'colposcopia',
      },
    );
    addTearDown(journey.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: PostColposcopyDecisionScreen(
          journey: journey,
          canCancel: true,
          audioController: audio,
        ),
      ),
    );

    final audioButton = tester.widget<AudioButton>(find.byType(AudioButton));
    expect(audioButton.audioFile, 'depois_colposcopia.mp3');
    expect(audioButton.label, 'Ouvir explicação');
    expect(tester.takeException(), isNull);
  });

  testWidgets('interrompe o áudio ao responder', (tester) async {
    final audio = _FakeAudioController();
    final journey = await _postColposcopyJourney();
    addTearDown(audio.dispose);
    addTearDown(journey.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: PostColposcopyDecisionScreen(
          journey: journey,
          canCancel: true,
          audioController: audio,
        ),
      ),
    );

    await tester.tap(find.text('Sim, foi solicitada'));
    await tester.pump();

    expect(audio.stopCalls, 1);
    expect(journey.view, isA<ActiveJourneyView>());
  });

  testWidgets('interrompe o áudio ao fechar', (tester) async {
    final audio = _FakeAudioController();
    final journey = await _postColposcopyJourney();
    addTearDown(audio.dispose);
    addTearDown(journey.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: PostColposcopyDecisionScreen(
          journey: journey,
          canCancel: true,
          audioController: audio,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();

    expect(audio.stopCalls, 1);
    expect(journey.view, isA<ActiveJourneyView>());
  });

  testWidgets('interrompe o áudio quando o aplicativo fica inativo', (
    tester,
  ) async {
    final audio = _FakeAudioController();
    final journey = await _postColposcopyJourney();
    addTearDown(audio.dispose);
    addTearDown(journey.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: PostColposcopyDecisionScreen(
          journey: journey,
          canCancel: true,
          audioController: audio,
        ),
      ),
    );

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();

    expect(audio.stopCalls, 1);
  });
}

Future<JourneySession> _postColposcopyJourney() async {
  final journey = await JourneySession.restoreForTesting(
    initialValues: const {
      'introduction_completed': true,
      'journey_current_step_id': 'colposcopia',
    },
  );
  await journey.advance();
  return journey;
}
