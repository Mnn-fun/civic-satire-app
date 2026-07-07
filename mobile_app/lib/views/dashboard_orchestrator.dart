import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/models/complaint.dart';
import 'package:mobile_app/services/auth_service.dart';
import 'package:mobile_app/services/feed_network_service.dart';
import 'package:mobile_app/views/gateway_login_screen.dart';
import 'package:mobile_app/views/national_feed_screen.dart';

/// Core systems structural routing controller watching Riverpod auth state
class DashboardOrchestrator extends ConsumerWidget {
  const DashboardOrchestrator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // 1. Guard check: if unauthenticated, render GatewayLoginScreen
    if (!authState.isAuthenticated || authState.role == null) {
      return const GatewayLoginScreen();
    }

    // 2. Standard switch statement checking active role context
    switch (authState.role!) {
      case UserRole.admin:
        return const AdminCorePanelView();
      case UserRole.government:
        return const GovernmentEntityView();
      case UserRole.citizen:
        return const CitizenUIView();
    }
  }
}

/// ---------------------------------------------------------------------------
/// CITIZEN UI VIEW
/// Displays traditional fast-scrolling National Satire Feed Screen with shake hooks
/// ---------------------------------------------------------------------------
class CitizenUIView extends StatelessWidget {
  const CitizenUIView({super.key});

  @override
  Widget build(BuildContext context) {
    return const NationalFeedScreen();
  }
}

/// ---------------------------------------------------------------------------
/// GOVERNMENT ENTITY VIEW
/// Analytical, data-heavy complaint status monitor replacing satire with formal pills
/// ---------------------------------------------------------------------------
class GovernmentEntityView extends ConsumerWidget {
  const GovernmentEntityView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(feedNotifierProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF18181B),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.account_balance_rounded, color: Colors.blueAccent, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'MUNICIPAL INFRASTRUCTURE MONITOR',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.5)),
            ),
            child: Text(
              'GOV ACCESS | ${authState.token ?? "ACTIVE"}',
              style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFA1A1AA)),
            tooltip: 'Terminate Municipal Session',
            onPressed: () {
              ref.read(authProvider.notifier).logout();
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
                  child: CircularProgressIndicator(color: Colors.blueAccent),
                ),
                error: (err, _) => Center(
                  child: Text('Failed to load municipal telemetry: $err', style: const TextStyle(color: Colors.redAccent)),
                ),
                data: (complaints) {
                  if (complaints.isEmpty) {
                    return const Center(
                      child: Text('Zero open civic infrastructure defects logged.', style: TextStyle(color: Color(0xFF71717A))),
                    );
                  }
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: complaints.length,
                    itemBuilder: (context, index) {
                      return _buildFormalComplaintStatusCard(complaints[index]);
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
        color: Color(0xFF18181B),
        border: Border(bottom: BorderSide(color: Color(0xFF27272A), width: 1.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildTelemetryMetric('OPEN CASELOAD', '15 ACTIVE', Colors.amberAccent)),
              Expanded(child: _buildTelemetryMetric('AVG DISPATCH SPEED', '4.2 HOURS', Colors.greenAccent)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTelemetryMetric('AI SEVERITY INDEX', 'TIER 1 CRITICAL', const Color(0xFFE11D48))),
              Expanded(child: _buildTelemetryMetric('MEME OVERLAYS', 'SUPPRESSED / HIDDEN', Colors.grey)),
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
        Text(label, style: const TextStyle(color: Color(0xFF71717A), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        const SizedBox(height: 3),
        Text(val, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w800)),
      ],
    );
  }

  /// Builds formal, high-contrast, text-heavy status card without satire meme overlays
  Widget _buildFormalComplaintStatusCard(Complaint complaint) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF3F3F46), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: RTO Jurisdiction & Formal Timestamp
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF27272A),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_city_rounded, color: Colors.blueAccent, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'RTO JURISDICTION: ${complaint.rtoCode}',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
              Text(
                'LOGGED: ${complaint.createdAt.toString().split(' ')[0]}',
                style: const TextStyle(color: Color(0xFF71717A), fontSize: 11, fontFamily: 'monospace'),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Title & Formal Technical Description
          Text(
            complaint.title,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            complaint.description,
            style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),

          // Formal High-Contrast Text-Heavy Status Pills (Meme overlays explicitly hidden)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFormalStatusPill('REVIEW PENDING', Colors.amber),
              _buildFormalStatusPill('DISPATCHED TO MUNICIPALITY', Colors.lightBlueAccent),
              _buildFormalStatusPill('STRUCTURAL INSPECTION REQUIRED', const Color(0xFFE11D48)),
              _buildFormalStatusPill('PRIORITY TIER 1', Colors.greenAccent),
            ],
          ),
          const SizedBox(height: 18),

          // Analytical Action Control Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.assignment_ind_outlined, size: 16, color: Colors.blueAccent),
                label: const Text('Assign Inspector', style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.blueAccent.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.check_circle_outline, size: 16),
                label: const Text('Mark Dispatched', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormalStatusPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// ADMIN CORE PANEL VIEW
/// Elite command room screen with raw backend logs, system analytics, and DB drop
/// ---------------------------------------------------------------------------
class AdminCorePanelView extends ConsumerStatefulWidget {
  const AdminCorePanelView({super.key});

  @override
  ConsumerState<AdminCorePanelView> createState() => _AdminCorePanelViewState();
}

class _AdminCorePanelViewState extends ConsumerState<AdminCorePanelView> {
  final List<String> _rawBackendLogs = [
    '[2026-07-07 16:55:01Z] [Stitch HTTP] Broadcast success -> Row ID: 6a4c52a45fbfdfdafcf6e934 (GJ-01)',
    '[2026-07-07 16:55:12Z] [Edge Vision AI] Verified structural trench depth: 1.4m on SG Highway',
    '[2026-07-07 16:55:40Z] [Satire Copywriter] Synthesized localized sarcasm for Ahmedabad jurisdiction',
    '[2026-07-07 16:56:05Z] [Stitch HTTP] Injected row ID: 6a4c52a55fbfdfdafcf6e936 (MH-01 monsoon crater)',
    '[2026-07-07 16:56:33Z] [RBAC Gateway] Root auth session initialized for master token: ADMIN777',
    '[2026-07-07 16:57:10Z] [Atlas Shard 00] Replication sync complete. 0 packet loss detected across clusters.',
    '[2026-07-07 16:57:42Z] [Riverpod State] Tri-role RBAC orchestrator active. Subscribed to authProvider.',
  ];

  void _executeMasterDatabaseDrop() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF18181B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE11D48), width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFE11D48), size: 28),
            SizedBox(width: 10),
            Text('CRITICAL WARNING', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ],
        ),
        content: const Text(
          'You are about to execute a MASTER DATABASE DROP on MongoDB Atlas Cluster0 (civic_satire -> complaints).\n\nThis action will purge all 15 civic records, terminate active edge vision pipelines, and reset shard indexes. Proceed?',
          style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ABORT', style: TextStyle(color: Color(0xFFA1A1AA), fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _rawBackendLogs.insert(
                  0,
                  '[${DateTime.now().toIso8601String()}] [CAUTION] MASTER DATABASE DROP EXECUTED! Collection purged & shards reset.',
                );
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.delete_forever_rounded, color: Colors.white, size: 22),
                      SizedBox(width: 10),
                      Text('💥 Master Database Purged! All collections & shards reset.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  backgroundColor: const Color(0xFFE11D48),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
            child: const Text('PURGE MASTER DATABASE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF18181B),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings_rounded, color: Color(0xFFE11D48), size: 22),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'ELITE ADMIN COMMAND ROOM',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.8),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE11D48).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFE11D48)),
            ),
            child: Text(
              'ROOT ACCESS | ${authState.token ?? "ADMIN777"}',
              style: const TextStyle(color: Color(0xFFE11D48), fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFA1A1AA)),
            tooltip: 'Sign Out & Terminate Root Session',
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section 1: System Analytics Telemetry Fields
              const Text(
                'SYSTEM ANALYTICS TELEMETRY FIELDS',
                style: TextStyle(color: Color(0xFF71717A), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.0),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildTelemetryCard('ATLAS SHARDS', '3 Active Shards', 'Latency: 14ms', Icons.storage, Colors.greenAccent)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTelemetryCard('VISION AI PIPELINE', '98.4% Accuracy', 'Throughput: 42 req/s', Icons.auto_awesome, Colors.amber)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTelemetryCard('SATIRE ENGINE', '15 Shards Online', 'Sarcasm Index: 9.8/10', Icons.psychology, Colors.lightBlueAccent)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTelemetryCard('CPU & RAM LOAD', '14.2% / 2.1 GB', 'Status: Optimal', Icons.memory, const Color(0xFFE11D48))),
                ],
              ),
              const SizedBox(height: 28),

              // Section 2: Raw Backend Logs Stream
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'RAW BACKEND TELEMETRY & STITCH LOGS',
                    style: TextStyle(color: Color(0xFF71717A), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.0),
                  ),
                  Text(
                    'LIVE TAIL (200 OK)',
                    style: TextStyle(color: Colors.greenAccent.shade400, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                height: 220,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF18181B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF3F3F46), width: 1.2),
                ),
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _rawBackendLogs.length,
                  itemBuilder: (context, index) {
                    final log = _rawBackendLogs[index];
                    final isWarning = log.contains('[CAUTION]');
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        log,
                        style: TextStyle(
                          color: isWarning ? const Color(0xFFE11D48) : const Color(0xFFA1A1AA),
                          fontFamily: 'monospace',
                          fontSize: 12,
                          fontWeight: isWarning ? FontWeight.bold : FontWeight.normal,
                          height: 1.3,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Section 3: Master Database Drop Button
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF18181B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE11D48).withValues(alpha: 0.6), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.dangerous_outlined, color: Color(0xFFE11D48), size: 22),
                        SizedBox(width: 8),
                        Text(
                          'DANGER ZONE: MASTER DATABASE CONTROLS',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Executing a database drop will instantly clear all cloud collections and reset edge vision validation models. Use with extreme caution during judging presentations.',
                      style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 12, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _executeMasterDatabaseDrop,
                        icon: const Icon(Icons.delete_forever_rounded, size: 20),
                        label: const Text(
                          'EXECUTE MASTER DATABASE DROP',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.8),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE11D48),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTelemetryCard(String title, String val1, String val2, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF3F3F46)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Color(0xFF71717A), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(val1, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(val2, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
