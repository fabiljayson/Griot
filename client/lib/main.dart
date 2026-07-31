import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/theme/app_theme.dart';
import 'core/network/api_client.dart';
import 'features/authentication/data/repositories/auth_repository.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/authentication/presentation/screens/login_screen.dart';
import 'features/authentication/presentation/screens/register_screen.dart';
import 'features/authentication/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize secure storage
  const secureStorage = FlutterSecureStorage();

  // Initialize API client with secure storage
  final apiClient = ApiClient(secureStorage: secureStorage);

  // Initialize auth repository
  final authRepository = AuthRepository(
    dio: apiClient.dio,
    secureStorage: secureStorage,
  );

  runApp(MyApp(authRepository: authRepository));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;

  const MyApp({super.key, required this.authRepository});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
      ],
      child: BlocProvider(
        create: (context) => AuthBloc(
          authRepository: authRepository,
        )..add(AuthCheckRequested()),
        child: MaterialApp(
          title: 'African Teller',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const AuthGate(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/home': (context) => const HomeScreen(),
          },
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
