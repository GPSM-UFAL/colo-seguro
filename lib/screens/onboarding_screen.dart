import 'package:flutter/material.dart';

import '../data/content.dart';
import '../domain/journey_definition.dart';
import '../services/journey_session.dart';
import '../theme/app_theme.dart';

/// “Onde você está agora?” defines the current care-journey stage.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({
    super.key,
    required this.journey,
    required this.canCancel,
  });

  final JourneySession journey;
  final bool canCancel;

  Future<void> _choose(
    BuildContext context,
    JourneySituation situation,
  ) async {
    if (journey.isSaving) return;

    final result = await journey.chooseSituation(situation);
    if (!context.mounted) return;
    if (result case JourneyActionFailed(:final message)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: canCancel
          ? AppBar(
              backgroundColor: AppColors.bgRose,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              shadowColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.close_rounded),
                color: AppColors.textBody,
                onPressed: journey.cancelTransientView,
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 620;
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                compact ? 14 : 22,
                24,
                compact ? 12 : 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    onboardingTitle,
                    style: TextStyle(
                      fontSize: compact ? 24 : 26,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                      color: AppColors.textBody,
                    ),
                  ),
                  SizedBox(height: compact ? 8 : 16),
                  Text(
                    onboardingSubtitle,
                    style: TextStyle(
                      fontSize: compact ? 14 : 15,
                      color: AppColors.textTertiary,
                      height: compact ? 1.35 : 1.48,
                    ),
                  ),
                  SizedBox(height: compact ? 12 : 32),
                  Expanded(
                    child: _OptionsList(
                      compact: compact,
                      onChoose: (situation) => _choose(context, situation),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OptionsList extends StatelessWidget {
  const _OptionsList({
    required this.compact,
    required this.onChoose,
  });

  final bool compact;
  final ValueChanged<JourneySituation> onChoose;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = compact ? 6.0 : 12.0;
        final minimumCardHeight = compact ? 54.0 : 68.0;
        final preferredCardHeight = compact ? 74.0 : 82.0;
        final gapsHeight = spacing * (onboardingOptions.length - 1);
        final availableCardHeight =
            (constraints.maxHeight - gapsHeight) / onboardingOptions.length;
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final canShowAll =
            availableCardHeight >= minimumCardHeight && textScale <= 1.05;

        if (canShowAll) {
          final cardHeight = availableCardHeight
              .clamp(minimumCardHeight, preferredCardHeight)
              .toDouble();
          return Column(
            children: [
              for (var index = 0;
                  index < onboardingOptions.length;
                  index++) ...[
                SizedBox(
                  height: cardHeight,
                  child: _OptionCard(
                    option: onboardingOptions[index],
                    compact: compact,
                    onTap: () => onChoose(onboardingOptions[index].situation),
                  ),
                ),
                if (index < onboardingOptions.length - 1)
                  SizedBox(height: spacing),
              ],
            ],
          );
        }

        return Stack(
          children: [
            ListView.separated(
              padding: const EdgeInsets.only(bottom: 40),
              itemCount: onboardingOptions.length,
              separatorBuilder: (_, __) => SizedBox(height: spacing),
              itemBuilder: (context, index) {
                return SizedBox(
                  height: preferredCardHeight,
                  child: _OptionCard(
                    option: onboardingOptions[index],
                    compact: compact,
                    onTap: () => onChoose(onboardingOptions[index].situation),
                  ),
                );
              },
            ),
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x00FFF7F4), AppColors.bgRose],
                    ),
                  ),
                  child: SizedBox(height: 40),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.option,
    required this.compact,
    required this.onTap,
  });

  final OnboardingOption option;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 34.0 : 40.0;
    return Material(
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
            padding: EdgeInsets.fromLTRB(compact ? 12 : 14, 0, 12, 0),
            child: Row(
              children: [
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceLavender,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    option.icon,
                    color: AppColors.primaryPlum,
                    size: compact ? 20 : 22,
                  ),
                ),
                SizedBox(width: compact ? 10 : 12),
                Expanded(
                  child: Text(
                    option.label,
                    maxLines: 3,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: compact ? 14 : 16,
                      height: compact ? 1.15 : 1.2,
                      color: AppColors.textBody,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: compact ? 6 : 10),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMutedWarm,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
