import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../services/audio_service.dart';
import '../theme/app_theme.dart';

/// Botão "Ouvir explicação" reutilizável.
///
/// Recebe o nome do arquivo de áudio (ex.: `vamos_te_acompanhar.mp3`) que deve
/// estar em `assets/audio/`. Mostra ícone de play/pause e dá feedback se o áudio
/// ainda não estiver disponível.
class AudioButton extends StatefulWidget {
  const AudioButton({
    super.key,
    required this.audioFile,
    this.label = 'Ouvir explicação',
    this.compact = false,
    this.audioController,
  });

  final String audioFile;
  final String label;
  final bool compact;
  final AudioController? audioController;

  @override
  State<AudioButton> createState() => _AudioButtonState();
}

class _AudioButtonState extends State<AudioButton> {
  AudioController get _audio => widget.audioController ?? AudioService.instance;

  Future<void> _onTap() async {
    final ok = await _audio.toggle(widget.audioFile);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Áudio "${widget.audioFile}" ainda não foi adicionado.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final compact = widget.compact;
    return StreamBuilder<PlayerState>(
      stream: _audio.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final playing = _audio.currentFile == widget.audioFile &&
            (playerState?.playing ?? _audio.isPlaying) &&
            playerState?.processingState != ProcessingState.completed;
        final borderRadius = BorderRadius.circular(compact ? 9999 : 16);
        final background =
            compact ? AppColors.surfaceLilac : AppColors.surfacePink;
        final border = compact ? AppColors.primaryPlum : Colors.transparent;
        final iconColor =
            compact ? AppColors.primaryPlum : AppColors.primaryDark;
        final textColor =
            compact ? AppColors.primaryPlum : AppColors.primaryDarkest;
        final shadow = compact
            ? const BoxShadow(
                color: Color(0x12000000),
                blurRadius: 3,
                offset: Offset(0, 1),
              )
            : const BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 10,
                offset: Offset(0, 4),
              );
        return Semantics(
          button: true,
          label: playing ? 'Pausar explicação em áudio' : widget.label,
          child: Container(
            decoration: BoxDecoration(
              color: background,
              borderRadius: borderRadius,
              border: Border.all(color: border, width: compact ? 1 : 0),
              boxShadow: [shadow],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: borderRadius,
                onTap: _onTap,
                child: Container(
                  width: compact ? null : double.infinity,
                  constraints: BoxConstraints(minHeight: compact ? 36 : 52),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: compact ? 0 : 12,
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        playing ? Icons.pause_rounded : Icons.volume_up_rounded,
                        color: iconColor,
                        size: compact ? 16 : 22,
                      ),
                      const SizedBox(width: 8),
                      if (compact)
                        Text(
                          playing ? 'Pausar' : widget.label,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else
                        Flexible(
                          child: Text(
                            playing ? 'Pausar' : widget.label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
