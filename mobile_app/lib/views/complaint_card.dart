import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/models/complaint.dart';
import 'package:mobile_app/providers/global_auth_provider.dart';
import 'package:mobile_app/views/discourse_section.dart';

// Riverpod 3 provider tracking if AI Satire Mode is toggled (simulated via shake or tap)
class SatireModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void setSatireMode(bool value) => state = value;
}

final satireModeProvider = NotifierProvider<SatireModeNotifier, bool>(SatireModeNotifier.new);
final isSatireModeProvider = satireModeProvider; // Alias for seamless compatibility

class ComplaintCard extends ConsumerStatefulWidget {
  final Complaint complaint;
  final bool suppressSatire;

  const ComplaintCard({
    super.key,
    required this.complaint,
    this.suppressSatire = false,
  });

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
    final authState = ref.watch(globalAuthProvider);
    final isGov = widget.suppressSatire || authState.role == UserRole.government;
    final isSatireMode = !isGov && ref.watch(satireModeProvider);
    final theme = Theme.of(context);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white, // Pure white surface (#FFFFFF)
        borderRadius: BorderRadius.circular(8), // Exactly 8dp rectangular boundary
        border: Border.all(
          color: const Color(0xFFDEE3E8), // Light-grey outline
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04), // Ethereal low-density shadow
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: RTO Code badge and timestamp
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4285F4).withValues(alpha: 0.10), // Translucent Google Blue fill
                    borderRadius: BorderRadius.circular(8), // 8dp boundary
                    border: Border.all(color: const Color(0xFF4285F4), width: 1.5), // Sharp 1.5dp blue outline
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Color(0xFF0058BD)),
                      const SizedBox(width: 4),
                      Text(
                        widget.complaint.rtoCode,
                        style: const TextStyle(
                          color: Color(0xFF0058BD),
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
                    color: Color(0xFF70757A), // Neutral secondary text
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Title & Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.complaint.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF171C20), // Off-black high legibility
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.complaint.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF424753), // Refined medium grey
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Image macro meme engine with smooth AnimatedCrossFade
          LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: constraints.maxWidth,
                height: 240,
                child: AnimatedCrossFade(
                  duration: const Duration(milliseconds: 350),
                  crossFadeState: isSatireMode ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  layoutBuilder: (topChild, topChildKey, bottomChild, bottomChildKey) {
                    return Stack(
                      clipBehavior: Clip.antiAlias,
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(key: bottomChildKey, child: bottomChild),
                        Positioned.fill(key: topChildKey, child: topChild),
                      ],
                    );
                  },
                  firstChild: _buildNormalImageView(constraints),
                  secondChild: _buildGhibliMemeView(constraints),
                ),
              );
            },
          ),

          // Footer Action Bar: Formal Administrative Actions for Gov or Citizen Discourse for Citizens
          if (isGov)
            _buildGovAdministrativeActions()
          else ...[
            InkWell(
              onTap: _toggleAccordion,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    const Icon(
                      Icons.thumb_up_alt_rounded,
                      size: 18,
                      color: Color(0xFF4285F4), // Google Blue icon
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.complaint.upvotes}',
                      style: const TextStyle(
                        color: Color(0xFF171C20),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 16,
                      color: Color(0xFF70757A),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isExpanded ? 'Hide Discourse' : 'Discourse (${widget.complaint.comments.length})',
                      style: const TextStyle(
                        color: Color(0xFF424753),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                      color: const Color(0xFF70757A),
                    ),
                  ],
                ),
              ),
            ),

            // In-line Accordion Expansion utilizing DiscourseSection
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: DiscourseSection(
                complaintId: widget.complaint.id,
                initialComments: widget.complaint.comments,
                rtoCode: widget.complaint.rtoCode,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGovAdministrativeActions() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFDEE3E8), width: 1.0)),
        color: Color(0xFFF8FAFC),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Inspector assigned to Municipal Case #${widget.complaint.rtoCode}')),
              );
            },
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 16, color: Color(0xFF0058BD)),
            label: const Text('Assign Inspector', style: TextStyle(color: Color(0xFF0058BD), fontSize: 12, fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF0058BD), width: 1.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Case #${widget.complaint.rtoCode} marked as Dispatched to Municipality')),
              );
            },
            icon: const Icon(Icons.local_shipping_rounded, size: 16, color: Colors.white),
            label: const Text('Mark Dispatched', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF137333),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  /// Normal infrastructure image view (StreetVoice Light UI)
  Widget _buildNormalImageView(BoxConstraints constraints) {
    return Container(
      width: constraints.maxWidth,
      height: 240,
      decoration: const BoxDecoration(color: Color(0xFFEAEEF4)),
      child: CachedNetworkImage(
        imageUrl: widget.complaint.imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildShimmerPlaceholder(),
        errorWidget: (context, url, error) => _buildErrorPlaceholder(),
      ),
    );
  }

  /// Cloud-baked Ghibli art meme asset view (rendered directly without local overlay widgets)
  Widget _buildGhibliMemeView(BoxConstraints constraints) {
    return Container(
      width: constraints.maxWidth,
      height: 240,
      decoration: const BoxDecoration(color: Color(0xFFEAEEF4)),
      child: CachedNetworkImage(
        imageUrl: widget.complaint.ghibliMemeUrl ?? widget.complaint.imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildShimmerPlaceholder(),
        errorWidget: (context, url, error) => _buildErrorPlaceholder(),
      ),
    );
  }

  /// Light-themed subtle shimmer loading placeholder block
  Widget _buildShimmerPlaceholder() {
    return Container(
      color: const Color(0xFFF1F5F9),
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4285F4)),
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Loading Cloud Asset...',
            style: TextStyle(
              color: Color(0xFF70757A),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: const Color(0xFFEAEEF4),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_outlined, color: Color(0xFF70757A), size: 36),
          SizedBox(height: 8),
          Text('Civic Evidence Photo Unavailable', style: TextStyle(color: Color(0xFF424753), fontSize: 12)),
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
