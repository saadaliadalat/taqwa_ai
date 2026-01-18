import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme/app_theme.dart';
import 'providers/settings_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/main_layout.dart';

/// Root application widget
class TaqwaAIApp extends ConsumerStatefulWidget {
  const TaqwaAIApp({super.key});

  @override
  ConsumerState<TaqwaAIApp> createState() => _TaqwaAIAppState();
}

class _TaqwaAIAppState extends ConsumerState<TaqwaAIApp> {
  bool _showMainLayout = false;

  void _onGetStarted() {
    // Mark onboarding as complete and navigate to main layout
    ref.read(settingsProvider.notifier).completeOnboarding();
    setState(() {
      _showMainLayout = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final settings = ref.watch(settingsProvider);
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Taqwa AI',
      debugShowCheckedModeBanner: false,
      
      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      
      // Localization support with delegates for RTL
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: _getLocale(settings.language),
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ar', 'SA'),
        Locale('ur', 'PK'),
        Locale('tr', 'TR'),
        Locale('id', 'ID'),
        Locale('ms', 'MY'),
      ],
      
      // Initial route determination
      home: authState.when(
        data: (user) {
          // If we've already navigated via Get Started button, show main layout
          if (_showMainLayout || settings.onboardingComplete) {
            return const MainLayout();
          }
          // Show welcome screen with proper callback
          return WelcomeScreen(onGetStarted: _onGetStarted);
        },
        loading: () => const _SplashScreen(),
        error: (_, __) => WelcomeScreen(onGetStarted: _onGetStarted),
      ),
    );
  }

  /// Get locale from language setting
  Locale _getLocale(String language) {
    switch (language) {
      case 'arabic':
        return const Locale('ar', 'SA');
      case 'urdu':
        return const Locale('ur', 'PK');
      case 'turkish':
        return const Locale('tr', 'TR');
      case 'indonesian':
        return const Locale('id', 'ID');
      case 'malay':
        return const Locale('ms', 'MY');
      default:
        return const Locale('en', 'US');
    }
  }
}

/// Splash screen shown during initialization
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App icon/logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  'تقوى',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // App name
            Text(
              'Taqwa AI',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            
            // Tagline
            Text(
              'Your Islamic AI Assistant',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 48),
            
            // Loading indicator
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
