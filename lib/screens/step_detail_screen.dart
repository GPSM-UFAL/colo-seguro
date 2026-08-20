import 'package:flutter/material.dart';

import '../data/content.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/audio_button.dart';
import '../widgets/primary_button.dart';

/// Tela de detalhe de uma etapa (nó do fluxograma), com áudio.
/// Layout fiel ao Figma "Etapa aberta".
class StepDetailScreen extends StatefulWidget {
  const StepDetailScreen({
    super.key,
    required this.content,
    this.statusLabel = '',
    this.stepNumber,
    this.totalSteps,
    this.breadcrumbLabel = 'Voltar',
    this.explorationSteps,
  });

  final StepContent content;
  final String statusLabel;
  final int? stepNumber;
  final int? totalSteps;
  final String breadcrumbLabel;
  final List<StepContent>? explorationSteps;

  @override
  State<StepDetailScreen> createState() => _StepDetailScreenState();
}

class _StepDetailScreenState extends State<StepDetailScreen> {
  int _selectedTab = 0;
  late int _currentStepIndex;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentStepIndex = (widget.stepNumber ?? 1) - 1;
  }

  StepContent get _content =>
      widget.explorationSteps?[_currentStepIndex] ?? widget.content;

  int? get _stepNumber => widget.explorationSteps == null
      ? widget.stepNumber
      : _currentStepIndex + 1;

  bool get _hasTabs => _content.tabs?.isNotEmpty ?? false;

  List<CollectionTabContent> get _tabs => _content.tabs ?? const [];

  CollectionTabContent get _activeTab =>
      _tabs[_selectedTab.clamp(0, _tabs.length - 1).toInt()];

  void _showExplorationStep(int index) {
    AudioService.instance.stop();
    setState(() {
      _currentStepIndex = index;
      _selectedTab = 0;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
    });
  }

  @override
  void dispose() {
    AudioService.instance.stop();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showProgress = widget.stepNumber != null && widget.totalSteps != null;
    final sections = _hasTabs ? _activeTab.sections : _content.sections;
    final tip = _hasTabs ? _activeTab.tip : _content.tip;
    const tipBackground = AppColors.alertBg;
    const tipTextColor = AppColors.alert;

    return Scaffold(
      backgroundColor: AppColors.bgRose,
      body: SafeArea(
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            // Breadcrumb verde "← Meu caminho"
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.arrow_back_rounded,
                      size: 20,
                      color: AppColors.primaryPlum,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.breadcrumbLabel,
                      style: const TextStyle(
                        color: AppColors.primaryPlum,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              _content.title,
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w600,
                color: AppColors.textDarkWarm,
              ),
            ),
            const SizedBox(height: 16),
            if (showProgress) ...[
              Row(
                children: List.generate(widget.totalSteps!, (i) {
                  final active = i < _stepNumber!;
                  return Expanded(
                    child: Container(
                      height: 6,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primaryPlum
                            : AppColors.borderWarm,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.statusLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryPlum,
                    ),
                  ),
                  Text(
                    'Etapa $_stepNumber de ${widget.totalSteps}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMutedWarm,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
            ],
            // Acolhimento (card ROSA)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.alertBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    color: AppColors.alert,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _content.reassurance,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.3,
                        color: AppColors.alert,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            if (_hasTabs) ...[
              _CollectionTabs(
                tabs: _tabs,
                selectedIndex: _selectedTab,
                onChanged: (index) {
                  setState(() => _selectedTab = index);
                },
              ),
              const SizedBox(height: 18),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: Column(
                  key: ValueKey(_activeTab.id),
                  children: [
                    for (int i = 0; i < sections.length; i++) ...[
                      _Section(
                        section: sections[i],
                        showAudioButton: sections[i].audioFile != null,
                      ),
                      if (i < sections.length - 1) ...[
                        const SizedBox(height: 18),
                        Container(height: 1, color: AppColors.borderWarm),
                        const SizedBox(height: 18),
                      ],
                    ],
                  ],
                ),
              ),
            ] else ...[
              // Seções (label verde com ícone + divisória bege)
              for (int i = 0; i < sections.length; i++) ...[
                _Section(section: sections[i]),
                if (i < sections.length - 1) ...[
                  const SizedBox(height: 18),
                  Container(height: 1, color: AppColors.borderWarm),
                  const SizedBox(height: 18),
                ],
              ],
            ],
            const SizedBox(height: 22),
            // Dica
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: tipBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.35,
                        color: tipTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AudioButton(audioFile: _content.audio),
            const SizedBox(height: 12),
            if (widget.explorationSteps != null) ...[
              if (_currentStepIndex > 0) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _showExplorationStep(_currentStepIndex - 1),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Etapa anterior'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      foregroundColor: AppColors.primaryPlum,
                      side: const BorderSide(color: AppColors.primaryPlum),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              if (_currentStepIndex < widget.explorationSteps!.length - 1) ...[
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'Próxima etapa',
                    onPressed: () =>
                        _showExplorationStep(_currentStepIndex + 1),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ],
            if (widget.explorationSteps == null)
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Voltar para meu caminho',
                  icon: null,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.section, this.showAudioButton = false});

  final StepSection section;
  final bool showAudioButton;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: AppColors.primaryPlum,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                section.label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: AppColors.primaryPlum,
                ),
              ),
            ),
            if (showAudioButton && section.audioFile != null) ...[
              const SizedBox(width: 12),
              AudioButton(
                audioFile: section.audioFile!,
                label: 'Ouvir texto',
                compact: true,
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Text(
          section.text,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
            color: AppColors.textDarkWarm,
          ),
        ),
      ],
    );
  }
}

class _CollectionTabs extends StatelessWidget {
  const _CollectionTabs({
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<CollectionTabContent> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const activeFill = AppColors.primaryPlum;
    const outerFill = AppColors.surfaceLavender;
    const outerBorder = AppColors.borderWarm;
    const activeText = AppColors.textOnPrimary;
    const inactiveText = AppColors.primaryPlum;
    const activeShadow = BoxShadow(
      color: Color(0x297C4A67),
      blurRadius: 10,
      offset: Offset(0, 4),
    );

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: outerFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: outerBorder, width: 1),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          for (int i = 0; i < tabs.length; i++) ...[
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: i == selectedIndex ? activeFill : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: i == selectedIndex ? const [activeShadow] : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => onChanged(i),
                    child: Center(
                      child: Text(
                        tabs[i].label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: i == selectedIndex ? activeText : inactiveText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
