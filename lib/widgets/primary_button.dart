import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Botão verde principal (ex.: "Começar", "Próximo", "Concluir").
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.arrow_forward_rounded,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryPlum,
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      shadowColor: AppColors.primaryShadow,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Container(
          constraints: const BoxConstraints(minHeight: 58),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textOnPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 10),
                Icon(icon, color: AppColors.textOnPrimary, size: 22),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
