import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/models/complaint.dart';
import 'package:mobile_app/providers/global_auth_provider.dart';
import 'package:mobile_app/services/feed_network_service.dart';
import 'package:mobile_app/views/admin_panel_screen.dart';
import 'package:mobile_app/views/gateway_login_screen.dart';
import 'package:mobile_app/views/national_feed_screen.dart';

/// Root Navigation Switcher for STREET VOICE.
/// Watches [globalAuthProvider] and renders the correct enterprise interface based on RBAC role.
class DashboardOrchestrator extends ConsumerWidget {
  const DashboardOrchestrator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(globalAuthProvider);

    // 1. Guard Check: If unauthenticated, route immediately to GatewayLoginScreen
    if (!state.isAuthenticated || state.role == null) {
      return const GatewayLoginScreen();
    }

    // 2. Strict Dart switch matching state.role to render explicit root interfaces
    switch (state.role!) {
      case UserRole.citizen:
        return const CitizenWorkspaceView();
      case UserRole.government:
        return const MunicipalTelemetryBoardView();
      case UserRole.admin:
        return const AdminPanelScreen();
    }
  }
}

/// ---------------------------------------------------------------------------
/// CITIZEN WORKSPACE VIEW
/// Renders main Citizen interface complete with bottom navigation bar
/// (National Feed, Reported, Account), AI Satire overlays, & hardware shake handlers.
/// ---------------------------------------------------------------------------
class CitizenWorkspaceView extends StatelessWidget {
  const CitizenWorkspaceView({super.key});

  @override
  Widget build(BuildContext context) {
    return const NationalFeedScreen();
  }
}

/// ---------------------------------------------------------------------------
/// MUNICIPAL TELEMETRY BOARD VIEW (Government Entity Root Interface)
/// Features open caseloads and status updates (Review Pending, Dispatched to Municipality)
/// completely stripped of satire overlays in clean Google Stitch Light aesthetics.
/// ---------------------------------------------------------------------------
class MunicipalTelemetryBoardView extends ConsumerWidget {
  const MunicipalTelemetryBoardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(feedNotifierProvider);
    final authState = ref.watch(globalAuthProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF171C20)),
        title: const Row(
          children: [
            Icon(Icons.account_balance_rounded,
                color: Color(0xFF4285F4), size: 22),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'MUNICIPAL TELEMETRY BOARD',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: Color(0xFF171C20),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF6FAFF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF4285F4), width: 1.5),
            ),
            child: Text(
              'RTO SCOPE | ${authState.rtoScope ?? "MH-01"}',
              style: const TextStyle(
                color: Color(0xFF0058BD),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF70757A)),
            tooltip: 'Terminate Municipal Session',
            onPressed: () {
              ref.read(globalAuthProvider.notifier).logout();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildAnalyticalTelemetryHeader(),
            Expanded(
              child: feedAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF4285F4)),
                ),
                error: (err, _) => Center(
                  child: Text(
                    'Failed to load municipal caseloads: $err',
                    style: const TextStyle(color: Color(0xFFEA4335)),
                  ),
                ),
                data: (complaints) {
                  if (complaints.isEmpty) {
                    return const Center(
                      child: Text(
                        'Zero open civic infrastructure defects logged.',
                        style: TextStyle(color: Color(0xFF70757A)),
                      ),
                    );
                  }
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: complaints.length,
                    itemBuilder: (context, index) {
                      return _buildFormalCaseloadCard(complaints[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticalTelemetryHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        border:
            Border(bottom: BorderSide(color: Color(0xFFDEE3E8), width: 1.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTelemetryMetric(
                    'OPEN CASELOADS', '15 ACTIVE', const Color(0xFFB06000)),
              ),
              Expanded(
                child: _buildTelemetryMetric(
                    'AVG DISPATCH TIME', '4.2 HOURS', const Color(0xFF137333)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTelemetryMetric(
                    'AI VISION VERIFIED', '100% PASS', const Color(0xFF0058BD)),
              ),
              Expanded(
                child: _buildTelemetryMetric('SATIRE OVERLAYS',
                    'STRIPPED / DISABLED', const Color(0xFF424753)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryMetric(String label, String val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF70757A),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          val,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  /// Builds formal, high-contrast, light-themed caseload card completely stripped of satire meme overlays
  Widget _buildFormalCaseloadCard(Complaint complaint) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDADCE0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'RTO CODE: ${complaint.rtoCode}',
                      style: const TextStyle(
                        color: Color(0xFF1967D2),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF7E0),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'AI VISION VERIFIED',
                      style: TextStyle(
                        color: Color(0xFFB06000),
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              _buildCaseloadStatusPill(complaint),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            complaint.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF171C20),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            complaint.description,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4C5156),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),

          // Official Municipal Action Row (No satire / No memes)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.assignment_turned_in_rounded,
                    size: 16, color: Color(0xFF137333)),
                label: const Text(
                  'DISPATCH TO MUNICIPALITY',
                  style: TextStyle(
                    color: Color(0xFF137333),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF137333), width: 1.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCaseloadStatusPill(Complaint complaint) {
    String status = 'REVIEW PENDING';
    Color bg = const Color(0xFFFEF7E0);
    Color text = const Color(0xFFB06000);

    if (complaint.upvotes > 2000) {
      status = 'HIGH PRIORITY ESCALATION';
      bg = const Color(0xFFFCE8E6);
      text = const Color(0xFFC5221F);
    } else if (complaint.upvotes > 1000) {
      status = 'DISPATCHED TO MUNICIPALITY';
      bg = const Color(0xFFE6F4EA);
      text = const Color(0xFF137333);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: text.withValues(alpha: 0.35), width: 1.0),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: text,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
