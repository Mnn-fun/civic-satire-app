import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/models/complaint.dart';
import 'package:mobile_app/providers/global_auth_provider.dart';
import 'package:mobile_app/services/feed_network_service.dart';

/// Production-ready CitizenReportedHistoryScreen serving as the citizen's personal
/// upload log with visual pipeline progression and pull-to-refresh invalidation.
class CitizenReportedHistoryScreen extends ConsumerWidget {
  final VoidCallback? onReportIssuePressed;

  const CitizenReportedHistoryScreen({
    super.key,
    this.onReportIssuePressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(globalAuthProvider);
    final feedAsync = ref.watch(feedNotifierProvider);
    final citizenEmail = authState.email?.trim().toLowerCase();

    return Container(
      color: Colors.white,
      child: feedAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF4285F4)),
              SizedBox(height: 16),
              Text(
                'Synchronizing personal upload history...',
                style: TextStyle(
                  color: Color(0xFF70757A),
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: Color(0xFFEA4335), size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load reported history',
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
          // 1. USER POST LIFECYCLE FILTERING
          final myReports = _filterCitizenReports(allComplaints, citizenEmail);

          if (myReports.isEmpty) {
            return RefreshIndicator(
              color: const Color(0xFF4285F4),
              backgroundColor: Colors.white,
              onRefresh: () => ref.read(feedNotifierProvider.notifier).fetchFeed(isRefresh: true),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 64),
                children: [
                  const SizedBox(height: 40),
                  const Icon(
                    Icons.history_edu_rounded,
                    color: Color(0xFFBDC1C6),
                    size: 64,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Your voice hasn't been raised yet. Use the 'Report Issue' button to start.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF70757A),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                  if (onReportIssuePressed != null) ...[
                    const SizedBox(height: 24),
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: onReportIssuePressed,
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                        label: const Text('Raise First Issue'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4285F4),
                          side: const BorderSide(color: Color(0xFF4285F4), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          // 3. STATE INTEGRITY: RefreshIndicator wrapping timeline cards
          return RefreshIndicator(
            color: const Color(0xFF4285F4),
            backgroundColor: Colors.white,
            onRefresh: () => ref.read(feedNotifierProvider.notifier).fetchFeed(isRefresh: true),
            child: ListView.separated(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              itemCount: myReports.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildTimelineProgressionCard(myReports[index]);
              },
            ),
          );
        },
      ),
    );
  }

  /// Isolates rows matching logged-in citizen's email metadata or local session submissions
  List<Complaint> _filterCitizenReports(List<Complaint> allComplaints, String? citizenEmail) {
    return allComplaints.where((complaint) {
      if (complaint.id.startsWith('local_')) {
        return true;
      }
      if (complaint.reporterEmail != null && citizenEmail != null) {
        return complaint.reporterEmail!.trim().toLowerCase() == citizenEmail;
      }
      return false;
    }).toList();
  }

  /// 2. TIMELINE PROGRESSION CARDS
  Widget _buildTimelineProgressionCard(Complaint complaint) {
    final status = complaint.status;
    final stageIndex = _getPipelineStageIndex(status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDEE3E8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card Header Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              border: Border(bottom: BorderSide(color: Color(0xFFDEE3E8), width: 1.0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4285F4).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF4285F4), width: 1.0),
                  ),
                  child: Text(
                    'RTO ZONE: ${complaint.rtoCode.toUpperCase()}',
                    style: const TextStyle(
                      color: Color(0xFF0058BD),
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 0.4,
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
          ),

          // Main Content: Thumbnail + Title
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    complaint.imageUrl,
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 76,
                      height: 76,
                      color: const Color(0xFFF1F3F4),
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported_rounded, color: Color(0xFF70757A), size: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        complaint.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF171C20),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        complaint.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF5F6368),
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Horizontal Linear Pipeline Progression Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
              border: Border(top: BorderSide(color: Color(0xFFDEE3E8), width: 1.0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'MUNICIPAL REVIEW PIPELINE',
                      style: TextStyle(
                        color: Color(0xFF70757A),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      _getPipelineStatusLabel(status),
                      style: TextStyle(
                        color: _getPipelineStatusColor(status),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Step Progression Bar
                Row(
                  children: [
                    _buildPipelineStepIndicator(stepIndex: 1, currentStage: stageIndex, label: 'Cloud AI'),
                    _buildPipelineConnector(isActive: stageIndex >= 2),
                    _buildPipelineStepIndicator(stepIndex: 2, currentStage: stageIndex, label: 'RTO Logged'),
                    _buildPipelineConnector(isActive: stageIndex >= 3),
                    _buildPipelineStepIndicator(stepIndex: 3, currentStage: stageIndex, label: 'Inspection'),
                    _buildPipelineConnector(isActive: stageIndex >= 4),
                    _buildPipelineStepIndicator(stepIndex: 4, currentStage: stageIndex, label: 'Dispatched'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineStepIndicator({
    required int stepIndex,
    required int currentStage,
    required String label,
  }) {
    final isCompleted = stepIndex <= currentStage;
    final isCurrent = stepIndex == currentStage;

    final Color dotColor = isCompleted
        ? (isCurrent ? const Color(0xFF1A73E8) : const Color(0xFF34A853))
        : const Color(0xFFDEE3E8);

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isCurrent ? const Color(0xFF1A73E8) : dotColor,
                width: 2.0,
              ),
            ),
            child: isCompleted
                ? const Icon(Icons.check, size: 9, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
              color: isCompleted ? const Color(0xFF171C20) : const Color(0xFF70757A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineConnector({required bool isActive}) {
    return Container(
      width: 18,
      height: 2,
      color: isActive ? const Color(0xFF34A853) : const Color(0xFFDEE3E8),
    );
  }

  int _getPipelineStageIndex(String status) {
    switch (status) {
      case 'Dispatched to Municipality':
        return 4;
      case 'Structural Inspection Required':
        return 3;
      case 'Review Pending':
        return 2;
      default:
        return 1;
    }
  }

  String _getPipelineStatusLabel(String status) {
    switch (status) {
      case 'Dispatched to Municipality':
        return 'Status: Sent to Cloud Verification -> Received by RTO -> Dispatched';
      case 'Structural Inspection Required':
        return 'Status: Sent to Cloud Verification -> Inspection Required';
      case 'Review Pending':
        return 'Status: Sent to Cloud Verification -> Received by RTO';
      default:
        return 'Status: Sent to Cloud Verification Agents -> Under AI Evaluation';
    }
  }

  Color _getPipelineStatusColor(String status) {
    switch (status) {
      case 'Dispatched to Municipality':
        return const Color(0xFF137333);
      case 'Structural Inspection Required':
        return const Color(0xFFB06000);
      case 'Review Pending':
        return const Color(0xFF1A73E8);
      default:
        return const Color(0xFF424753);
    }
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
