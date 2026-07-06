import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/services/feed_network_service.dart';
import 'package:mobile_app/views/complaint_card.dart';

class NationalFeedScreen extends ConsumerWidget {
  const NationalFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsyncValue = ref.watch(feedNotifierProvider);
    final isSatireMode = ref.watch(satireModeProvider);
    final theme = Theme.of(context);

    // Toggle AI Satire mode (simulates hardware shake trigger)
    void toggleSatireMode() {
      ref.read(satireModeProvider.notifier).toggle();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isSatireMode ? Icons.visibility_off : Icons.auto_awesome,
                color: isSatireMode ? const Color(0xFFA1A1AA) : Colors.amber.shade400,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                isSatireMode ? 'Satire Mode Deactivated (Normal View)' : 'Shake Triggered: AI Satire Overlay Activated!',
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ],
          ),
          backgroundColor: isSatireMode ? const Color(0xFF27272A) : const Color(0xFFE11D48),
          duration: const Duration(milliseconds: 1800),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        // Clicking app bar title simulates hardware shake trigger
        title: GestureDetector(
          onTap: toggleSatireMode,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              const Icon(Icons.campaign_outlined, color: Color(0xFFE11D48), size: 26),
              const SizedBox(width: 10),
              const Text('The National Feed'),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF27272A),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'TAP/SHAKE',
                  style: TextStyle(color: Color(0xFF71717A), fontSize: 9, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Action button to trigger mock shake / toggle satire mode
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSatireMode ? Icons.auto_awesome : Icons.vibration,
                key: ValueKey(isSatireMode),
                color: isSatireMode ? Colors.amber.shade400 : const Color(0xFFFAFAFA),
              ),
            ),
            onPressed: toggleSatireMode,
            tooltip: 'Simulate Hardware Shake (Toggle Satire)',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(feedNotifierProvider.notifier).fetchFeed(isRefresh: true);
            },
            tooltip: 'Refresh Feed from Stitch Endpoint',
          ),
        ],
      ),
      // Overall screen wrapper simulating hardware shake listener
      body: GestureDetector(
        onDoubleTap: toggleSatireMode, // double-tap anywhere on screen background to simulate shake
        child: feedAsyncValue.when(
          loading: () => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Color(0xFFE11D48)),
                const SizedBox(height: 16),
                Text(
                  'Synchronizing civic discourse with Stitch endpoint...',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontStyle: FontStyle.italic),
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
                  const Icon(Icons.error_outline, color: Color(0xFFE11D48), size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load civic feed',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => ref.read(feedNotifierProvider.notifier).fetchFeed(isRefresh: true),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry Fetch'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27272A),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          data: (complaints) {
            if (complaints.isEmpty) {
              return const Center(
                child: Text(
                  'No civic complaints recorded in this jurisdiction.',
                  style: TextStyle(color: Color(0xFF71717A), fontStyle: FontStyle.italic),
                ),
              );
            }

            return RefreshIndicator(
              color: const Color(0xFFE11D48),
              backgroundColor: const Color(0xFF18181B),
              onRefresh: () => ref.read(feedNotifierProvider.notifier).fetchFeed(isRefresh: true),
              child: ListView.separated(
                // Lock scroll physics to BouncingScrollPhysics for premium kinetic feedback
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: complaints.length,
                // Explicit SizedBox(height: 16) separator for scannable card padding
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final complaint = complaints[index];
                  return ComplaintCard(complaint: complaint);
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Report Issue', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
