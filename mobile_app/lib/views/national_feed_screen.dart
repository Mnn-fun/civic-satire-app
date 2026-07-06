import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/views/complaint_card.dart';

// Sample data provider supplying civic complaints matching the MongoDB schema
final complaintsListProvider = Provider<List<Complaint>>((ref) {
  final now = DateTime.now();
  return [
    Complaint(
      id: '668a1b2c3d4e5f6a7b8c9d01',
      title: 'Crater-Sized Potholes on Western Express Highway Commute',
      description: 'Multiple deep potholes near Andheri flyover causing severe traffic jams and vehicle damage during peak monsoon commute hours.',
      rtoCode: 'MH-01',
      imageUrl: 'https://images.unsplash.com/photo-1515162816999-a0c47dc192f7?auto=format&fit=crop&w=800&q=80',
      satireText: 'Municipal Corporation clarifies that these are not potholes, but a newly commissioned lunar surface simulation park for aspiring astronauts.',
      upvotes: 1842,
      createdAt: now.subtract(const Duration(hours: 2)),
      comments: [
        'My hatchback almost disappeared into the third crater near the exit ramp. Can we get a warning sign at least?'
      ],
    ),
    Complaint(
      id: '668a1b2c3d4e5f6a7b8c9d02',
      title: 'Barricaded Road Excavation Left Abandoned for 8 Months',
      description: 'Outer Ring Road lane reduced to single file due to unfinished underground wiring and drainage work with no workers on site.',
      rtoCode: 'DL-01',
      imageUrl: 'https://images.unsplash.com/photo-1541888946425-d0ebb18086f6?auto=format&fit=crop&w=800&q=80',
      satireText: 'Archaeological Survey of India declared the excavation a protected heritage site after discovering tools from the 2018 municipal budget.',
      upvotes: 2410,
      createdAt: now.subtract(const Duration(hours: 5)),
      comments: [], // Empty comments to demonstrate clean centered gray placeholder text
    ),
    Complaint(
      id: '668a1b2c3d4e5f6a7b8c9d03',
      title: 'Uncollected Refuse Overflowing onto Tech Park Pedestrian Walkway',
      description: 'Garbage collection trucks have skipped the Whitefield sector for three consecutive days, blocking pedestrian sidewalk access completely.',
      rtoCode: 'KA-05',
      imageUrl: 'https://images.unsplash.com/photo-1605600659908-0ef719419d41?auto=format&fit=crop&w=800&q=80',
      satireText: 'Local tech startups are now pitching AI-powered odor-canceling headphones to help pedestrians navigate the new organic biodiversity corridor.',
      upvotes: 950,
      createdAt: now.subtract(const Duration(hours: 12)),
      comments: [], // Empty comments to demonstrate clean centered gray placeholder text
    ),
  ];
});

class NationalFeedScreen extends ConsumerWidget {
  const NationalFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complaints = ref.watch(complaintsListProvider);
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
            icon: const Icon(Icons.search),
            onPressed: () {},
            tooltip: 'Search Complaints',
          ),
        ],
      ),
      // Overall screen wrapper simulating hardware shake listener
      body: GestureDetector(
        onDoubleTap: toggleSatireMode, // double-tap anywhere on screen background to simulate shake
        child: ListView.separated(
          // Lock scroll physics to BouncingScrollPhysics for premium kinetic feedback
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          itemCount: complaints.length,
          // Explicit SizedBox(height: 16) separator for scannable card padding
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final complaint = complaints[index];
            return ComplaintCard(complaint: complaint);
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
