import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';

import 'package:acolher_app/main.dart';
import 'package:acolher_app/screens/faq_screen.dart';
import 'package:acolher_app/screens/support_screen.dart';
import 'package:acolher_app/screens/welcome_carousel_screen.dart';
import 'package:acolher_app/services/audio_service.dart';
import 'package:acolher_app/services/journey_session.dart';
import 'package:acolher_app/widgets/audio_button.dart';

class _FakeAudioController implements AudioController {
  final _states = StreamController<PlayerState>.broadcast();

  bool toggleSucceeds = true;
  int stopCalls = 0;
  String? _currentFile;
  bool _isPlaying = false;

  @override
  String? get currentFile => _currentFile;

  @override
  bool get isPlaying => _isPlaying;

  @override
  Stream<PlayerState> get playerStateStream => _states.stream;

  @override
  Future<bool> toggle(String fileName) async {
    if (!toggleSucceeds) return false;

    if (_currentFile == fileName && _isPlaying) {
      _isPlaying = false;
    } else {
      _currentFile = fileName;
      _isPlaying = true;
    }
    _emitState();
    return true;
  }

  @override
  Future<void> stop() async {
    stopCalls++;
    _currentFile = null;
    _isPlaying = false;
    _emitState(processingState: ProcessingState.idle);
  }

  void start(String fileName) {
    _currentFile = fileName;
    _isPlaying = true;
    _emitState();
  }

  void _emitState({ProcessingState processingState = ProcessingState.ready}) {
    _states.add(PlayerState(_isPlaying, processingState));
  }

  Future<void> dispose() => _states.close();
}

void main() {
  testWidgets('App inicia na tela de boas-vindas', (WidgetTester tester) async {
    final journey = await JourneySession.restoreForTesting();
    addTearDown(journey.dispose);
    await tester.pumpWidget(ColoSeguroApp(journey: journey));
    await tester.pump();

    expect(find.text('Vamos te acompanhar'), findsOneWidget);
    expect(find.text('Começar'), findsOneWidget);
  });

  testWidgets('FAQ usa o botão de áudio compartilhado', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: FaqScreen()));

    final buttons = find.byType(AudioButton);
    expect(buttons, findsWidgets);
    expect(
      tester
          .widget<AudioButton>(
            find.widgetWithText(AudioButton, 'Ouvir resposta'),
          )
          .label,
      'Ouvir resposta',
    );
  });

  testWidgets('Apoio usa o botão de áudio compartilhado', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SupportScreen()));

    final button = tester.widget<AudioButton>(find.byType(AudioButton));
    expect(button.audioFile, 'apoio_onde_buscar_ajuda.mp3');
    expect(button.label, 'Ouvir explicação');
  });

  testWidgets('Botão de áudio acompanha reprodução e pausa', (
    WidgetTester tester,
  ) async {
    final audio = _FakeAudioController();
    addTearDown(audio.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AudioButton(
            audioFile: 'teste.mp3',
            label: 'Ouvir teste',
            audioController: audio,
          ),
        ),
      ),
    );

    expect(find.text('Ouvir teste'), findsOneWidget);
    expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);

    await tester.tap(find.byType(AudioButton));
    await tester.pump();

    expect(find.text('Pausar'), findsOneWidget);
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);

    await tester.tap(find.byType(AudioButton));
    await tester.pump();

    expect(find.text('Ouvir teste'), findsOneWidget);
    expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
  });

  testWidgets('Botão de áudio informa falha ao carregar arquivo', (
    WidgetTester tester,
  ) async {
    final audio = _FakeAudioController()..toggleSucceeds = false;
    addTearDown(audio.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AudioButton(
            audioFile: 'ausente.mp3',
            audioController: audio,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(AudioButton));
    await tester.pump();

    expect(
      find.text('Áudio "ausente.mp3" ainda não foi adicionado.'),
      findsOneWidget,
    );
  });

  testWidgets('Carrossel interrompe o áudio ao trocar de página', (
    WidgetTester tester,
  ) async {
    final audio = _FakeAudioController();
    final journey = await JourneySession.restoreForTesting();
    addTearDown(audio.dispose);
    addTearDown(journey.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: WelcomeCarouselScreen(
          journey: journey,
          audioController: audio,
        ),
      ),
    );
    await tester.pump();

    audio.start('vamos_te_acompanhar.mp3');
    audio.stopCalls = 0;
    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(find.text('Primeiros cuidados'), findsOneWidget);
    expect(audio.stopCalls, 1);
    expect(audio.currentFile, isNull);
    expect(audio.isPlaying, isFalse);
  });
}
