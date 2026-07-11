import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _obscureText = true;
  String? _errorMessage;

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final user = _userController.text.trim();
    final pass = _passController.text;

    if (user.isEmpty || pass.isEmpty) {
      setState(() => _errorMessage = 'Please enter your credentials.');
      return;
    }

    setState(() => _errorMessage = null);

    final appState = context.read<AppState>();
    final success = await appState.login(user, pass);
    if (success) {
      if (mounted) context.go('/dashboard');
    } else {
      setState(() {
        _errorMessage = appState.errorMessage ?? 'Login failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = context.appColors;
    
    return Scaffold(
      backgroundColor: tc.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                    child: Column(
                      children: [
                        const Spacer(),
                        _buildHeader(tc),
                        const Spacer(),
                        _buildLoginCard(tc),
                        const Spacer(),
                        _buildFooter(tc),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(AppThemeColors tc) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tc.surface,
            shape: BoxShape.circle,
            border: Border.all(color: tc.border),
            boxShadow: [
              if (!tc.isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Image.asset(
            'assets/images/Krishi_Logo-Tr.png',
            width: 72,
            height: 72,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.eco, size: 72, color: AppColors.green);
            },
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Rastriye Krishi',
          style: TextStyle(
            color: tc.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Survey Application',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: tc.textSub,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(AppThemeColors tc) {
    final appState = context.watch<AppState>();

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 440),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: tc.border,
          width: 1.2,
        ),
        boxShadow: [
          if (!tc.isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: tc.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Login to continue your work',
                  style: TextStyle(
                    fontSize: 14,
                    color: tc.textSub,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          if (_errorMessage != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: tc.redLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.red, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: AppColors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 28),
          
          // Email Input
          Text(
            'Email Address',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: tc.textSub,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _userController,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            decoration: _buildInputDecoration(
              hint: 'Enter your email address',
              icon: Icons.email_outlined,
              tc: tc,
            ),
            style: TextStyle(color: tc.textPrimary, fontWeight: FontWeight.w600, fontSize: 15),
          ),

          const SizedBox(height: 20),

          // Password Input
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Password',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: tc.textSub,
                ),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please contact your administrator to reset password.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passController,
            obscureText: _obscureText,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleLogin(),
            decoration: _buildInputDecoration(
              hint: '••••••••',
              icon: Icons.lock_outline,
              tc: tc,
              suffix: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: tc.textSub,
                  size: 22,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              ),
            ),
            style: TextStyle(color: tc.textPrimary, fontWeight: FontWeight.w600, fontSize: 15),
          ),

          const SizedBox(height: 32),

          // Login Button
          ElevatedButton(
            onPressed: appState.isAuthenticating ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: appState.isAuthenticating
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Login',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(AppThemeColors tc) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 440),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: TextStyle(color: tc.textSub, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: () => context.push('/register'),
                child: const Text(
                  'Register',
                  style: TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    required AppThemeColors tc,
    Widget? suffix,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: tc.textSub, size: 22),
      suffixIcon: suffix,
      hintText: hint,
      hintStyle: TextStyle(color: tc.textMuted, fontSize: 15, fontWeight: FontWeight.w500),
      filled: true,
      fillColor: tc.surfaceVariant,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: tc.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: tc.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.green, width: 1.8),
      ),
    );
  }
}
