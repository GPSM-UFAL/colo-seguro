import 'package:flutter/material.dart';

import '../data/content.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';

/// "Apoio" — mensagens de acolhimento e onde buscar ajuda.
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      children: [
        const Text('Apoio',
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppColors.textDarkWarm)),
        const SizedBox(height: 8),
        const Text('Um espaço de cuidado com você.',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          decoration: BoxDecoration(
            color: AppColors.alertBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.favorite_rounded,
                      color: AppColors.alert, size: 26),
                  SizedBox(width: 14),
                  Text(supportHighlightTitle,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.alert)),
                ],
              ),
              SizedBox(height: 12),
              Text(supportHighlightBody,
                  style: TextStyle(
                      fontSize: 14, height: 1.45, color: AppColors.alert)),
            ],
          ),
        ),
        const SizedBox(height: 38),
        const _Label('ONDE BUSCAR AJUDA'),
        const SizedBox(height: 20),
        const Text(
          'Se precisar de orientação, atendimento médico ou acolhimento, procure o posto de saúde (UBS) mais próximo da sua casa. A equipe de saúde está preparada para te ouvir, realizar os encaminhamentos necessários e garantir todo o suporte que você precisa.',
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: AppColors.textDarkWarm,
          ),
        ),
        const SizedBox(height: 14),
        const _ListenButton(),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
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

class _ListenButton extends StatelessWidget {
  const _ListenButton();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Ouvir explicação',
      child: Material(
        color: AppColors.surfacePink,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () =>
              AudioService.instance.toggle('apoio_onde_buscar_ajuda.mp3'),
          child: const SizedBox(
            height: 52,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.volume_up_rounded,
                  color: AppColors.primaryDark,
                  size: 22,
                ),
                SizedBox(width: 10),
                Text(
                  'Ouvir explicação',
                  style: TextStyle(
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
