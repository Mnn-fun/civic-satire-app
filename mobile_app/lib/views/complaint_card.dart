import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/models/complaint.dart';

// Riverpod 3 provider tracking if AI Satire Mode is toggled (simulated via shake or tap)
class SatireModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final satireModeProvider = NotifierProvider<SatireModeNotifier, bool>(SatireModeNotifier.new);

class ComplaintCard extends ConsumerStatefulWidget {
  final Complaint complaint;

  const ComplaintCard({super.key, required this.complaint});

  @override
  ConsumerState<ComplaintCard> createState() => _ComplaintCardState();
}

class _ComplaintCardState extends ConsumerState<ComplaintCard> {
  bool _isExpanded = false;

  void _toggleAccordion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSatireMode = ref.watch(satireModeProvider);
    final theme = Theme.of(context);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF18181B), // Corporate neutral dark surface (zinc-900)
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF3F3F46), // Clean neutral gray border (zinc-700)
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: RTO Code badge and timestamp
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27272A),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF52525B)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Color(0xFF3B82F6)),
                      const SizedBox(width: 4),
                      Text(
                        widget.complaint.rtoCode,
                        style: const TextStyle(
                          color: Color(0xFFFAFAFA),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatDate(widget.complaint.createdAt),
                  style: const TextStyle(
                    color: Color(0xFFA1A1AA),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Title & Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.complaint.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFFFAFAFA),
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.complaint.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFA1A1AA),
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),

          // Image section with strict Stack/Positioned/LayoutBuilder setup
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Base image layer
                  Container(
                    width: constraints.maxWidth,
                    height: 200,
                    decoration: const BoxDecoration(
                      color: Color(0xFF27272A),
                    ),
                    child: Image.network(
                      widget.complaint.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF27272A),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image_outlined, color: Color(0xFF52525B), size: 36),
                              SizedBox(height: 8),
                              Text('Civic Evidence Photo', style: TextStyle(color: Color(0xFF71717A), fontSize: 12)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  // AI Satire Text Overlay revealed when satireMode is triggered (via shake or toggle)
                  if (isSatireMode)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.75),
                              const Color(0xFFE11D48).withValues(alpha: 0.95),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.amber.shade400, width: 1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.auto_awesome, color: Colors.amber.shade400, size: 14),
                                    const SizedBox(width: 6),
                                    Text(
                                      'AI SATIRE GENERATED',
                                      style: TextStyle(
                                        color: Colors.amber.shade400,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '"${widget.complaint.satireText}"',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          // Footer / Accordion Trigger Bar
          InkWell(
            onTap: _toggleAccordion,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_upward_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.complaint.upvotes}',
                    style: const TextStyle(
                      color: Color(0xFFFAFAFA),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 16,
                    color: Color(0xFFA1A1AA),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isExpanded ? 'Hide Details' : 'Discourse (${widget.complaint.comments.length})',
                    style: const TextStyle(
                      color: Color(0xFFA1A1AA),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xFFA1A1AA),
                  ),
                ],
              ),
            ),
          ),

          // In-line Accordion Expansion using basic AnimatedContainer with Curves.linear
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.linear,
            height: _isExpanded ? 130 : 0,
            width: double.infinity,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
              color: Color(0xFF121214), // slightly darker inset
            ),
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(color: Color(0xFF27272A), height: 1),
                    const SizedBox(height: 12),
                    // Pinned details (Google Maps deep-link comment placeholder)
                    InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.map_outlined, color: Color(0xFF3B82F6), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Pinned Evidence: ${widget.complaint.rtoCode} Municipal Sector • Open in Google Maps',
                                style: const TextStyle(
                                  color: Color(0xFF60A5FA),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Color(0xFF60A5FA),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Clean, centered gray placeholder text if no comments exist
                    Center(
                      child: Text(
                        widget.complaint.comments.isEmpty
                            ? 'No citizen discourse yet. Be the first to start the conversation.'
                            : '"${widget.complaint.comments.first}" — Verified Citizen',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF71717A), // Neutral gray placeholder
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
