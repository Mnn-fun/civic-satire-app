import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Sample data model for civic satire items
class SatirePost {
  final String id;
  final String title;
  final String category;
  final String summary;
  final String timestamp;
  final int upvotes;

  const SatirePost({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.timestamp,
    required this.upvotes,
  });
}

// A Riverpod provider providing placeholder civic satire posts
final nationalFeedProvider = Provider<List<SatirePost>>((ref) {
  return const [
    SatirePost(
      id: '1',
      title: 'City Council Resolves Pothole Crisis by Declaring Street "Historic Cobblestone Experience"',
      category: 'Infrastructure',
      summary: 'Motorists are now encouraged to drive at 5 mph to fully appreciate the authentic 18th-century wagon trail ambiance.',
      timestamp: '2h ago',
      upvotes: 1420,
    ),
    SatirePost(
      id: '2',
      title: 'New Department of Bureaucracy Created to Streamline Existing Bureaucracy',
      category: 'Government',
      summary: 'The agency promises to cut red tape by introducing a mandatory 14-page form to request red tape removal.',
      timestamp: '4h ago',
      upvotes: 890,
    ),
    SatirePost(
      id: '3',
      title: 'Local Mayor Proposes Replacing Town Hall Debates with Competitive Reality Show Elimination',
      category: 'Elections',
      summary: 'Citizens will vote via SMS to see which council member gets voted off the budget committee island this week.',
      timestamp: '6h ago',
      upvotes: 2150,
    ),
  ];
});

class NationalFeedScreen extends ConsumerWidget {
  const NationalFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedItems = ref.watch(nationalFeedProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.campaign_outlined, color: Color(0xFFE11D48), size: 26),
            SizedBox(width: 10),
            Text('The National Feed'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
            tooltip: 'Search Satire',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
            tooltip: 'Alerts',
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: feedItems.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final post = feedItems[index];
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE11D48).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFE11D48).withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            post.category.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: const Color(0xFFFB7185),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        Text(
                          post.timestamp,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      post.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post.summary,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(Icons.arrow_upward_rounded, size: 18, color: theme.colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          '${post.upvotes}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.chat_bubble_outline_rounded, size: 16, color: theme.textTheme.bodySmall?.color),
                        const SizedBox(width: 6),
                        Text(
                          'Discuss',
                          style: theme.textTheme.labelMedium,
                        ),
                        const Spacer(),
                        Icon(Icons.share_outlined, size: 18, color: theme.textTheme.bodySmall?.color),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        tooltip: 'Submit Satire',
        child: const Icon(Icons.edit),
      ),
    );
  }
}
