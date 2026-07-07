import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:mobile_app/services/feed_network_service.dart';
import 'package:mobile_app/views/complaint_card.dart';
import 'package:mobile_app/views/submit_complaint_screen.dart';

class NationalFeedScreen extends ConsumerStatefulWidget {
  const NationalFeedScreen({super.key});

  @override
  ConsumerState<NationalFeedScreen> createState() => _NationalFeedScreenState();
}

class _NationalFeedScreenState extends ConsumerState<NationalFeedScreen> {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  DateTime? _lastShakeTime;

  @override
  void initState() {
    super.initState();
    _initShakeListener();
  }

  /// Initializes the hardware accelerometer stream to detect physical shake gestures.
  void _initShakeListener() {
    try {
      // Monitor physical device movement via sensors_plus accelerometerEventStream
      _accelerometerSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
        // Mathematical threshold calculation: check if absolute acceleration force
        // exceeds a threshold value of 12.0 m/s^2 along the X or Y axis (or 15.0 on Z)
        if (event.x.abs() > 12.0 || event.y.abs() > 12.0 || event.z.abs() > 15.0) {
          _handleShakeDetected();
        }
      });
    } catch (e) {
      debugPrint('Hardware accelerometer stream initialization failed or unsupported: $e');
    }
  }

  /// Handles a detected shake with an explicit 500ms debounce window.
  void _handleShakeDetected() {
    final now = DateTime.now();
    // Explicit debounce mechanism (500ms window) so a single physical shake doesn't rapidly trigger multiple times
    if (_lastShakeTime == null || now.difference(_lastShakeTime!) > const Duration(milliseconds: 500)) {
      _lastShakeTime = now;

      // Instantly flip Riverpod state provider (isSatireModeProvider) to true with zero delay
      final isCurrentlySatire = ref.read(isSatireModeProvider);
      if (!isCurrentlySatire) {
        ref.read(isSatireModeProvider.notifier).setSatireMode(true);
        _showSatireSnackBar(true, isHardwareShake: true);
      } else {
        // Toggling back to normal view on subsequent shake
        ref.read(isSatireModeProvider.notifier).setSatireMode(false);
        _showSatireSnackBar(false, isHardwareShake: true);
      }
    }
  }

  /// Manual toggle for emulator / desktop testing without physical accelerometer hardware
  void _toggleSatireMode() {
    final newState = !ref.read(isSatireModeProvider);
    ref.read(isSatireModeProvider.notifier).setSatireMode(newState);
    _showSatireSnackBar(newState, isHardwareShake: false);
  }

  void _showSatireSnackBar(bool isSatireMode, {required bool isHardwareShake}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSatireMode ? Icons.auto_awesome : Icons.visibility_off,
              color: isSatireMode ? Colors.amber.shade400 : const Color(0xFFA1A1AA),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isSatireMode
                    ? (isHardwareShake ? '⚡ SHAKE DETECTED: AI Satire Overlay Activated!' : 'AI Satire Overlay Activated!')
                    : 'Satire Mode Deactivated (Normal View)',
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: isSatireMode ? const Color(0xFFE11D48) : const Color(0xFF27272A),
        duration: const Duration(milliseconds: 1800),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  void dispose() {
    // Cleanly dispose of stream listener when widget unmounts to prevent memory leaks during testing
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedAsyncValue = ref.watch(feedNotifierProvider);
    final isSatireMode = ref.watch(isSatireModeProvider);

    return Scaffold(
      appBar: AppBar(
        // Clicking app bar title simulates hardware shake trigger for emulator testing
        title: GestureDetector(
          onTap: _toggleSatireMode,
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
                  'SHAKE/TAP',
                  style: TextStyle(color: Color(0xFF71717A), fontSize: 9, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSatireMode ? Icons.auto_awesome : Icons.vibration,
                key: ValueKey(isSatireMode),
                color: isSatireMode ? Colors.amber.shade400 : const Color(0xFFFAFAFA),
              ),
            ),
            onPressed: _toggleSatireMode,
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
      body: GestureDetector(
        onDoubleTap: _toggleSatireMode, // double-tap anywhere on background to simulate shake
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
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SubmitComplaintScreen()),
          );
        },
        backgroundColor: const Color(0xFF27272A), // Corporate dull gray (zinc-800)
        foregroundColor: const Color(0xFFFAFAFA), // Crisp white text and icon
        elevation: 4,
        highlightElevation: 6,
        extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
        extendedIconLabelSpacing: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: Color(0xFF52525B), width: 1.2), // Corporate neutral gray border
        ),
        icon: const Icon(Icons.add_circle_outline_rounded, size: 22, color: Color(0xFFE4E4E7)),
        label: const Text(
          'Report Issue',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: 0.5),
        ),
      ),
    );
  }
}
