import 'package:flutter/material.dart';

import '../data/content.dart';
import '../services/audio_service.dart';
import '../services/journey_progress_store.dart';
import '../theme/app_theme.dart';
import 'journey_screen.dart';
import 'faq_screen.dart';
import 'onboarding_screen.dart';
import 'support_screen.dart';

/// Casca com a barra inferior: Caminho · Dúvidas · Apoio.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.currentStepIndex});

  final int currentStepIndex;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  int _index = 0;
  late int _currentStepIndex = widget.currentStepIndex;
  late JourneyPlan _plan = journeyForCurrentStepIndex(_currentStepIndex);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      AudioService.instance.stop();
    }
  }

  /// Reabre a tela "Onde você está agora?" e remonta o caminho.
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _changeSituation() async {
    final index = await Navigator.of(context).push<int>(
      MaterialPageRoute(builder: (_) => const OnboardingScreen(asPicker: true)),
    );
    if (index != null) {
      await JourneyProgressStore.saveSituationIndex(index);
      if (!mounted) return;
      setState(() {
        _currentStepIndex = currentStepIndexForOnboarding(index);
        _plan = journeyForCurrentStepIndex(_currentStepIndex);
      });
    }
  }

  Future<void> _advanceStep() async {
    if (_currentStepIndex >= _plan.steps.length - 1) return;

    final nextStepIndex = _currentStepIndex + 1;
    await JourneyProgressStore.saveCurrentStepIndex(nextStepIndex);
    if (!mounted) return;

    setState(() {
      _currentStepIndex = nextStepIndex;
      _plan = journeyForCurrentStepIndex(_currentStepIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      JourneyScreen(
        plan: _plan,
        onChangeSituation: _changeSituation,
        onAdvanceStep: _advanceStep,
      ),
      const FaqScreen(),
      const SupportScreen(),
    ];

    return Scaffold(
      body: SafeArea(bottom: false, child: pages[_index]),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.bgSurface,
          border: Border(
            top: BorderSide(color: AppColors.borderWarm, width: 1),
          ),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: AppColors.bgSurface,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            indicatorColor: Colors.transparent,
            elevation: 0,
            height: 84,
            iconTheme: WidgetStateProperty.resolveWith((states) {
              final color = states.contains(WidgetState.selected)
                  ? AppColors.primaryPlum
                  : AppColors.textMutedWarm;
              return IconThemeData(color: color, size: 24);
            }),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return TextStyle(
                color:
                    selected ? AppColors.primaryPlum : AppColors.textMutedWarm,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
              );
            }),
          ),
          child: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) {
                AudioService.instance.stop();
                setState(() => _index = i);
              },
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.timeline_rounded),
                label: 'Caminho',
              ),
              NavigationDestination(
                icon: Icon(Icons.help_outline_rounded),
                label: 'Dúvidas',
              ),
              NavigationDestination(
                icon: Icon(Icons.favorite_outline_rounded),
                label: 'Apoio',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
