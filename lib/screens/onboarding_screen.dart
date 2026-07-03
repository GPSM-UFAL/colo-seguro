import 'package:flutter/material.dart';

import '../data/content.dart';
import '../services/journey_progress_store.dart';
import '../theme/app_theme.dart';
import 'home_shell.dart';

/// Tela "Onde você está agora?" — define o caminho da jornada.
///
/// Usada em dois modos:
///  - 1ª vez (asPicker = false): ao escolher, entra no app (HomeShell).
///  - Para mudar depois (asPicker = true): ao escolher, devolve o índice
///    com Navigator.pop(index) para a Jornada remontar o caminho.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key, this.asPicker = false});

  final bool asPicker;

  Future<void> _enter(BuildContext context, int index) async {
    await JourneyProgressStore.saveSituationIndex(index);
    if (!context.mounted) return;

    if (asPicker) {
      Navigator.of(context).pop(index);
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomeShell(
          currentStepIndex: currentStepIndexForOnboarding(index),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: asPicker
          ? AppBar(
              backgroundColor: AppColors.bgRose,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              shadowColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.close_rounded),
                color: AppColors.textBody,
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'Mudar minha situação',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBody,
                ),
              ),
              centerTitle: false,
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(onboardingTitle,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                    color: AppColors.textBody,
                  )),
              const SizedBox(height: 16),
              const Text(onboardingSubtitle,
                  style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textTertiary,
                      height: 1.48)),
              const SizedBox(height: 32),
              Expanded(
                child: Stack(
                  children: [
                    ListView.separated(
                      padding: const EdgeInsets.only(bottom: 56),
                      itemCount: onboardingOptions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => _OptionCard(
                        label: onboardingOptions[i],
                        icon: onboardingIcons[i],
                        onTap: () => _enter(context, i),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: Container(
                          height: 56,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0x00FFF7F4), AppColors.bgRose],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard(
      {required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 82,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.surfaceWarm,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowLight,
                  offset: Offset(0, 6),
                  blurRadius: 15.75,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 12, 0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceLavender,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: AppColors.primaryPlum, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 3,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.2,
                        color: AppColors.textBody,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textMutedWarm, size: 22),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
