import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/services/auth_service.dart';
import 'package:mobile_app/services/global_session_service.dart';
import 'package:mobile_app/views/citizen_registration_screen.dart';
import 'package:mobile_app/views/dashboard_orchestrator.dart';

/// Active segment mode for gateway authentication
enum GatewayAuthMode {
  citizen,
  government,
  admin,
}

/// Production-ready Material 3 Gateway Login Screen featuring multi-role ingress,
/// rigorous validation handling, and backdoor administrative access.
class GatewayLoginScreen extends ConsumerStatefulWidget {
  const GatewayLoginScreen({super.key});

  @override
  ConsumerState<GatewayLoginScreen> createState() => _GatewayLoginScreenState();
}

class _GatewayLoginScreenState extends ConsumerState<GatewayLoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  GatewayAuthMode _currentMode = GatewayAuthMode.citizen;
  bool _obscurePassword = true;
  bool _showAdminBackdoor = false;
  String? _localValidationMessage;

  // Citizen credentials
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Municipal Officer credentials
  final _officeIdController = TextEditingController();
  final _govPasscodeController = TextEditingController();

  // Admin Terminal backdoor credentials
  final _masterIdController = TextEditingController();
  final _systemSignatureController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _officeIdController.dispose();
    _govPasscodeController.dispose();
    _masterIdController.dispose();
    _systemSignatureController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _switchMode(GatewayAuthMode mode) {
    setState(() {
      _currentMode = mode;
      _localValidationMessage = null;
    });
    _animationController.reset();
    _animationController.forward();
  }

  void _toggleAdminBackdoor() {
    setState(() {
      _showAdminBackdoor = !_showAdminBackdoor;
      if (_showAdminBackdoor) {
        _currentMode = GatewayAuthMode.admin;
      } else {
        _currentMode = GatewayAuthMode.citizen;
      }
      _localValidationMessage = null;
    });
    _animationController.reset();
    _animationController.forward();
  }

  /// Validates email formatting against rigorous RFC 5322 regex
  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  /// Executes login through GlobalAuthNotifier and synchronizes with legacy routing state
  Future<void> _handleAuthentication() async {
    setState(() => _localValidationMessage = null);

    // Enforce form field validators (prevent zero-character submissions)
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final globalAuth = ref.read(globalSessionProvider.notifier);
    final legacyAuth = ref.read(authProvider.notifier);
    bool success = false;

    try {
      switch (_currentMode) {
        case GatewayAuthMode.citizen:
          final email = _emailController.text.trim();
          final pass = _passwordController.text.trim();
          if (!_isValidEmail(email)) {
            setState(() => _localValidationMessage = 'Validation Error: Please enter a valid email pattern.');
            return;
          }
          success = await globalAuth.authenticateUser(email, pass);
          if (success) {
            legacyAuth.loginWithRole(UserRole.citizen);
          }
          break;

        case GatewayAuthMode.government:
          final officeId = _officeIdController.text.trim();
          final passcode = _govPasscodeController.text.trim();
          success = await globalAuth.authenticateGovernmentEntity(officeId, passcode);
          if (success) {
            legacyAuth.loginWithRole(UserRole.government);
          }
          break;

        case GatewayAuthMode.admin:
          final masterId = _masterIdController.text.trim();
          final signature = _systemSignatureController.text.trim();
          success = await globalAuth.authenticateAdmin(masterId, signature);
          if (success) {
            legacyAuth.loginWithRole(UserRole.admin, masterKey: AuthNotifier.adminBackdoorPasscode);
          }
          break;
      }

      if (success && mounted) {
        // Smooth Material 3 transition to core dashboard orchestrator
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (context, animation, secondaryAnimation) => const DashboardOrchestrator(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                  ),
                  child: child,
                ),
              );
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _localValidationMessage = e.toString());
      }
    }
  }

  /// Triggers smooth animated transition to Citizen Registration Screen
  void _navigateToRegistration() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) => const CitizenRegistrationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic));
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(globalSessionProvider);
    final isBusy = sessionState.IsLoading;
    final activeError = _localValidationMessage ?? sessionState.ErrorMessage;

    return Scaffold(
      backgroundColor: const Color(0xFF09090B), // Material 3 deep dark zinc background
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Branding Title and Secret Admin Backdoor Trigger
                    _buildBrandingHeader(),
                    const SizedBox(height: 32),

                    // 2. Segment Layout Selector (Citizen vs Government)
                    if (!_showAdminBackdoor) _buildSegmentSelector(),
                    if (_showAdminBackdoor) _buildAdminTerminalBanner(),
                    const SizedBox(height: 28),

                    // 3. Animated Credentials Form Content
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildFormContent(isBusy),
                    ),
                    const SizedBox(height: 20),

                    // 4. Error Message Alert Banner
                    if (activeError != null && activeError.isNotEmpty) _buildErrorBanner(activeError),
                    if (activeError != null && activeError.isNotEmpty) const SizedBox(height: 16),

                    // 5. Submit Action Button
                    _buildSubmitButton(isBusy),
                    const SizedBox(height: 24),

                    // 6. Navigation Link to Citizen Registration
                    if (_currentMode == GatewayAuthMode.citizen) _buildRegistrationLink(),

                    // 7. Hidden System Override Backdoor Link
                    const SizedBox(height: 16),
                    _buildBackdoorFooterLink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandingHeader() {
    return Column(
      children: [
        GestureDetector(
          onDoubleTap: _toggleAdminBackdoor, // Double tap secret trigger
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _currentMode == GatewayAuthMode.admin
                    ? [const Color(0xFFE11D48), const Color(0xFF881337)]
                    : (_currentMode == GatewayAuthMode.government
                        ? [const Color(0xFF3B82F6), const Color(0xFF1E3A8A)]
                        : [const Color(0xFF10B981), const Color(0xFF047857)]),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (_currentMode == GatewayAuthMode.admin
                          ? const Color(0xFFE11D48)
                          : (_currentMode == GatewayAuthMode.government ? const Color(0xFF3B82F6) : const Color(0xFF10B981)))
                      .withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              _currentMode == GatewayAuthMode.admin
                  ? Icons.admin_panel_settings_rounded
                  : (_currentMode == GatewayAuthMode.government ? Icons.account_balance_rounded : Icons.public_rounded),
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          _currentMode == GatewayAuthMode.admin
              ? 'ADMINISTRATIVE TERMINAL'
              : (_currentMode == GatewayAuthMode.government ? 'MUNICIPAL OFFICER INGRESS' : 'CIVIC SATIRE PORTAL'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _currentMode == GatewayAuthMode.admin
              ? 'Classified Core Shard & Database Override Access'
              : (_currentMode == GatewayAuthMode.government
                  ? 'Authorized Regional RTO Personnel Access Only'
                  : 'Crowdsourced Civic Hazard Documentation & Satire Feed'),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildSegmentSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF27272A), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSegmentButton(
              title: 'Citizen Portal',
              icon: Icons.person_rounded,
              isSelected: _currentMode == GatewayAuthMode.citizen,
              activeColor: const Color(0xFF10B981),
              onTap: () => _switchMode(GatewayAuthMode.citizen),
            ),
          ),
          Expanded(
            child: _buildSegmentButton(
              title: 'Officer Ingress',
              icon: Icons.badge_rounded,
              isSelected: _currentMode == GatewayAuthMode.government,
              activeColor: const Color(0xFF3B82F6),
              onTap: () => _switchMode(GatewayAuthMode.government),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? activeColor : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? activeColor : const Color(0xFF71717A)),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFFA1A1AA),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminTerminalBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE11D48).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE11D48), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFE11D48), size: 22),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'SECURITY WARNING: Unauthorized access to Administrative Terminals is strictly audited.',
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            onPressed: _toggleAdminBackdoor,
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
            tooltip: 'Exit Backdoor Mode',
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent(bool isBusy) {
    switch (_currentMode) {
      case GatewayAuthMode.citizen:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLabel('Email Address'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _emailController,
              enabled: !isBusy,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
              decoration: _buildInputDecoration(hintText: 'citizen@municipality.org', icon: Icons.email_outlined),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Email is required';
                if (!_isValidEmail(val.trim())) return 'Enter a valid email address';
                return null;
              },
            ),
            const SizedBox(height: 18),
            _buildLabel('Password'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _passwordController,
              enabled: !isBusy,
              obscureText: _obscurePassword,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInputDecoration(
                hintText: '••••••••••••',
                icon: Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF71717A)),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Password cannot be zero-characters';
                if (val.trim().length < 6) return 'Password must be at least 6 characters';
                return null;
              },
            ),
          ],
        );

      case GatewayAuthMode.government:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLabel('Municipal Office ID (e.g., MH-01, GJ-01, DL-01)'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _officeIdController,
              enabled: !isBusy,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 1),
              textCapitalization: TextCapitalization.characters,
              decoration: _buildInputDecoration(hintText: 'MH-01-HQ', icon: Icons.account_balance_outlined),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Office ID is required';
                return null;
              },
            ),
            const SizedBox(height: 18),
            _buildLabel('Government Passcode'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _govPasscodeController,
              enabled: !isBusy,
              obscureText: _obscurePassword,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInputDecoration(
                hintText: 'Enter regional officer code',
                icon: Icons.vpn_key_outlined,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF71717A)),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Government passcode required';
                return null;
              },
            ),
          ],
        );

      case GatewayAuthMode.admin:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLabel('Master Administrator ID'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _masterIdController,
              enabled: !isBusy,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              decoration: _buildInputDecoration(hintText: 'ROOT_SYS_ADMIN', icon: Icons.shield_outlined),
              validator: (val) => val == null || val.trim().isEmpty ? 'Master ID cannot be empty' : null,
            ),
            const SizedBox(height: 18),
            _buildLabel('System Override Signature'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _systemSignatureController,
              enabled: !isBusy,
              obscureText: _obscurePassword,
              style: const TextStyle(color: Color(0xFFE11D48), fontWeight: FontWeight.w800, letterSpacing: 2),
              decoration: _buildInputDecoration(
                hintText: 'Enter backdoor signature (ADMIN777)',
                icon: Icons.key_rounded,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF71717A)),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'System signature required' : null,
            ),
          ],
        );
    }
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 13, fontWeight: FontWeight.w600),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF18181B),
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF52525B), fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF71717A), size: 20),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3F3F46), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3F3F46), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: _currentMode == GatewayAuthMode.admin
              ? const Color(0xFFE11D48)
              : (_currentMode == GatewayAuthMode.government ? const Color(0xFF3B82F6) : const Color(0xFF10B981)),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(bool isBusy) {
    final activeColor = _currentMode == GatewayAuthMode.admin
        ? const Color(0xFFE11D48)
        : (_currentMode == GatewayAuthMode.government ? const Color(0xFF3B82F6) : const Color(0xFF10B981));

    return ElevatedButton(
      onPressed: isBusy ? null : _handleAuthentication,
      style: ElevatedButton.styleFrom(
        backgroundColor: activeColor,
        disabledBackgroundColor: activeColor.withValues(alpha: 0.5),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
        shadowColor: activeColor.withValues(alpha: 0.4),
      ),
      child: isBusy
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _currentMode == GatewayAuthMode.admin
                      ? Icons.admin_panel_settings
                      : (_currentMode == GatewayAuthMode.government ? Icons.login_rounded : Icons.arrow_forward_rounded),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  _currentMode == GatewayAuthMode.admin
                      ? 'EXECUTE ROOT INGRESS'
                      : (_currentMode == GatewayAuthMode.government ? 'ENTER OFFICER TERMINAL' : 'ENTER CITIZEN PORTAL'),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.8),
                ),
              ],
            ),
    );
  }

  Widget _buildRegistrationLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'New to Civic Satire? ',
          style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 14),
        ),
        GestureDetector(
          onTap: _navigateToRegistration,
          child: const Text(
            'Create Citizen Account →',
            style: TextStyle(
              color: Color(0xFF10B981),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackdoorFooterLink() {
    return Center(
      child: GestureDetector(
        onTap: _toggleAdminBackdoor,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF18181B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF27272A)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _showAdminBackdoor ? Icons.shield_outlined : Icons.key_off_outlined,
                color: _showAdminBackdoor ? const Color(0xFFE11D48) : const Color(0xFF71717A),
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                _showAdminBackdoor ? 'Return to Standard Ingress' : '🔐 System Override: Administrative Terminal Ingress',
                style: TextStyle(
                  color: _showAdminBackdoor ? const Color(0xFFE11D48) : const Color(0xFF71717A),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
