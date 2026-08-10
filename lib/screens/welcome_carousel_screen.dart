import 'package:flutter/material.dart';

import '../data/content.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_illustration.dart';
import '../widgets/audio_button.dart';
import '../widgets/primary_button.dart';
import 'onboarding_screen.dart';

/// Telas 0 a 5 do Figma — carrossel de boas-vindas com áudio.
class WelcomeCarouselScreen extends StatefulWidget {
  const WelcomeCarouselScreen({super.key, this.audioController});

  final AudioController? audioController;

  @override
  State<WelcomeCarouselScreen> createState() => _WelcomeCarouselScreenState();
}

class _WelcomeCarouselScreenState extends State<WelcomeCarouselScreen>
    with WidgetsBindingObserver {
  final _controller = PageController();
  int _index = 0;

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

  void _next() {
    if (_index < introPages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    } else {
      _goToApp();
    }
  }

  void _onPageChanged(int index) {
    _audio.stop();
    setState(() => _index = index);
  }

  void _goToApp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audio.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Row(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/branding/splash_logo.png',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Colo Seguro',
                        style: TextStyle(
                          color: AppColors.primaryDarker,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (_index < introPages.length - 1)
                    TextButton(
                      onPressed: _goToApp,
                      child: const Text(
                        'Pular',
                        style: TextStyle(color: AppColors.primaryDark),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: _onPageChanged,
                itemCount: introPages.length,
                itemBuilder: (context, i) {
                  final page = introPages[i];
                  return _IntroPageView(
                    page: page,
                    showProgress: i > 0,
                    progressValue: i > 0 ? i / (introPages.length - 1) : 0,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: AudioButton(
                      audioFile: introPages[_index].audio,
                      label: 'Ouvir',
                      audioController: widget.audioController,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_index == 0)
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        label: introPages[_index].cta,
                        icon: Icons.arrow_forward_rounded,
                        onPressed: _next,
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: _SecondaryButton(
                            label: 'Voltar',
                            icon: Icons.arrow_back_rounded,
                            onPressed: () => _controller.previousPage(
                              duration: const Duration(milliseconds: 280),
                              curve: Curves.easeInOut,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PrimaryButton(
                            label: introPages[_index].cta,
                            icon: _index == introPages.length - 1
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded,
                            onPressed: _next,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroPageView extends StatelessWidget {
  const _IntroPageView({
    required this.page,
    required this.showProgress,
    required this.progressValue,
  });
  final IntroPage page;
  final bool showProgress;
  final double progressValue;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showProgress) ...[
            Text(
              page.stepLabel ?? '',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progressValue,
                minHeight: 8,
                backgroundColor: AppColors.textMuted.withValues(alpha: 0.14),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryPlum,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          AppIllustration(imageName: page.illustration, height: 244),
          const SizedBox(height: 24),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 25,
              fontWeight: FontWeight.w600,
              height: 1.28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page.body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          if (page.bodySecondary != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceWarm,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderLight, width: 1),
              ),
              child: Text(
                page.bodySecondary!,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  color: AppColors.textBody,
                  fontSize: 15,
                  height: 1.55,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceWarm,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Container(
          height: 58,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.textBody, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textBody,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
