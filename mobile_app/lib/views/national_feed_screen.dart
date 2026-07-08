import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:mobile_app/models/complaint.dart';
import 'package:mobile_app/providers/global_auth_provider.dart';
import 'package:mobile_app/services/feed_network_service.dart';
import 'package:mobile_app/views/citizen_account_screen.dart';
import 'package:mobile_app/views/citizen_reported_history_screen.dart';
import 'package:mobile_app/views/complaint_card.dart';
import 'package:mobile_app/views/submit_complaint_screen.dart';

/// Refactored to Google Stitch Light UI (#FFFFFF background, 8dp borders, sharp Google accents)
/// Features a 3-Option Bottom Navigation Bar (National Feed, Reported, Account) inspired by HTML canvas.
class NationalFeedScreen extends ConsumerStatefulWidget {
  const NationalFeedScreen({super.key});

  @override
  ConsumerState<NationalFeedScreen> createState() => _NationalFeedScreenState();
}

class _NationalFeedScreenState extends ConsumerState<NationalFeedScreen> {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  DateTime? _lastShakeTime;
  double? _lastX, _lastY, _lastZ;
  int _selectedNavIndex = 0; // 0: National Feed, 1: Reported, 2: Account

  @override
  void initState() {
    super.initState();
    _initShakeListener();
  }

  /// Initializes hardware accelerometer stream with strict 16.0 m/s^2 force target
  /// and sharp direction delta dampening to prevent false triggers during steady walking.
  void _initShakeListener() {
    try {
      _accelerometerSubscription = accelerometerEventStream().listen((
        AccelerometerEvent event,
      ) {
        final deltaX = _lastX == null ? 0.0 : (event.x - _lastX!).abs();
        final deltaY = _lastY == null ? 0.0 : (event.y - _lastY!).abs();
        final deltaZ = _lastZ == null ? 0.0 : (event.z - _lastZ!).abs();

        _lastX = event.x;
        _lastY = event.y;
        _lastZ = event.z;

        final exceedsThreshold =
            event.x.abs() >= 16.0 ||
            event.y.abs() >= 16.0 ||
            event.z.abs() >= 16.0;

        final hasSharpDelta =
            deltaX >= 12.0 || deltaY >= 12.0 || deltaZ >= 12.0;

        if (exceedsThreshold && hasSharpDelta) {
          _handleShakeDetected();
        }
      });
    } catch (e) {
      debugPrint(
        'Hardware accelerometer stream initialization failed or unsupported: $e',
      );
    }
  }

  /// Handles a detected shake with an explicit 500ms debounce window.
  void _handleShakeDetected() {
    final now = DateTime.now();
    if (_lastShakeTime == null ||
        now.difference(_lastShakeTime!) > const Duration(milliseconds: 500)) {
      _lastShakeTime = now;

      final isCurrentlySatire = ref.read(isSatireModeProvider);
      final newState = !isCurrentlySatire;
      ref.read(isSatireModeProvider.notifier).setSatireMode(newState);
      _showSatireSnackBar(newState, isHardwareShake: true);
    }
  }

  /// Manual toggle for testing without physical accelerometer hardware
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
              color: isSatireMode
                  ? const Color(0xFFEA4335)
                  : const Color(0xFF70757A),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isSatireMode
                    ? (isHardwareShake
                          ? '⚡ SHAKE DETECTED: AI Satire Overlay Activated!'
                          : 'AI Satire Overlay Activated!')
                    : 'Satire Mode Deactivated (Normal View)',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF171C20),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isSatireMode ? const Color(0xFFF6FAFF) : Colors.white,
        duration: const Duration(milliseconds: 1800),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSatireMode
                ? const Color(0xFFEA4335)
                : const Color(0xFFDEE3E8),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedAsyncValue = ref.watch(feedNotifierProvider);
    final isSatireMode = ref.watch(isSatireModeProvider);

    return Scaffold(
      backgroundColor:
          Colors.white, // Solid white (#FFFFFF) Scaffold background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: GestureDetector(
          onTap: _toggleSatireMode,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Transform.rotate(
                angle: -0.26, // -15 degrees tilt
                child: const Icon(
                  Icons.campaign_outlined,
                  color: Color(0xFF4285F4),
                  size: 26,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _getAppBarTitle(),
                style: const TextStyle(
                  color: Color(0xFF171C20),
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF4285F4)),
            onPressed: () {
              ref
                  .read(feedNotifierProvider.notifier)
                  .fetchFeed(isRefresh: true);
            },
            tooltip: 'Refresh Feed from Stitch Endpoint',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildMainBody(feedAsyncValue, isSatireMode),
      floatingActionButton: _selectedNavIndex == 2
          ? null // Hide FAB on Account tab
          : FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SubmitComplaintScreen(),
                  ),
                );
              },
              backgroundColor: const Color(0xFF4285F4).withValues(alpha: 0.82),
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              elevation: 0,
              highlightElevation: 0,
              extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
              extendedIconLabelSpacing: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  8,
                ), // Exactly 8dp rectangular boundary
                side: const BorderSide(
                  color: Color(0xFF4285F4),
                  width: 1.5,
                ), // Sharp 1.5dp Google Blue outline
              ),
              icon: const Icon(
                Icons.add_circle_outline_rounded,
                size: 22,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              label: const Text(
                'Report Issue',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedNavIndex) {
      case 1:
        return 'Reported Issues';
      case 2:
        return 'Citizen Account';
      case 0:
      default:
        return 'The National Feed';
    }
  }

  Widget _buildMainBody(
    AsyncValue<List<Complaint>> feedAsyncValue,
    bool isSatireMode,
  ) {
    return IndexedStack(
      index: _selectedNavIndex,
      children: [
        // Index 0: National Feed
        _buildFeedContent(feedAsyncValue, isSatireMode, isReportedTab: false),
        // Index 1: Reported
        CitizenReportedHistoryScreen(
          onReportIssuePressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SubmitComplaintScreen(),
              ),
            );
          },
        ),
        // Index 2: Account slot pointing directly to CitizenAccountScreen
        const CitizenAccountScreen(showAppBar: false),
      ],
    );
  }

  Widget _buildFeedContent(
    AsyncValue<List<Complaint>> feedAsyncValue,
    bool isSatireMode, {
    required bool isReportedTab,
  }) {
    return GestureDetector(
      onDoubleTap: _toggleSatireMode,
      child: feedAsyncValue.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF4285F4)),
              SizedBox(height: 16),
              Text(
                'Synchronizing civic discourse with Stitch endpoint...',
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
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFEA4335),
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load civic feed',
                  style: TextStyle(
                    color: Color(0xFF171C20),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF70757A),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => ref
                      .read(feedNotifierProvider.notifier)
                      .fetchFeed(isRefresh: true),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry Fetch'),
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
                style: TextStyle(
                  color: Color(0xFF70757A),
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          }

          final displayList = isReportedTab ? complaints : complaints;

          return RefreshIndicator(
            color: const Color(0xFF4285F4),
            backgroundColor: Colors.white,
            onRefresh: () => ref
                .read(feedNotifierProvider.notifier)
                .fetchFeed(isRefresh: true),
            child: ListView.separated(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              itemCount: displayList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 32),
              itemBuilder: (context, index) {
                final complaint = displayList[index];
                final authState = ref.watch(globalAuthProvider);
                final isGov = authState.role == UserRole.government;
                return ComplaintCard(
                  complaint: complaint,
                  suppressSatire: isGov,
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// Builds the 3-Option Google Stitch Light Breathable Bottom Navigation Bar
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFDEE3E8), width: 1.5)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, 'National Feed', Icons.grid_view_rounded),
          _buildNavItem(1, 'Reported', Icons.campaign_outlined),
          _buildNavItem(2, 'Account', Icons.person_outline_rounded),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final isSelected = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedNavIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4285F4).withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8), // Exactly 8dp radius
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4285F4).withValues(alpha: 0.4)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? const Color(0xFF0058BD)
                  : const Color(0xFF70757A),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF0058BD)
                    : const Color(0xFF70757A),
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
