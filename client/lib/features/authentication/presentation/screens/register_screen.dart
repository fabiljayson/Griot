import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(AuthRegisterRequested(
            username: _usernameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            passwordConfirm: _passwordConfirmController.text,
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.parchment,
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: AppTheme.terracotta,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.terracotta,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          } else if (state is AuthRegistrationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Account created successfully! Please sign in.',
                  style: GoogleFonts.notoSans(color: Colors.white),
                ),
                backgroundColor: AppTheme.savannahGreen,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            Navigator.of(context).pop();
          }
        },
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Header ──
                    _buildHeader(),
                    const SizedBox(height: 32),

                    // ── Form Fields ──
                    _buildFormFields(),
                    const SizedBox(height: 28),

                    // ── Register Button ──
                    _buildRegisterButton(),
                    const SizedBox(height: 24),

                    // ── Login Link ──
                    _buildLoginLink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          Icons.person_add_outlined,
          size: 64,
          color: AppTheme.terracotta,
        ),
        const SizedBox(height: 16),
        Text(
          'Join African Teller',
          style: GoogleFonts.notoSerif(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppTheme.terracotta,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Create an account to start exploring\nAfrican heritage and culture',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            color: AppTheme.warmGray,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Column(
          children: [
            // Username
            _buildField(
              controller: _usernameController,
              label: 'Username',
              hint: 'Choose a username',
              icon: Icons.person_outline_rounded,
              enabled: !isLoading,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter a username';
                if (v.trim().length < 3) return 'Must be at least 3 characters';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email
            _buildField(
              controller: _emailController,
              label: 'Email',
              hint: 'Enter your email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              enabled: !isLoading,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter your email';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Name Row
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    controller: _firstNameController,
                    label: 'First Name',
                    hint: 'First',
                    enabled: !isLoading,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildField(
                    controller: _lastNameController,
                    label: 'Last Name',
                    hint: 'Last',
                    enabled: !isLoading,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Password
            _buildField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Create a password',
              icon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              enabled: !isLoading,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.warmGray,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please enter a password';
                if (v.length < 8) return 'Must be at least 8 characters';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Confirm Password
            _buildField(
              controller: _passwordConfirmController,
              label: 'Confirm Password',
              hint: 'Confirm your password',
              icon: Icons.lock_outline_rounded,
              obscureText: _obscurePasswordConfirm,
              enabled: !isLoading,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _onRegister(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePasswordConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.warmGray,
                ),
                onPressed: () =>
                    setState(() => _obscurePasswordConfirm = !_obscurePasswordConfirm),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please confirm your password';
                if (v != _passwordController.text) return 'Passwords do not match';
                return null;
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    bool obscureText = false,
    bool enabled = true,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    TextInputAction textInputAction = TextInputAction.next,
    void Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: AppTheme.ivory,
      ),
      validator: validator,
    );
  }

  Widget _buildRegisterButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : _onRegister,
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: GoogleFonts.notoSans(
            color: AppTheme.warmGray,
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Text(
            'Sign In',
            style: GoogleFonts.notoSerif(
              color: AppTheme.terracotta,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
