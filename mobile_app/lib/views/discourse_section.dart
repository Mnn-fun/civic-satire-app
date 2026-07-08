import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Clean, light-themed DiscourseSection widget that integrates seamlessly
/// under the National Feed complaint card design framework.
class DiscourseSection extends ConsumerStatefulWidget {
  final String complaintId;
  final List<String> initialComments;
  final String? rtoCode;

  const DiscourseSection({
    super.key,
    required this.complaintId,
    this.initialComments = const [],
    this.rtoCode,
  });

  @override
  ConsumerState<DiscourseSection> createState() => _DiscourseSectionState();
}

class _DiscourseSectionState extends ConsumerState<DiscourseSection> {
  late List<String> _comments;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _comments = List.from(widget.initialComments);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _comments.add(text);
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Pinned Link Bar
          _buildPinnedLinkBar(),
          const SizedBox(height: 14),

          // 2. Comments List
          _buildCommentsList(),
          const SizedBox(height: 16),

          // 3. Input Tray
          _buildInputTray(),
        ],
      ),
    );
  }

  /// Pinned Link Bar: interactive text action button with neutral gray icon
  /// representing pinned Google Maps deep-link for geo-validation tracking.
  Widget _buildPinnedLinkBar() {
    return InkWell(
      onTap: () {
        // Placeholder for Google Maps deep-link execution
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: Color(0xFF64748B),
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Pinned Evidence: ${widget.rtoCode ?? "Geo-Validation"} Tracker • Open in Google Maps',
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFF64748B),
                ),
              ),
            ),
            const Icon(
              Icons.open_in_new_rounded,
              color: Color(0xFF94A3B8),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  /// Comments List: renders existing community remarks utilizing high-contrast,
  /// clean typography or elegant centered placeholder text.
  Widget _buildCommentsList() {
    if (_comments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        ),
        child: const Center(
          child: Text(
            'No community remarks yet. Tap to start the discussion.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _comments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final comment = _comments[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Verified Citizen',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    index == _comments.length - 1 ? 'Just now' : 'Earlier',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                comment,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Input Tray: text field matching light theme borders with send icon button.
  Widget _buildInputTray() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _commentController,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Add a remark for municipal verification...',
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 13,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFF4285F4), width: 1.5),
              ),
            ),
            onSubmitted: (_) => _submitComment(),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: _submitComment,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFF4285F4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.send_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}
