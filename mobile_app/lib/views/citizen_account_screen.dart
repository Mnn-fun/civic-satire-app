import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/providers/global_auth_provider.dart';
import 'package:mobile_app/services/auth_service.dart' hide UserRole;
import 'package:mobile_app/views/complaint_card.dart';
import 'package:mobile_app/views/gateway_login_screen.dart';

/// Production-ready CitizenAccountScreen widget matching the exact
/// light-themed Google Stitch UI aesthetics of STREET VOICE (#FFFFFF background,
/// 8dp borders, explicit vertical spacing dividers).
class CitizenAccountScreen extends ConsumerStatefulWidget {
  final bool showAppBar;

  const CitizenAccountScreen({super.key, this.showAppBar = true});

  @override
  ConsumerState<CitizenAccountScreen> createState() =>
      _CitizenAccountScreenState();
}

class _CitizenAccountScreenState extends ConsumerState<CitizenAccountScreen> {
  static const List<String> _rtoOptions = [
    'MH-01',
    'MH-02',
    'DL-01',
    'GJ-01',
    'KA-01',
    'TN-01',
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(globalAuthProvider);
    final isSatireMode = ref.watch(satireModeProvider);

    final currentRto = authState.rtoScope ?? 'MH-01';
    final selectedRto = _rtoOptions.contains(currentRto) ? currentRto : 'MH-01';
    final userEmail = authState.email ?? 'citizen@streetvoice.in';
    final userName = userEmail.contains('@')
        ? _formatUsername(userEmail.split('@').first)
        : 'Citizen Explorer';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
              iconTheme: const IconThemeData(color: Color(0xFF171C20)),
              title: const Row(
                children: [
                  Icon(
                    Icons.person_pin_circle_rounded,
                    color: Color(0xFF4285F4),
                    size: 24,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Citizen Portal Account',
                    style: TextStyle(
                      color: Color(0xFF171C20),
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. USER PROFILE HEADER
              _buildProfileHeader(
                userName: userName,
                email: userEmail,
                rtoScope: currentRto,
              ),

              const SizedBox(height: 24), // Vertical Spacing Divider
              // 2. INTERACTIVE FEATURE PREFERENCE ROW (AI Satire Overlay Engine)
              _buildSatirePreferenceRow(
                isSatireMode: isSatireMode,
                onToggle: (val) =>
                    ref.read(satireModeProvider.notifier).setSatireMode(val),
              ),

              const SizedBox(height: 14), // Vertical Spacing Divider
              // Passive Diagnostic Row (Hardware Shaker Handshake)
              _buildDiagnosticStatusRow(),

              const SizedBox(height: 28), // Vertical Spacing Divider
              // 3. DYNAMIC REGIONAL RTO DROPDOWN MODIFIER
              _buildRtoDropdownModifier(
                selectedRto: selectedRto,
                onChanged: (newRto) {
                  if (newRto != null) {
                    ref
                        .read(globalAuthProvider.notifier)
                        .updateRtoScope(newRto);
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Primary jurisdiction updated to RTO Zone: $newRto',
                        ),
                        backgroundColor: const Color(0xFF171C20),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 36), // Vertical Spacing Divider
              // 4. ACTION TERMINAL (Sign Out of Citizen Portal)
              _buildActionTerminal(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper to format raw email prefixes into readable human display names
  String _formatUsername(String rawName) {
    if (rawName.isEmpty) return 'Citizen Explorer';
    final parts = rawName
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), ' ')
        .trim()
        .split(RegExp(r'\s+'));
    return parts
        .where((p) => p.isNotEmpty)
        .map((p) => '${p[0].toUpperCase()}${p.substring(1).toLowerCase()}')
        .join(' ');
  }

  Widget _buildProfileHeader({
    required String userName,
    required String email,
    required String rtoScope,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF6FAFF), // Breathable light Google surface
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4285F4), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF4285F4).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFF0058BD),
              size: 36,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4285F4).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ACTIVE CITIZEN PORTAL',
                    style: TextStyle(
                      color: Color(0xFF0058BD),
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Color(0xFF171C20),
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  email,
                  style: const TextStyle(
                    color: Color(0xFF424753),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF4285F4)),
                  ),
                  child: Text(
                    'RTO Zone: $rtoScope',
                    style: const TextStyle(
                      color: Color(0xFF0058BD),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSatirePreferenceRow({
    required bool isSatireMode,
    required ValueChanged<bool> onToggle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDEE3E8), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 18,
                      color: Color(0xFFEA4335),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'AI Satire Overlay Engine',
                      style: TextStyle(
                        color: Color(0xFF171C20),
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  'When enabled, double-tap or hardware shake activates satirical Ghibli macro captions on civic issues.',
                  style: TextStyle(
                    color: Color(0xFF70757A),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: isSatireMode,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFFEA4335),
            inactiveThumbColor: const Color(0xFF70757A),
            inactiveTrackColor: const Color(0xFFE2E8F0),
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticStatusRow() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDEE3E8), width: 1.0),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.wifi_tethering_rounded,
            color: Color(0xFF34A853), // Green wireless wave icon
            size: 22,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hardware Shaker Handshake',
                  style: TextStyle(
                    color: Color(0xFF171C20),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Active (Sensors+ Accelerometer Stream Online)',
                  style: TextStyle(
                    color: Color(0xFF137333),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRtoDropdownModifier({
    required String selectedRto,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDEE3E8), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.map_rounded, size: 18, color: Color(0xFF4285F4)),
              SizedBox(width: 8),
              Text(
                'Dynamic Regional RTO Modifier',
                style: TextStyle(
                  color: Color(0xFF171C20),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Alter your primary regional jurisdiction to view and report municipal infrastructure defects.',
            style: TextStyle(
              color: Color(0xFF70757A),
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: selectedRto,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF70757A),
            ),
            style: const TextStyle(
              color: Color(0xFF171C20),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              labelText: 'Primary Regional Jurisdiction',
              labelStyle: const TextStyle(
                color: Color(0xFF424753),
                fontSize: 13,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDEE3E8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDEE3E8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF4285F4),
                  width: 1.5,
                ),
              ),
            ),
            items: _rtoOptions.map((rto) {
              String labelName;
              switch (rto) {
                case 'MH-01':
                  labelName = 'MH-01 — Mumbai South Zone';
                  break;
                case 'MH-02':
                  labelName = 'MH-02 — Mumbai West Zone';
                  break;
                case 'DL-01':
                  labelName = 'DL-01 — Delhi Central Zone';
                  break;
                case 'GJ-01':
                  labelName = 'GJ-01 — Ahmedabad Zone';
                  break;
                case 'KA-01':
                  labelName = 'KA-01 — Bengaluru Central';
                  break;
                case 'TN-01':
                  labelName = 'TN-01 — Chennai Central';
                  break;
                default:
                  labelName = '$rto — Regional Zone';
              }
              return DropdownMenuItem<String>(
                value: rto,
                child: Text(labelName),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTerminal() {
    return OutlinedButton.icon(
      onPressed: () {
        ref.read(globalAuthProvider.notifier).logout();
        ref.read(authProvider.notifier).logout();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const GatewayLoginScreen()),
          (route) => false,
        );
      },
      icon: const Icon(
        Icons.logout_rounded,
        size: 20,
        color: Color(0xFFEA4335),
      ),
      label: const Text(
        'Sign Out of Citizen Portal',
        style: TextStyle(
          color: Color(0xFFEA4335),
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFFEA4335), width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Color.fromARGB(255, 255, 223, 220),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
