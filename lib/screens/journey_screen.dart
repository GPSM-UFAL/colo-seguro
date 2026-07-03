import 'package:flutter/material.dart';

import '../data/content.dart';
import '../theme/app_theme.dart';
import 'step_detail_screen.dart';

/// "Meu caminho" — mostra SÓ o caminho da paciente (definido no onboarding).
class JourneyScreen extends StatelessWidget {
  const JourneyScreen({
    super.key,
    required this.plan,
    this.onChangeSituation,
    this.onAdvanceStep,
  });

  final JourneyPlan plan;
  final VoidCallback? onChangeSituation;
  final VoidCallback? onAdvanceStep;

  void _openStep(
      BuildContext context, PlannedStep step, int number, int total) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StepDetailScreen(
          content: step.content,
          statusLabel: step.statusLabel,
          stepNumber: number,
          totalSteps: total,
          breadcrumbLabel: 'Meu caminho',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Meu caminho',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDarkWarm)),
            ),
            _ChangeButton(onTap: onChangeSituation),
          ],
        ),
        const SizedBox(height: 6),
        Text(plan.headline,
            style:
                const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
        const SizedBox(height: 24),
        ...List.generate(plan.steps.length, (i) {
          return _TimelineTile(
            step: plan.steps[i],
            isLast: i == plan.steps.length - 1,
            onOpen: () =>
                _openStep(context, plan.steps[i], i + 1, plan.steps.length),
            onAdvance: i == plan.currentStepIndex &&
                    i < plan.steps.length - 1
                ? onAdvanceStep
                : null,
          );
        }),
      ],
    );
  }
}

class _ChangeButton extends StatelessWidget {
  const _ChangeButton({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (onTap == null) return const SizedBox.shrink();
    return TextButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.edit_rounded,
          size: 16, color: AppColors.primaryPlum),
      label: const Text('Mudar',
          style: TextStyle(
              color: AppColors.primaryPlum, fontWeight: FontWeight.w600)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        backgroundColor: AppColors.surfaceLavender,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.step,
    required this.isLast,
    required this.onOpen,
    this.onAdvance,
  });

  final PlannedStep step;
  final bool isLast;
  final VoidCallback onOpen;
  final VoidCallback? onAdvance;

  @override
  Widget build(BuildContext context) {
    final isCurrent = step.status == StepStatus.current;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linha do tempo (bolinha + traço)
          Column(
            children: [
              _TimelineDot(status: step.status),
              if (!isLast)
                Expanded(
                  child: Container(
                      width: 2,
                      color: AppColors.textMutedWarm.withValues(alpha: 0.45)),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: isCurrent
                  ? _CurrentCard(
                      step: step,
                      onOpen: onOpen,
                      onAdvance: onAdvance,
                    )
                  : _PlainRow(step: step, onOpen: onOpen),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineDot extends StatelessWidget {
  const _TimelineDot({required this.status});
  final StepStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case StepStatus.done:
        return Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
              color: AppColors.primaryPlum, shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded,
              size: 16, color: AppColors.textOnPrimary),
        );
      case StepStatus.current:
        // anel verde com centro branco
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.bgRose,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryPlum, width: 4),
          ),
        );
      default:
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.bgRose,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.textMutedWarm, width: 2),
          ),
        );
    }
  }
}

/// Linha simples (etapas concluídas ou futuras) — sem caixa.
class _PlainRow extends StatelessWidget {
  const _PlainRow({required this.step, required this.onOpen});
  final PlannedStep step;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final isFuture =
        step.status == StepStatus.next || step.status == StepStatus.later;
    final titleColor =
        isFuture ? AppColors.textMutedWarm : AppColors.textDarkWarm;
    final metaColor =
        isFuture ? AppColors.textMutedWarm : AppColors.primaryPlum;
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.content.title,
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: titleColor)),
                  const SizedBox(height: 2),
                  Text(step.statusLabel,
                      style: TextStyle(fontSize: 13, color: metaColor)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textMutedWarm
                    .withValues(alpha: isFuture ? 0.6 : 1)),
          ],
        ),
      ),
    );
  }
}

/// Card destacado da etapa atual ("Você está aqui").
class _CurrentCard extends StatelessWidget {
  const _CurrentCard({
    required this.step,
    required this.onOpen,
    this.onAdvance,
  });

  final PlannedStep step;
  final VoidCallback onOpen;
  final VoidCallback? onAdvance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLavender,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primaryPlum, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 15.75,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryPlum,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('VOCÊ ESTÁ AQUI',
                style: TextStyle(
                    color: AppColors.textOnPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3)),
          ),
          const SizedBox(height: 10),
          Text(step.content.title,
              style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDarker)),
          const SizedBox(height: 6),
          Text(step.content.summary,
              style: const TextStyle(
                  fontSize: 14, height: 1.45, color: AppColors.primaryDarker)),
          const SizedBox(height: 14),
          // Botão "Entender esta etapa →"
          Material(
            color: AppColors.primaryPlum,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onOpen,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Entender esta etapa',
                        style: TextStyle(
                            color: AppColors.textOnPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded,
                        color: AppColors.textOnPrimary, size: 18),
                  ],
                ),
              ),
            ),
          ),
          if (onAdvance != null) ...[
            const SizedBox(height: 10),
            Material(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onAdvance,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: AppColors.primaryPlum, width: 1.2),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_rounded,
                          color: AppColors.primaryPlum, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text('Passei para a próxima etapa',
                            style: TextStyle(
                                color: AppColors.primaryPlum,
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
