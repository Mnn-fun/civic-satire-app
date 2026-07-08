import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/services/auth_service.dart';

/// Admin Panel layout displayed when authenticated as UserRole.admin with masterKey 'ADMIN777'
/// Refactored to Google Stitch Light UI (#FFFFFF background, 8dp borders, sharp Google accents).
class AdminPanelScreen extends ConsumerWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white, // Solid white background (#FFFFFF)
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF171C20)),
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings_rounded, color: Color(0xFFEA4335), size: 24),
            SizedBox(width: 10),
            Text('RBAC Admin Command Panel', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF171C20))),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF70757A)),
            tooltip: 'Clean Sign-Out (Test Loop Guard)',
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Active RBAC Security Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDAD6).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEA4335), width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEA4335).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.security, color: Color(0xFFEA4335), size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '⚡ ROOT ACCESS GRANTED',
                            style: TextStyle(color: Color(0xFF171C20), fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 0.8),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Role: ${authState.role?.name.toUpperCase() ?? "UNKNOWN"} | Token: ${authState.token ?? "N/A"}',
                            style: const TextStyle(color: Color(0xFFC5221F), fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // System Diagnostics Section Label
              const Text(
                'EDGE AGENT PIPELINE DIAGNOSTICS',
                style: TextStyle(color: Color(0xFF70757A), fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.0),
              ),
              const SizedBox(height: 12),

              // Metric Cards Grid
              Row(
                children: [
                  Expanded(child: _buildMetricCard('Active Atlas Shards', '3 Shards', Icons.storage, const Color(0xFF137333), const Color(0xFF34A853))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMetricCard('Vision AI Accuracy', '98.4%', Icons.auto_awesome, const Color(0xFFB06000), const Color(0xFFFBBC04))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildMetricCard('Satire Copywriters', 'Online (15/15)', Icons.text_snippet_outlined, const Color(0xFF0058BD), const Color(0xFF4285F4))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMetricCard('Backdoor Status', 'ADMIN777 Valid', Icons.key, const Color(0xFFC5221F), const Color(0xFFEA4335))),
                ],
              ),
              const SizedBox(height: 32),

              // Moderation Control Section
              const Text(
                'SATIRE FEED MODERATION QUEUE',
                style: TextStyle(color: Color(0xFF70757A), fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.0),
              ),
              const SizedBox(height: 12),
              _buildQueueItem('GJ-01: BRTS Corridor Excavation Gridlock', 'Auto-Approved by Satire Agent', true),
              const SizedBox(height: 10),
              _buildQueueItem('MH-01: Crater-Sized Monsoon Potholes', 'Auto-Approved by Satire Agent', true),
              const SizedBox(height: 10),
              _buildQueueItem('DL-01: Smog-Covered Barricades Left Abandoned', 'Flagged for High Satire Potency', false),
              const SizedBox(height: 32),

              // Clean Sign Out Button
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.logout_rounded, size: 18, color: Color(0xFF424753)),
                label: const Text('Sign Out & Terminate Admin Session', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF424753))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFDEE3E8), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color textColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDEE3E8), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: borderColor, size: 22),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: Color(0xFF171C20), fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Color(0xFF70757A), fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildQueueItem(String title, String status, bool approved) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDEE3E8), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(
            approved ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            color: approved ? const Color(0xFF34A853) : const Color(0xFFFBBC04),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFF171C20), fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 2),
                Text(status, style: TextStyle(color: approved ? const Color(0xFF70757A) : const Color(0xFFB06000), fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
