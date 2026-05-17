import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Input controllers
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  
  // Selection states
  String? _selectedGender;
  DateTime? _selectedDob;
  
  // Visibility toggles
  bool _obscurePass = true;
  bool _obscureConfirmPass = true;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _selectDob(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final dark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: dark 
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppColors.green,
                    onPrimary: Colors.white,
                    surface: Color(0xFF1A2E1A),
                    onSurface: Color(0xFFE8F5E8),
                  ),
                  dialogTheme: const DialogThemeData(
                    backgroundColor: Color(0xFF112011),
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.green,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: AppColors.textPrimary,
                  ),
                ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDob) {
      setState(() {
        _selectedDob = picked;
      });
    }
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your gender.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    if (_selectedDob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your date of birth.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final dobStr = "${_selectedDob!.year}-${_selectedDob!.month.toString().padLeft(2, '0')}-${_selectedDob!.day.toString().padLeft(2, '0')}";

    final appState = context.read<AppState>();
    final result = await appState.register(
      fullName: _nameController.text.trim(),
      gender: _selectedGender!,
      dateOfBirth: dobStr,
      location: _locationController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passController.text,
    );

    if (result['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Registered successfully! Please login.'),
            backgroundColor: AppColors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/login');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Registration failed.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Create Account',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: dark ? Colors.white : AppColors.textPrimary,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildHeaderCard(dark),
                  const SizedBox(height: 24),
                  _buildSubmitButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(bool dark) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 500),
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
          _buildSectionHeader('Personal Information', Icons.person_outline),
          const SizedBox(height: 16),
          
          // Full Name
          _buildLabel('Full Name'),
          TextFormField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your full name' : null,
            decoration: _buildInputDecoration(hint: 'John Doe', icon: Icons.badge_outlined, dark: dark),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          
          const SizedBox(height: 16),

          // Gender Dropdown (Full Width)
          _buildLabel('Gender'),
          DropdownButtonFormField<String>(
            initialValue: _selectedGender,
            decoration: _buildInputDecoration(
              hint: 'Select your gender',
              icon: Icons.wc_outlined,
              dark: dark,
            ),
            items: ['Male', 'Female', 'Other'].map((String gender) {
              return DropdownMenuItem<String>(
                value: gender,
                child: Text(
                  gender,
                  style: TextStyle(
                    color: dark ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
            dropdownColor: dark ? const Color(0xFF112011) : Colors.white,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            onChanged: (val) => setState(() => _selectedGender = val),
          ),
          
          const SizedBox(height: 16),
          
          // Date of Birth Button (Full Width)
          _buildLabel('Date of Birth'),
          InkWell(
            onTap: () => _selectDob(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF112011) : AppColors.bg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: dark ? const Color(0xFF2A3F2A) : AppColors.border,
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, color: AppColors.textSub, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedDob == null
                          ? 'Select your date of birth'
                          : "${_selectedDob!.year}-${_selectedDob!.month.toString().padLeft(2, '0')}-${_selectedDob!.day.toString().padLeft(2, '0')}",
                      style: TextStyle(
                        color: _selectedDob == null ? AppColors.textMuted : (dark ? Colors.white : AppColors.textPrimary),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // District/Location
          _buildLabel('District / Location'),
          TextFormField(
            controller: _locationController,
            textInputAction: TextInputAction.next,
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your location' : null,
            decoration: _buildInputDecoration(hint: 'Kathmandu', icon: Icons.map_outlined, dark: dark),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),

          const SizedBox(height: 28),
          _buildSectionHeader('Contact Information', Icons.mail_outline),
          const SizedBox(height: 16),

          // Email
          _buildLabel('Email Address'),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Please enter your email';
              final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!regex.hasMatch(val.trim())) return 'Please enter a valid email';
              return null;
            },
            decoration: _buildInputDecoration(hint: 'name@example.com', icon: Icons.alternate_email, dark: dark),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),

          const SizedBox(height: 16),

          // Phone
          _buildLabel('Phone Number'),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Please enter your phone number';
              if (val.trim().length != 10 || !RegExp(r'^\d+$').hasMatch(val.trim())) {
                return 'Please enter a valid 10-digit number';
              }
              return null;
            },
            decoration: _buildInputDecoration(hint: '98XXXXXXXX', icon: Icons.phone_android_outlined, dark: dark),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),

          const SizedBox(height: 28),
          _buildSectionHeader('Security Information', Icons.security),
          const SizedBox(height: 16),

          // Password
          _buildLabel('Password'),
          TextFormField(
            controller: _passController,
            obscureText: _obscurePass,
            textInputAction: TextInputAction.next,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Please enter a password';
              if (val.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
            decoration: _buildInputDecoration(
              hint: '••••••••',
              icon: Icons.lock_outline,
              dark: dark,
              suffix: IconButton(
                icon: Icon(
                  _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textSub,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              ),
            ),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),

          const SizedBox(height: 16),

          // Confirm Password
          _buildLabel('Confirm Password'),
          TextFormField(
            controller: _confirmPassController,
            obscureText: _obscureConfirmPass,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleRegister(),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Please confirm your password';
              if (val != _passController.text) return 'Passwords do not match';
              return null;
            },
            decoration: _buildInputDecoration(
              hint: '••••••••',
              icon: Icons.lock_outline,
              dark: dark,
              suffix: IconButton(
                icon: Icon(
                  _obscureConfirmPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textSub,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureConfirmPass = !_obscureConfirmPass),
              ),
            ),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final appState = context.watch<AppState>();

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 500),
      child: ElevatedButton(
        onPressed: appState.isAuthenticating ? null : _handleRegister,
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
                    'Register Account',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.person_add_alt_1_outlined, size: 20),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.green, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.green,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 13,
          color: AppColors.textSub,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    required bool dark,
    Widget? suffix,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return InputDecoration(
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 12, right: 8),
        child: Icon(icon, color: AppColors.textSub, size: 20),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 20),
      suffixIcon: suffix,
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.w500),
      filled: true,
      fillColor: dark ? const Color(0xFF112011) : AppColors.bg,
      contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      errorStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
    );
  }
}
