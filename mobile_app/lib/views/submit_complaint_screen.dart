import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/services/feed_network_service.dart';

class SubmitComplaintScreen extends ConsumerStatefulWidget {
  const SubmitComplaintScreen({super.key});

  @override
  ConsumerState<SubmitComplaintScreen> createState() => _SubmitComplaintScreenState();
}

class _SubmitComplaintScreenState extends ConsumerState<SubmitComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rtoCodeController = TextEditingController();
  final _imageUrlController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _rtoCodeController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  /// Prominent debug action: auto-fills realistic civic issue and Unsplash image
  void _autoFillPitchMock() {
    setState(() {
      _titleController.text = 'Massive Crater on SG Highway';
      _descriptionController.text = 'Unfinished drainage trench left wide open across all 3 fast lanes without reflective warning signs or barricades during monsoon commute.';
      _rtoCodeController.text = 'GJ-01';
      _imageUrlController.text = 'https://images.unsplash.com/photo-1515162816999-a0c47dc192f7?auto=format&fit=crop&w=800&q=80';
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
            SizedBox(width: 10),
            Text('🪄 Pitch Mock Data Auto-Filled Successfully!', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
          ],
        ),
        backgroundColor: const Color(0xFF27272A),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Triggers async POST request to Stitch HTTP endpoint with modal loading indicator
  Future<void> _submitToEdgeAgents() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Show modal loading indicator during network flight
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFF18181B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF3F3F46), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Color(0xFFE11D48)),
                const SizedBox(height: 20),
                const Text(
                  'Transmitting to Edge Agents...',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'AI Vision & Satirical Copywriter evaluation in progress for ${_rtoCodeController.text.trim()}...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 13),
                ),
              ],
            ),
          ),
        );
      },
    );

    setState(() {
      _isSubmitting = true;
    });

    final success = await ref.read(feedNotifierProvider.notifier).submitComplaint(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          rtoCode: _rtoCodeController.text.trim().toUpperCase(),
          imageUrl: _imageUrlController.text.trim(),
        );

    if (!mounted) return;
    
    // Pop modal loading dialog
    Navigator.of(context).pop();

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Complaint broadcasted! AI Edge Agents have synthesized satirical copy for ${_rtoCodeController.text.trim()}.',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF18181B),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Color(0xFF3F3F46))),
        ),
      );
      // Return to National Feed screen
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to submit complaint to Stitch endpoint. Please retry.', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF18181B),
        elevation: 0,
        title: const Text('Report Civic Issue', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Prominent Action Chip for Debug / Demo Pitch Auto-Fill
                Align(
                  alignment: Alignment.centerRight,
                  child: ActionChip(
                    avatar: const Icon(Icons.auto_awesome, color: Colors.amber, size: 18),
                    label: const Text(
                      '🪄 Auto-Fill Pitch Mock',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white),
                    ),
                    backgroundColor: const Color(0xFF27272A),
                    side: const BorderSide(color: Color(0xFFE11D48), width: 1.2),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    onPressed: _autoFillPitchMock,
                  ),
                ),
                const SizedBox(height: 20),

                // Title Input Field
                _buildSectionLabel('Issue Title'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration(
                    hintText: 'e.g., Massive Crater on SG Highway',
                    prefixIcon: Icons.title,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Please enter an issue title' : null,
                ),
                const SizedBox(height: 20),

                // RTO Code Input Field
                _buildSectionLabel('RTO Jurisdiction Code'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _rtoCodeController,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 1),
                  textCapitalization: TextCapitalization.characters,
                  decoration: _buildInputDecoration(
                    hintText: 'e.g., GJ-01, MH-01, DL-01',
                    prefixIcon: Icons.location_on_outlined,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Please enter target RTO code' : null,
                ),
                const SizedBox(height: 20),

                // Description Input Field
                _buildSectionLabel('Detailed Description'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration(
                    hintText: 'Describe the civic hazard, exact location, and structural details...',
                    prefixIcon: Icons.description_outlined,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a description' : null,
                ),
                const SizedBox(height: 20),

                // Image URL Input Field
                _buildSectionLabel('Image Infrastructure URL (Unsplash / Cloud)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _imageUrlController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: _buildInputDecoration(
                    hintText: 'https://images.unsplash.com/...',
                    prefixIcon: Icons.image_outlined,
                  ),
                  onChanged: (val) {
                    setState(() {}); // Trigger rebuild to update image preview container
                  },
                ),
                const SizedBox(height: 24),

                // High-visibility Image Preview Box
                _buildSectionLabel('Infrastructure Image Preview'),
                const SizedBox(height: 8),
                Container(
                  height: 200,
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: const Color(0xFF18181B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF3F3F46), width: 1.5),
                  ),
                  child: _buildImagePreviewContent(),
                ),
                const SizedBox(height: 32),

                // Submit to Edge Agents Button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitToEdgeAgents,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE11D48),
                    disabledBackgroundColor: const Color(0xFFE11D48).withValues(alpha: 0.5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.send_rounded, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        _isSubmitting ? 'Transmitting to Edge Agents...' : 'Submit to Edge Agents',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5),
    );
  }

  InputDecoration _buildInputDecoration({required String hintText, required IconData prefixIcon}) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF18181B),
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF52525B), fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF71717A)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF3F3F46), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF3F3F46), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE11D48), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
    );
  }

  Widget _buildImagePreviewContent() {
    final url = _imageUrlController.text.trim();
    if (url.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade700, size: 48),
          const SizedBox(height: 12),
          const Text(
            'No Image Loaded',
            style: TextStyle(color: Color(0xFF71717A), fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'Enter a URL above or tap "🪄 Auto-Fill Pitch Mock"',
            style: TextStyle(color: Color(0xFF52525B), fontSize: 12),
          ),
        ],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.broken_image_outlined, color: Colors.redAccent, size: 40),
                const SizedBox(height: 8),
                const Text('Failed to load image URL', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                Text(url, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF71717A), fontSize: 11)),
              ],
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                color: const Color(0xFFE11D48),
              ),
            );
          },
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF3F3F46)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.greenAccent, size: 14),
                SizedBox(width: 6),
                Text('Image Validated', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
