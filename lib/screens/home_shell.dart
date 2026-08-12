import 'package:flutter/material.dart';

import '../services/audio_service.dart';
import '../services/journey_session.dart';
import '../theme/app_theme.dart';
import 'faq_screen.dart';
import 'journey_screen.dart';
import 'support_screen.dart';

/// Shell with the bottom navigation: Caminho · Dúvidas · Apoio.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.journey});

  final JourneySession journey;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  int _index = 0;

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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _advanceStep() async {
    final result = await widget.journey.advance();
    if (!mounted) return;
    if (result case JourneyActionFailed(:final message)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final view = widget.journey.view;
    final plan = switch (view) {
      ActiveJourneyView(:final plan) => plan,
      ExplorationView(:final plan) => plan,
      _ => throw StateError('HomeShell requires a renderable journey.'),
    };
    final exploration = view is ExplorationView ? view : null;
    final isExploration = exploration != null;

    final pages = [
      JourneyScreen(
        plan: plan,
        onChangeSituation:
            isExploration ? null : widget.journey.beginCurrentStageSelection,
        onDefineCurrentStage:
            isExploration ? widget.journey.beginCurrentStageSelection : null,
        onReturnToJourney: exploration?.hasPreservedProgress == true
            ? widget.journey.returnToActiveJourney
            : null,
        onAdvanceStep: plan.canAdvance ? _advanceStep : null,
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
            onDestinationSelected: (index) {
              AudioService.instance.stop();
              setState(() => _index = index);
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
