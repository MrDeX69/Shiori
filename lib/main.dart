import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/di/injection.dart';
import 'features/onboarding/onboarding_screen.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await configureDependencies();
  FlutterNativeSplash.remove();

  runApp(
    const ProviderScope(
      child: ShioriApp(),
    ),
  );
}

class ShioriApp extends ConsumerStatefulWidget {
  const ShioriApp({super.key});

  @override
  ConsumerState<ShioriApp> createState() => _ShioriAppState();
}

class _ShioriAppState extends ConsumerState<ShioriApp>
    with WidgetsBindingObserver {
  bool _showOnboarding = false;
  bool _isLocked = false;
  bool _isAuthenticating = false;
  bool _initialized = false;
  final _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
    final biometricEnabled = prefs.getBool('biometric_enabled') ?? false;

    if (!onboardingComplete) {
      setState(() {
        _showOnboarding = true;
        _initialized = true;
      });
    } else if (biometricEnabled) {
      setState(() {
        _isLocked = true;
        _initialized = true;
      });
      _authenticate();
    } else {
      setState(() => _initialized = true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      final prefs = await SharedPreferences.getInstance();
      final biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
      if (biometricEnabled && !_isLocked) {
        setState(() => _isLocked = true);
      }
    }
    if (state == AppLifecycleState.resumed && _isLocked && !_isAuthenticating) {
      _authenticate();
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Shiori',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      if (authenticated && mounted) {
        setState(() {
          _isLocked = false;
          _isAuthenticating = false;
        });
      } else if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color(0xFF0A0A0F),
        ),
      );
    }

    if (_showOnboarding) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: OnboardingScreen(
          onComplete: () {
            setState(() => _showOnboarding = false);
          },
        ),
      );
    }

    if (_isLocked) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: Scaffold(
          backgroundColor: const Color(0xFF0A0A0F),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFE85D75),
                        Color(0xFF9B3F5C),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE85D75).withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.fingerprint,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Shiori is Locked',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Authenticate to continue',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _isAuthenticating ? null : _authenticate,
                  icon: const Icon(Icons.fingerprint),
                  label: Text(
                    _isAuthenticating
                        ? 'Authenticating...'
                        : 'Authenticate',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE85D75),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Shiori',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      routerConfig: router,
    );
  }
}