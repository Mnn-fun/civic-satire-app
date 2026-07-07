import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/services/auth_service.dart';
import 'package:mobile_app/views/dashboard_orchestrator.dart';

/// Dark-themed, high-contrast role-selection login screen
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  UserRole _selectedRole = UserRole.citizen;
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  /// Handles auth login and Navigator.pushReplacement routing
  void _handleLogin() {
    setState(() => _errorMessage = '');
    final inputKey = _passwordController.text.trim();

    // 3. If user types master admin override code, dynamically change auth target to admin
    final targetRole = (inputKey == AuthNotifier.adminBackdoorPasscode)
        ? UserRole.admin
        : _selectedRole;

    try {
      final success = ref.read(authProvider.notifier).loginWithRole(
        targetRole,
        masterKey: inputKey,
      );

      if (success && mounted) {
        // 4. Execute a Navigator.pushReplacement routing path to structural orchestrator
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardOrchestrator()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString(), style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B), // Deep corporate dark background (zinc-950)
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Prominent logo block and branding subtitle
                  _buildBrandingHeader(),
                  const SizedBox(height: 36),

                  // 2. Interactive segment choice row framed by neutral gray border blocks
                  _buildRoleSelectorRow(),
                  const SizedBox(height: 24),

                  // 3. Clean optional password entry field for master override
                  _buildPasswordField(),
                  const SizedBox(height: 16),

                  if (_errorMessage.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 4. Heavy text button executing pushReplacement
                  _buildHeavyEnterButton(),
                  const SizedBox(height: 32),

                  // Corporate neutral gray framed system badge
                  _buildSystemFooterBadge(),
                ],
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
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF18181B),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF3F3F46), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE11D48).withValues(alpha: 0.15),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.shield_outlined, color: Color(0xFFE11D48), size: 56),
        ),
        const SizedBox(height: 20),
        const Text(
          'CIVIC INFRASTRUCTURE GRID',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Autonomous AI Verification & Satire Dispatch Portal',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFA1A1AA),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSelectorRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SELECT INGRESS PATHWAY',
          style: TextStyle(
            color: Color(0xFF71717A),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF18181B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF3F3F46), width: 1.2), // Corporate neutral gray border block
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildRolePill(
                  title: 'Citizen Portal',
                  icon: Icons.person_outline_rounded,
                  role: UserRole.citizen,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildRolePill(
                  title: 'Government Ingress',
                  icon: Icons.account_balance_outlined,
                  role: UserRole.government,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRolePill({required String title, required IconData icon, required UserRole role}) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
          _errorMessage = '';
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF27272A) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: const Color(0xFFE11D48), width: 1.5)
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? const Color(0xFFE11D48) : const Color(0xFF71717A),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFFA1A1AA),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'MASTER OVERRIDE CODE',
              style: TextStyle(
                color: Color(0xFF71717A),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              'Optional / Admin Backdoor',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: true,
          style: const TextStyle(color: Colors.white, fontFamily: 'monospace', letterSpacing: 2),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF18181B),
            hintText: 'Leave blank for standard bypass...',
            hintStyle: const TextStyle(color: Color(0xFF52525B), fontSize: 13, fontFamily: 'sans-serif', letterSpacing: 0),
            prefixIcon: const Icon(Icons.key_outlined, color: Color(0xFF71717A), size: 20),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF3F3F46), width: 1.2), // Corporate neutral gray border
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF3F3F46), width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE11D48), width: 1.5),
            ),
          ),
          onChanged: (_) {
            if (_errorMessage.isNotEmpty) {
              setState(() => _errorMessage = '');
            }
          },
          onSubmitted: (_) => _handleLogin(),
        ),
      ],
    );
  }

  Widget _buildHeavyEnterButton() {
    return ElevatedButton(
      onPressed: _handleLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE11D48),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFFF43F5E), width: 1), // Crisp high-contrast frame
        ),
        elevation: 6,
        shadowColor: const Color(0xFFE11D48).withValues(alpha: 0.4),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.login_rounded, size: 20),
          SizedBox(width: 10),
          Text(
            'Enter Secure Infrastructure System',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemFooterBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF27272A), width: 1),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, color: Color(0xFF71717A), size: 14),
          SizedBox(width: 8),
          Text(
            'SYSTEM STATUS: 3 SHARDS ONLINE | TLS 1.3 ENCRYPTED',
            style: TextStyle(
              color: Color(0xFF71717A),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
