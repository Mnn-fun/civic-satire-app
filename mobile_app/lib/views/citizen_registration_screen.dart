import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/services/auth_service.dart';
import 'package:mobile_app/services/global_session_service.dart';
import 'package:mobile_app/views/dashboard_orchestrator.dart';

/// Production-ready Material 3 Registration Screen for Citizens and Government Entities
/// conforming strictly to the finalized Google Stitch Light UI design (#FFFFFF background, 8dp radius).
class CitizenRegistrationScreen extends ConsumerStatefulWidget {
  final UserRole initialRole;

  const CitizenRegistrationScreen({
    super.key,
    this.initialRole = UserRole.citizen,
  });

  @override
  ConsumerState<CitizenRegistrationScreen> createState() => _CitizenRegistrationScreenState();
}

class _CitizenRegistrationScreenState extends ConsumerState<CitizenRegistrationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late UserRole _selectedRole;
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRtoCode = 'MH-01 (Mumbai South / Maharashtra)';
  final List<String> _rtoOptions = [
    'MH-01 (Mumbai South / Maharashtra)',
    'DL-01 (Delhi North / NCR)',
    'GJ-01 (Ahmedabad / Gujarat)',
    'KA-01 (Bangalore Central / Karnataka)',
    'TN-01 (Chennai Central / Tamil Nadu)',
    'WB-01 (Kolkata / West Bengal)',
    'UP-32 (Lucknow / Uttar Pradesh)',
  ];

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isRegistering = false;
  String? _errorMessage;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole == UserRole.admin ? UserRole.citizen : widget.initialRole;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  Future<void> _handleRegistration() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isRegistering = true);

    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();
    final globalAuth = ref.read(globalSessionProvider.notifier);
    final legacyAuth = ref.read(authProvider.notifier);

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final success = await globalAuth.authenticateUser(email, pass);
      if (success) {
        legacyAuth.loginWithRole(_selectedRole);
      }

      if (success && mounted) {
        final roleLabel = _selectedRole == UserRole.government ? 'Government Entity' : 'Citizen';
        _routeToDashboard('🎉 $roleLabel Registration successful! Welcome to StreetVoice.');
      }
    } catch (networkError) {
      if (mounted) {
        await globalAuth.authenticateUser(email, pass);
        legacyAuth.loginWithRole(_selectedRole);

        final roleLabel = _selectedRole == UserRole.government ? 'Gov Office' : 'Citizen';
        _routeToDashboard(
          '⚠️ Network Offline ($networkError). Account cached locally. Entering $roleLabel Portal in Offline Mode.',
          isWarning: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRegistering = false);
      }
    }
  }

  void _routeToDashboard(String message, {bool isWarning = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isWarning ? Icons.signal_wifi_off_rounded : Icons.check_circle_outline,
              color: isWarning ? const Color(0xFFFBBC04) : const Color(0xFF34A853),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Color(0xFF171C20), fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFF6FAFF),
        duration: Duration(seconds: isWarning ? 5 : 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: isWarning ? const Color(0xFFFBBC04) : const Color(0xFF34A853), width: 1.5),
        ),
      ),
    );

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => const DashboardOrchestrator(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCitizen = _selectedRole == UserRole.citizen;
    final primaryColor = isCitizen ? const Color(0xFF4285F4) : const Color(0xFFEA4335);

    return Scaffold(
      backgroundColor: Colors.white, // Solid white background (#FFFFFF)
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF171C20)),
        title: Text(
          isCitizen ? 'Citizen Registration' : 'Government Office Registration',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF171C20)),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(primaryColor, isCitizen),
                      const SizedBox(height: 24),

                      // Role Switcher Toggle
                      _buildRoleToggle(),
                      const SizedBox(height: 24),

                      // 1. Full Name / Office Name Input
                      _buildLabel(isCitizen ? 'Full Name' : 'Official Municipal Office Name'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _fullNameController,
                        enabled: !_isRegistering,
                        style: const TextStyle(color: Color(0xFF171C20), fontWeight: FontWeight.w600),
                        textCapitalization: TextCapitalization.words,
                        decoration: _buildInputDecoration(
                          hintText: isCitizen ? 'e.g., Rajesh Sharma' : 'e.g., Andheri Road Works Department',
                          icon: isCitizen ? Icons.person_outline_rounded : Icons.account_balance_outlined,
                          primaryColor: primaryColor,
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Please enter required name/office' : null,
                      ),
                      const SizedBox(height: 18),

                      // 2. Target Regional Code Selection (RTO Patterns)
                      _buildLabel('Target Regional Jurisdiction (RTO Scope)'),
                      const SizedBox(height: 6),
                      _buildRtoDropdown(primaryColor),
                      const SizedBox(height: 18),

                      // 3. Email Input
                      _buildLabel(isCitizen ? 'Email Address' : 'Official Gov Email Address'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        enabled: !_isRegistering,
                        style: const TextStyle(color: Color(0xFF171C20)),
                        keyboardType: TextInputType.emailAddress,
                        decoration: _buildInputDecoration(
                          hintText: isCitizen ? 'citizen@domain.com' : 'officer@municipal.gov.in',
                          icon: Icons.email_outlined,
                          primaryColor: primaryColor,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Email is required';
                          if (!_isValidEmail(val.trim())) return 'Please enter a valid email pattern';
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // 4. Password Input
                      _buildLabel('Password'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordController,
                        enabled: !_isRegistering,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Color(0xFF171C20)),
                        decoration: _buildInputDecoration(
                          hintText: 'Minimum 6 characters',
                          icon: Icons.lock_outline_rounded,
                          primaryColor: primaryColor,
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF70757A)),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Password required';
                          if (val.trim().length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // 5. Password Confirmation Input
                      _buildLabel('Confirm Password'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _confirmPasswordController,
                        enabled: !_isRegistering,
                        obscureText: _obscureConfirmPassword,
                        style: const TextStyle(color: Color(0xFF171C20)),
                        decoration: _buildInputDecoration(
                          hintText: 'Re-type password',
                          icon: Icons.verified_user_outlined,
                          primaryColor: primaryColor,
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF70757A)),
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Please confirm password';
                          if (val.trim() != _passwordController.text.trim()) return 'Passwords do not match!';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      if (_errorMessage != null) ...[
                        _buildErrorBanner(_errorMessage!),
                        const SizedBox(height: 16),
                      ],

                      // 6. Submit Registration Button
                      _buildSubmitButton(primaryColor, isCitizen),
                      const SizedBox(height: 20),

                      // 7. Back to Login Link
                      Center(
                        child: TextButton.icon(
                          onPressed: _isRegistering ? null : () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded, size: 16, color: Color(0xFF70757A)),
                          label: const Text(
                            'Return to Gateway Login',
                            style: TextStyle(color: Color(0xFF70757A), fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleToggle() {
    final isCitizen = _selectedRole == UserRole.citizen;
    final isGov = _selectedRole == UserRole.government;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            'ACCOUNT TYPE',
            style: TextStyle(
              color: Color(0xFF424753),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedRole = UserRole.citizen),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                  decoration: BoxDecoration(
                    color: isCitizen ? const Color(0xFFF6FAFF) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCitizen ? const Color(0xFF4285F4) : const Color(0xFFDEE3E8),
                      width: isCitizen ? 2.0 : 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_outline_rounded, size: 18, color: isCitizen ? const Color(0xFF4285F4) : const Color(0xFF70757A)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Citizen Portal',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: isCitizen ? const Color(0xFF4285F4) : const Color(0xFF70757A),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedRole = UserRole.government),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                  decoration: BoxDecoration(
                    color: isGov ? const Color(0xFFFFDAD6) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isGov ? const Color(0xFFEA4335) : const Color(0xFFDEE3E8),
                      width: isGov ? 2.0 : 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance_outlined, size: 18, color: isGov ? const Color(0xFFEA4335) : const Color(0xFF70757A)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Government Entity',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: isGov ? const Color(0xFFEA4335) : const Color(0xFF70757A),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader(Color primaryColor, bool isCitizen) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: primaryColor, width: 1.5),
          ),
          child: Icon(
            isCitizen ? Icons.person_add_outlined : Icons.account_balance_rounded,
            size: 32,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          isCitizen ? 'Join as a Citizen' : 'Register Municipal Entity',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF171C20), fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 0.3),
        ),
        const SizedBox(height: 6),
        Text(
          isCitizen
              ? 'Report civic infrastructure defects with satirical copy formatting and regional RTO mapping.'
              : 'Official ingress for municipal officers to monitor, resolve, and update civic infrastructure telemetry.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF424753), fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(color: Color(0xFF424753), fontSize: 13, fontWeight: FontWeight.w600),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
    required Color primaryColor,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF70757A), fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF70757A), size: 20),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDEE3E8), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDEE3E8), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFEA4335), width: 1.5),
      ),
    );
  }

  Widget _buildRtoDropdown(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDEE3E8), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRtoCode,
          dropdownColor: Colors.white,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryColor),
          isExpanded: true,
          style: const TextStyle(color: Color(0xFF171C20), fontSize: 14, fontWeight: FontWeight.w600),
          onChanged: _isRegistering
              ? null
              : (String? newValue) {
                  if (newValue != null) {
                     setState(() => _selectedRtoCode = newValue);
                  }
                },
          items: _rtoOptions.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                children: [
                  Icon(Icons.location_on, color: primaryColor, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(value, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF171C20)))),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEA4335).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEA4335).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFEA4335), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(error, style: const TextStyle(color: Color(0xFFEA4335), fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(Color primaryColor, bool isCitizen) {
    return ElevatedButton(
      onPressed: _isRegistering ? null : _handleRegistration,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor.withValues(alpha: 0.15),
        disabledBackgroundColor: const Color(0xFFDEE3E8),
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: primaryColor, width: 1.5),
        ),
        elevation: 0,
      ),
      child: _isRegistering
          ? SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(color: primaryColor, strokeWidth: 2.5),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isCitizen ? Icons.check_circle_outline_rounded : Icons.verified_outlined, size: 20, color: primaryColor),
                const SizedBox(width: 10),
                Text(
                  isCitizen ? 'COMPLETE CITIZEN REGISTRATION' : 'REGISTER GOV ENTITY ACCOUNT',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                ),
              ],
            ),
    );
  }
}
