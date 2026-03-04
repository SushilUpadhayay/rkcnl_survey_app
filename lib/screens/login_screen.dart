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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHero(),
              _buildLoginForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.4,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.green,
            image: DecorationImage(
              image: AssetImage(
                  'assets/images/photo-1523348837708-15d4a09cfac2.jpg'),
              fit: BoxFit.cover,
              opacity: 0.4,
            ),
          ),
        ),
        Positioned(
          top: 64,
          left: 24,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  'assets/images/Krishi_Logo-Tr.png',
                  width: 24,
                  height: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Rastriye Krishi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 24,
          left: 24,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white12,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: Image.asset(
              'assets/images/Krishi_Logo-Tr.png',
              width: 40,
              height: 40,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    final tc = context.appColors;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Back',
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: tc.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Log in to start your field survey',
            style: TextStyle(fontSize: 16, color: tc.textSub),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: tc.redLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.red, size: 20),
                  const SizedBox(width: 8),
                  Text(_errorMessage!,
                      style: const TextStyle(
                          color: AppColors.red, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
          Text('Phone number or Username',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: tc.textPrimary)),
          const SizedBox(height: 8),
          TextField(
            controller: _userController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.person_outline),
              hintText: 'Enter your credentials',
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Password',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: tc.textPrimary)),
              TextButton(
                onPressed: () {},
                child: const Text('Forgot password?',
                    style: TextStyle(
                        color: AppColors.green,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
              ),
            ],
          ),
          TextField(
            controller: _passController,
            obscureText: _obscureText,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    size: 20),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              ),
              hintText: '••••••••',
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _handleLogin,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Login'),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('OR',
                    style: TextStyle(
                        color: tc.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => context.push('/otp'),
            icon: const Icon(Icons.vibration, size: 20),
            label: const Text('Login with OTP'),
          ),
          const SizedBox(height: 32),
          Center(
            child: Wrap(
              children: [
                Text("Don't have an account? ",
                    style: TextStyle(color: tc.textSub)),
                GestureDetector(
                  onTap: () {},
                  child: const Text('Register',
                      style: TextStyle(
                          color: AppColors.green, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
