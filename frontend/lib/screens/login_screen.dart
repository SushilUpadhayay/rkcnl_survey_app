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
    final email = _userController.text.trim();
    final pass = _passController.text;

    if (email.isEmpty || pass.isEmpty) {
      setState(() => _errorMessage = 'Please enter your credentials.');
      return;
    }

    setState(() => _errorMessage = null);

    final appState = context.read<AppState>();
    final success = await appState.login(email, pass);

    if (success) {
      if (mounted) context.go('/dashboard');
    } else {
      setState(() => _errorMessage = appState.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeader(dark),
                const SizedBox(height: 24),
                _buildLoginCard(dark),
                const SizedBox(height: 28),
                _buildRegisterLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool dark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF1E331E) : const Color(0xFFE8F5E9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
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
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: dark ? const Color(0xFFE8F5E8) : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Survey Application',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(bool dark) {
    final appState = context.watch<AppState>();

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 440),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1A2E1A) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: dark ? const Color(0xFF2A4F2A) : AppColors.border,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    color: dark ? const Color(0xFFE8F5E8) : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Login to continue your work',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSub,
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
                color: AppColors.redLight.withValues(alpha: dark ? 0.15 : 1.0),
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
          
          // Username Input
          const Text(
            'Username',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: AppColors.textSub,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _userController,
            textInputAction: TextInputAction.next,
            decoration: _buildInputDecoration(
              hint: 'Enter your username',
              icon: Icons.person_outline,
              dark: dark,
            ),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),

          const SizedBox(height: 20),

          // Password Input
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Password',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: AppColors.textSub,
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
              dark: dark,
              suffix: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textSub,
                  size: 22,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              ),
            ),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
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

  Widget _buildRegisterLink() {
    return Center(
      child: Wrap(
        spacing: 4,
        children: [
          const Text(
            "Don't have an account?",
            style: TextStyle(
              color: AppColors.textSub,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
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
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    required bool dark,
    Widget? suffix,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: AppColors.textSub, size: 22),
      suffixIcon: suffix,
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 15, fontWeight: FontWeight.w500),
      filled: true,
      fillColor: dark ? const Color(0xFF112011) : AppColors.bg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: dark ? const Color(0xFF2A3F2A) : AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: dark ? const Color(0xFF2A3F2A) : AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.green, width: 1.8),
      ),
    );
  }
}
