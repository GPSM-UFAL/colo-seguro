import 'package:flutter/material.dart';

import '../domain/journey_definition.dart';
import '../services/audio_service.dart';
import '../services/journey_session.dart';
import '../theme/app_theme.dart';
import '../widgets/audio_button.dart';
import '../widgets/primary_button.dart';

class PostColposcopyDecisionScreen extends StatefulWidget {
  const PostColposcopyDecisionScreen({
    super.key,
    required this.journey,
    required this.canCancel,
    this.audioController,
  });

  final JourneySession journey;
  final bool canCancel;
  final AudioController? audioController;

  @override
  State<PostColposcopyDecisionScreen> createState() =>
      _PostColposcopyDecisionScreenState();
}

class _PostColposcopyDecisionScreenState
    extends State<PostColposcopyDecisionScreen> with WidgetsBindingObserver {
  AudioController get _audio => widget.audioController ?? AudioService.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _audio.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audio.stop();
    super.dispose();
  }

  Future<void> _answer(
    BuildContext context,
    BiopsyRequestAnswer answer,
  ) async {
    if (widget.journey.isSaving) return;

    await _audio.stop();
    final result = await widget.journey.resolvePostColposcopy(answer);
    if (!context.mounted) return;
    if (result case JourneyActionFailed(:final message)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _cancel() async {
    await _audio.stop();
    if (!mounted) return;
    widget.journey.cancelTransientView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.canCancel
          ? AppBar(
              leading: IconButton(
                onPressed: _cancel,
                icon: const Icon(Icons.close_rounded),
              ),
            )
          : null,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          size: 46,
                          color: AppColors.primaryPlum,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Depois da colposcopia',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDarkWarm,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'A equipe informou que você precisa fazer uma biópsia?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            height: 1.45,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'A biópsia só é necessária quando uma área precisa ser analisada com mais atenção.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        AudioButton(
                          audioFile: 'depois_colposcopia.mp3',
                          label: 'Ouvir explicação',
                          audioController: widget.audioController,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          PrimaryButton(
                            label: 'Sim, foi solicitada',
                            icon: Icons.arrow_forward_rounded,
                            onPressed: () => _answer(
                              context,
                              BiopsyRequestAnswer.requested,
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(58),
                              foregroundColor: AppColors.primaryPlum,
                              side: const BorderSide(
                                color: AppColors.primaryPlum,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () => _answer(
                              context,
                              BiopsyRequestAnswer.notRequested,
                            ),
                            child: const Text(
                              'Não, não foi solicitada',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
