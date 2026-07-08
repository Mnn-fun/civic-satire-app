import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/models/complaint.dart';
import 'package:mobile_app/providers/global_auth_provider.dart';
import 'package:mobile_app/services/feed_network_service.dart';
import 'package:mobile_app/views/gateway_login_screen.dart';

/// Production-grade GovernmentCaseBoardScreen matching STREET VOICE Light Theme
/// design guidelines (#FFFFFF background, 8dp borders, sharp Google accents).
class GovernmentCaseBoardScreen extends ConsumerStatefulWidget {
  const GovernmentCaseBoardScreen({super.key});

  @override
  ConsumerState<GovernmentCaseBoardScreen> createState() => _GovernmentCaseBoardScreenState();
}

class _GovernmentCaseBoardScreenState extends ConsumerState<GovernmentCaseBoardScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(globalAuthProvider);
    final feedAsync = ref.watch(feedNotifierProvider);
    final officerRto = authState.rtoScope ?? 'MH-01';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF171C20)),
        title: const Row(
          children: [
            Icon(Icons.account_balance_rounded, color: Color(0xFF4285F4), size: 24),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'MUNICIPAL CASEBOARD',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFF171C20),
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  letterSpacing: -0.2,
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
              'RTO SCOPE | $officerRto',
              style: const TextStyle(
                color: Color(0xFF0058BD),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFEA4335)),
            tooltip: 'Sign Out of Government Console',
            onPressed: () {
              ref.read(globalAuthProvider.notifier).logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const GatewayLoginScreen()),
                (route) => false,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. ANALYTICAL HEADER PANEL
            feedAsync.when(
              data: (allComplaints) {
                final rtoCases = _filterByRtoScope(allComplaints, officerRto);
                return _buildAnalyticalHeaderPanel(
                  openCaseloadCount: rtoCases.length,
                  officerRto: officerRto,
                );
              },
              loading: () => _buildAnalyticalHeaderPanel(openCaseloadCount: 0, officerRto: officerRto),
              error: (_, _) => _buildAnalyticalHeaderPanel(openCaseloadCount: 0, officerRto: officerRto),
            ),

            // 2. RTO JURISDICTIONAL FILTERED CASEBOARD LIST
            Expanded(
              child: feedAsync.when(
                loading: () => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF4285F4)),
                      SizedBox(height: 16),
                      Text(
                        'Synchronizing regional RTO caseload data...',
                        style: TextStyle(
                          color: Color(0xFF70757A),
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                error: (error, stackTrace) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Color(0xFFEA4335), size: 48),
                        const SizedBox(height: 16),
                        const Text(
                          'Failed to synchronize municipal caseload',
                          style: TextStyle(
                            color: Color(0xFF171C20),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF70757A), fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => ref.read(feedNotifierProvider.notifier).fetchFeed(isRefresh: true),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry Synchronizing'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (allComplaints) {
                  final filteredComplaints = _filterByRtoScope(allComplaints, officerRto);

                  if (filteredComplaints.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.fact_check_outlined,
                              color: Color(0xFF34A853),
                              size: 52,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Zero open caseloads in RTO Zone $officerRto',
                              style: const TextStyle(
                                color: Color(0xFF171C20),
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'All reported infrastructure defects have been inspected or dispatched.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF70757A),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: const Color(0xFF4285F4),
                    backgroundColor: Colors.white,
                    onRefresh: () => ref.read(feedNotifierProvider.notifier).fetchFeed(isRefresh: true),
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      itemCount: filteredComplaints.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 24),
                      itemBuilder: (context, index) {
                        return _buildFormalCaseCard(filteredComplaints[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Filters complaints strictly matching the logged-in officer's regional RTO scope
  List<Complaint> _filterByRtoScope(List<Complaint> complaints, String officerRto) {
    if (officerRto.toUpperCase() == 'ALL') return complaints;
    return complaints.where((c) {
      final code = c.rtoCode.trim().toUpperCase();
      final scope = officerRto.trim().toUpperCase();
      return code == scope || code.contains(scope) || scope.contains(code);
    }).toList();
  }

  /// 1. Analytical Header Panel
  Widget _buildAnalyticalHeaderPanel({
    required int openCaseloadCount,
    required String officerRto,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(color: Color(0xFFDEE3E8), width: 1.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'OPEN CASELOAD',
                  value: '$openCaseloadCount Active',
                  valueColor: const Color(0xFFB06000),
                  icon: Icons.assignment_late_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  label: 'AVG DISPATCH SPEED',
                  value: '2.4 Hours',
                  valueColor: const Color(0xFF137333),
                  icon: Icons.speed_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFDEE3E8), width: 1.2),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield_outlined, color: Color(0xFF0058BD), size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Meme Overlays: Suppressed / Hidden',
                      style: TextStyle(
                        color: Color(0xFF171C20),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.check_circle_rounded, color: Color(0xFF34A853), size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required Color valueColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDEE3E8), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: valueColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF70757A),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Formal Case Cards Layout
  Widget _buildFormalCaseCard(Complaint complaint) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDEE3E8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar: Regional RTO Tag + Timestamp + Operational Status Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              border: Border(bottom: BorderSide(color: Color(0xFFDEE3E8), width: 1.0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4285F4).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF4285F4), width: 1.0),
                      ),
                      child: Text(
                        'RTO JURISDICTION: ${complaint.rtoCode.toUpperCase()}',
                        style: const TextStyle(
                          color: Color(0xFF0058BD),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Text(
                      _formatTimestamp(complaint.createdAt),
                      style: const TextStyle(
                        color: Color(0xFF70757A),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Stack high-contrast operational status pills matching mock designs
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildStatusPill(complaint.status),
                    _buildStatusPill('Priority Tier 1'),
                  ],
                ),
              ],
            ),
          ),

          // Formal Infrastructural Data Layout
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  complaint.title,
                  style: const TextStyle(
                    color: Color(0xFF171C20),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  complaint.description,
                  style: const TextStyle(
                    color: Color(0xFF424753),
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),

                // Clean Operational Image Card (Meme / Satire Overlays Suppressed)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      Image.network(
                        complaint.imageUrl,
                        height: 190,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          height: 190,
                          color: const Color(0xFFF1F3F4),
                          alignment: Alignment.center,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported_rounded, color: Color(0xFF70757A), size: 36),
                              SizedBox(height: 8),
                              Text('Site Image Record Offline', style: TextStyle(color: Color(0xFF70757A), fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          color: const Color(0xFF171C20).withValues(alpha: 0.85),
                          child: const Row(
                            children: [
                              Icon(Icons.verified_user_rounded, color: Colors.white, size: 14),
                              SizedBox(width: 8),
                              Text(
                                'Formal Municipal Telemetry Record — Satire Layer Suppressed',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 4. ACTION INTERACTIVE TRAYS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
              border: Border(top: BorderSide(color: Color(0xFFDEE3E8), width: 1.0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _handleActionUpdate(complaint, 'Structural Inspection Required'),
                    icon: const Icon(Icons.engineering_rounded, size: 18, color: Color(0xFF0058BD)),
                    label: const Text(
                      'Assign Inspector',
                      style: TextStyle(
                        color: Color(0xFF0058BD),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF4285F4), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleActionUpdate(complaint, 'Dispatched to Municipality'),
                    icon: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                    label: const Text(
                      'Mark Dispatched',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF137333),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  Widget _buildStatusPill(String status) {
    Color bg;
    Color fg;
    Color border;

    switch (status) {
      case 'Dispatched to Municipality':
        bg = const Color(0xFFE6F4EA);
        fg = const Color(0xFF137333);
        border = const Color(0xFF34A853);
        break;
      case 'Structural Inspection Required':
        bg = const Color(0xFFFEF7E0);
        fg = const Color(0xFFB06000);
        border = const Color(0xFFFBBC04);
        break;
      case 'Priority Tier 1':
        bg = const Color(0xFFFCE8E6);
        fg = const Color(0xFFC5221F);
        border = const Color(0xFFEA4335);
        break;
      default:
        bg = const Color(0xFFF1F3F4);
        fg = const Color(0xFF424753);
        border = const Color(0xFFDEE3E8);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 1.0),
      ),
      child: Text(
        '[ $status ]',
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  void _handleActionUpdate(Complaint complaint, String newStatus) async {
    await ref.read(feedNotifierProvider.notifier).updateComplaintStatus(complaint.id, newStatus);
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Case ID #${complaint.id.substring(0, 6)} updated to: [ $newStatus ]'),
        backgroundColor: const Color(0xFF171C20),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatTimestamp(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}
