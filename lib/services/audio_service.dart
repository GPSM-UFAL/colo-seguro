import 'package:just_audio/just_audio.dart';

abstract interface class AudioController {
  String? get currentFile;
  Stream<PlayerState> get playerStateStream;
  bool get isPlaying;

  Future<bool> toggle(String fileName);
  Future<void> stop();
}

/// Serviço único (singleton) que controla a reprodução dos áudios do app.
///
/// Os áudios ficam em `assets/audio/`. Cada tela passa o nome do arquivo
/// (ex.: `intro_0.mp3`) e este serviço toca/pausa.
class AudioService implements AudioController {
  AudioService._internal() {
    _player.processingStateStream.listen((state) async {
      if (state == ProcessingState.completed) {
        await _player.pause();
        await _player.seek(Duration.zero);
      }
    });
  }
  static final AudioService instance = AudioService._internal();

  final AudioPlayer _player = AudioPlayer();

  /// Caminho do arquivo que está tocando agora (ou null).
  String? _currentFile;
  @override
  String? get currentFile => _currentFile;

  /// Stream do estado do player — use para atualizar o ícone play/pause.
  @override
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  @override
  bool get isPlaying =>
      _player.playing && _player.processingState != ProcessingState.completed;

  /// Toca um arquivo de `assets/audio/<fileName>`.
  /// Se o mesmo arquivo já estiver tocando, pausa (toggle).
  /// Retorna `false` se o áudio ainda não existe na pasta.
  @override
  Future<bool> toggle(String fileName) async {
    final assetPath = 'assets/audio/$fileName';
    try {
      if (_currentFile == fileName) {
        if (_player.processingState == ProcessingState.completed) {
          await _player.seek(Duration.zero);
        } else if (_player.playing) {
          await _player.pause();
          return true;
        } else {
          await _player.seek(Duration.zero);
        }
      } else {
        await _player.stop();
        await _player.setAsset(assetPath);
        _currentFile = fileName;
      }

      await _player.play();
      return true;
    } catch (e) {
      // Arquivo ainda não foi colocado na pasta assets/audio.
      _currentFile = null;
      return false;
    }
  }

  @override
  Future<void> stop() async {
    _currentFile = null;
    await _player.stop();
  }

  void dispose() {
    _player.dispose();
  }
}
