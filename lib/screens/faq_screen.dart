import 'package:flutter/material.dart';

import '../data/content.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';

/// "Tira-dúvidas" — perguntas frequentes (expansíveis) + glossário.
class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.bgRose,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        children: [
          const Text('Tira-dúvidas',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDarkWarm)),
          const SizedBox(height: 8),
          const Text('Toque numa pergunta para ver a resposta.',
              style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
          const SizedBox(height: 26),
          const _SectionLabel('PERGUNTAS FREQUENTES'),
          const SizedBox(height: 16),
          ...faqItems.indexed.map(
            (entry) => _FaqTile(
              item: entry.$2,
              initiallyExpanded: entry.$1 == 0,
            ),
          ),
          const SizedBox(height: 23),
          const _SectionLabel('PALAVRAS DIFÍCEIS'),
          const SizedBox(height: 14),
          ...glossary.map((g) => _GlossaryTile(item: g)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontSize: 12,
            height: 1,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.24,
            color: AppColors.primaryPlum));
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.item, this.initiallyExpanded = false});

  final FaqItem item;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderWarm, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x126B4452),
            blurRadius: 15.75,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          shape: const Border(),
          collapsedShape: const Border(),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          iconColor: AppColors.textMutedWarm,
          collapsedIconColor: AppColors.textMutedWarm,
          title: Text(item.question,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDarkWarm)),
          children: [
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.borderWarm,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(item.answer,
                  style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 10),
            _ListenButton(label: 'Ouvir resposta', audioFile: item.audio),
          ],
        ),
      ),
    );
  }
}

class _GlossaryTile extends StatelessWidget {
  const _GlossaryTile({required this.item});
  final GlossaryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLavender,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.term,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDarker)),
          const SizedBox(height: 6),
          Text(item.meaning,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          _ListenButton(label: 'Ouvir definição', audioFile: item.audio),
        ],
      ),
    );
  }
}

class _ListenButton extends StatelessWidget {
  const _ListenButton({required this.label, this.audioFile});

  final String label;
  final String? audioFile;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: AppColors.surfacePink,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            if (audioFile == null) return;
            final ok = await AudioService.instance.toggle(audioFile!);
            if (!ok && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Áudio ainda não foi adicionado.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.volume_up_rounded,
                  color: AppColors.primaryDark,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.primaryDarkest,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
