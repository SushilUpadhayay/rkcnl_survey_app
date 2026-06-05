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

    await context.read<AppState>().login(user);
    if (mounted) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final tc = context.appColors;
=======
    final dark = Theme.of(context).brightness == Brightness.dark;
    
>>>>>>> register
    return Scaffold(
      backgroundColor: tc.bg,
      body: SafeArea(
<<<<<<< HEAD
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                    child: Column(
                      children: [
                        _buildHeader(tc),
                        const Spacer(),
                        _buildLoginForm(tc),
                        const Spacer(),
                        _buildFooter(tc),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
=======
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
>>>>>>> register
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildHeader(AppThemeColors tc) {
=======
  Widget _buildHeader(bool dark) {
>>>>>>> register
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
<<<<<<< HEAD
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
=======
            color: dark ? const Color(0xFF1E331E) : const Color(0xFFE8F5E9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
>>>>>>> register
            ],
          ),
          child: Image.asset(
            'assets/images/Krishi_Logo-Tr.png',
<<<<<<< HEAD
            width: 48,
            height: 48,
=======
            width: 72,
            height: 72,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.eco, size: 72, color: AppColors.green);
            },
>>>>>>> register
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Rastriye Krishi',
          style: TextStyle(
<<<<<<< HEAD
            color: tc.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          'Survey Application',
          style: TextStyle(
            color: tc.textSub,
            fontSize: 14,
            fontWeight: FontWeight.w500,
=======
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
>>>>>>> register
          ),
        ),
      ],
    );
  }

<<<<<<< HEAD
  Widget _buildLoginForm(AppThemeColors tc) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: tc.border),
        boxShadow: [
          if (!tc.isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
=======
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
>>>>>>> register
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
<<<<<<< HEAD
          Text(
            'Welcome Back',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: tc.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Login to continue your work',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: tc.textSub),
=======
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
>>>>>>> register
          ),
          
          if (_errorMessage != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
<<<<<<< HEAD
                color: tc.redLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.red.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.red, size: 18),
=======
                color: AppColors.redLight.withValues(alpha: dark ? 0.15 : 1.0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.red, size: 20),
>>>>>>> register
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
<<<<<<< HEAD
          const SizedBox(height: 24),
          _buildTextField(
            label: 'Username',
            controller: _userController,
            hint: 'Enter your username',
            icon: Icons.person_outline,
            tc: tc,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Password',
            controller: _passController,
            hint: '••••••••',
            icon: Icons.lock_outline,
            isPassword: true,
            tc: tc,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: AppColors.green,
              ),
              child: const Text(
                'Forgot Password?',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
=======

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
>>>>>>> register
              ),
            ),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
<<<<<<< HEAD
          const SizedBox(height: 16),
          ElevatedButton(
<<<<<<< HEAD
            onPressed: context.watch<AppState>().isAuthenticating ? null : _handleLogin,
            child: context.watch<AppState>().isAuthenticating
=======

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
>>>>>>> register
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
<<<<<<< HEAD
          const SizedBox(height: 24),
          Center(
            child: Wrap(
=======
            onPressed: _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
>>>>>>> origin/main
              children: [
                Text('Login'),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
=======
          GestureDetector(
            onTap: () => context.push('/register'),
            child: const Text(
              'Register',
              style: TextStyle(
                color: AppColors.green,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
>>>>>>> register
            ),
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required AppThemeColors tc,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: tc.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword && _obscureText,
          style: TextStyle(color: tc.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: tc.textSub),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      size: 20,
                      color: tc.textSub,
                    ),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  )
                : null,
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            filled: true,
            fillColor: tc.isDark ? tc.surfaceVariant : Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: tc.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: tc.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.green, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(AppThemeColors tc) {
    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: () => context.push('/otp'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            side: BorderSide(color: tc.border),
            foregroundColor: tc.textPrimary,
          ),
          icon: const Icon(Icons.phonelink_ring_rounded, size: 18, color: AppColors.green),
          label: const Text('Login with OTP'),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: TextStyle(color: tc.textSub, fontSize: 14),
            ),
            GestureDetector(
              onTap: () {},
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
=======
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
>>>>>>> register
    );
  }
}
