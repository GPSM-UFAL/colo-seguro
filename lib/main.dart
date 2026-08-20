import 'package:flutter/material.dart';

import 'screens/home_shell.dart';
import 'screens/onboarding_screen.dart';
import 'screens/post_colposcopy_decision_screen.dart';
import 'screens/welcome_carousel_screen.dart';
import 'services/journey_session.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ColoSeguroBootstrap());
}

class ColoSeguroBootstrap extends StatefulWidget {
  const ColoSeguroBootstrap({super.key});

  @override
  State<ColoSeguroBootstrap> createState() => _ColoSeguroBootstrapState();
}

class _ColoSeguroBootstrapState extends State<ColoSeguroBootstrap> {
  late Future<JourneySession> _journey = JourneySession.restore();

  void _retry() {
    setState(() => _journey = JourneySession.restore());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<JourneySession>(
      future: _journey,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ColoSeguroApp(journey: snapshot.requireData);
        }

        if (snapshot.hasError) {
          return MaterialApp(
            title: 'Colo Seguro',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            home: Scaffold(
              body: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 40),
                        const SizedBox(height: 16),
                        const Text(
                          'Não foi possível carregar sua jornada.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _retry,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return MaterialApp(
          title: 'Colo Seguro',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const _BrandLaunchScreen(),
        );
      },
    );
  }
}

class _BrandLaunchScreen extends StatelessWidget {
  const _BrandLaunchScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image(
                  image: AssetImage('assets/branding/logo_mark.png'),
                  width: 176,
                  height: 176,
                  semanticLabel: 'Símbolo do Colo Seguro',
                ),
                SizedBox(height: 20),
                Text(
                  'Colo Seguro',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textDarkWarm,
                    fontSize: 32,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
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

class ColoSeguroApp extends StatelessWidget {
  const ColoSeguroApp({super.key, required this.journey});

  final JourneySession journey;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Colo Seguro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: AnimatedBuilder(
        animation: journey,
        builder: (context, _) {
          return switch (journey.view) {
            IntroductionView() => WelcomeCarouselScreen(journey: journey),
            OnboardingView(:final canCancel) => OnboardingScreen(
                journey: journey,
                canCancel: canCancel,
              ),
            PostColposcopyDecisionView(:final canCancel) =>
              PostColposcopyDecisionScreen(
                journey: journey,
                canCancel: canCancel,
              ),
            ActiveJourneyView() ||
            ExplorationView() =>
              HomeShell(journey: journey),
          };
        },
      ),
    );
  }
}
