import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/network/api_client.dart';
import 'core/network/connectivity_manager.dart';
import 'core/localization/app_localizations.dart';
import 'features/authentication/data/repositories/auth_repository.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/authentication/presentation/screens/login_screen.dart';
import 'features/authentication/presentation/screens/register_screen.dart';
import 'features/authentication/presentation/screens/home_screen.dart';
import 'features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'features/about/presentation/screens/about_screen.dart';
import 'features/stories/presentation/screens/stories_list_screen.dart';
import 'features/stories/presentation/screens/story_detail_screen.dart';
import 'features/qr_engine/data/repositories/qr_repository.dart';
import 'features/qr_engine/presentation/bloc/qr_bloc.dart';
import 'features/qr_engine/presentation/screens/qr_scanner_screen.dart';
import 'features/qr_engine/presentation/screens/qr_manager_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Sentry for crash reporting
  await SentryFlutter.init(
    (options) {
      options.dsn = const String.fromEnvironment('SENTRY_DSN', defaultValue: '');
      options.tracesSampleRate = 0.1;
    },
    appRunner: () => runApp(MyApp()),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final AuthRepository authRepository;
  late final QRRepository qrRepository;
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    
    // Initialize secure storage
    const secureStorage = FlutterSecureStorage();

    // Initialize API client with secure storage
    final apiClient = ApiClient(secureStorage: secureStorage);

    // Initialize repositories
    authRepository = AuthRepository(
      dio: apiClient.dio,
      secureStorage: secureStorage,
    );
    qrRepository = QRRepository(dio: apiClient.dio);

    // Initialize connectivity manager
    ConnectivityManager().initialize();
  }

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: qrRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: authRepository,
            )..add(AuthCheckRequested()),
          ),
          BlocProvider(
            create: (context) => QRBloc(repository: qrRepository),
          ),
        ],
        child: ConnectivityOverlay(
          child: MaterialApp(
            title: 'African Teller',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            locale: _locale,
            supportedLocales: const [
              Locale('en'),
              Locale('fr'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const AuthGate(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/home': (context) => const HomeScreen(),
              '/admin-dashboard': (context) => const AdminDashboardScreen(),
              '/about': (context) => const AboutScreen(),
              '/stories': (context) => const StoriesListScreen(),
              '/story-detail': (context) => const StoryDetailScreen(),
              '/qr-scanner': (context) => const QRScannerScreen(),
              '/qr-manager': (context) => const QRManagerScreen(),
            },
          ),
        ),
      ),
    );
  }
}

/// Redirects to Home or Login based on authentication state.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context).pushReplacementNamed('/home');
        } else if (state is AuthUnauthenticated) {
          Navigator.of(context).pushReplacementNamed('/login');
        } else if (state is AuthRegistrationSuccess) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      child: const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading African Teller...'),
            ],
          ),
        ),
      ),
    );
  }
}
