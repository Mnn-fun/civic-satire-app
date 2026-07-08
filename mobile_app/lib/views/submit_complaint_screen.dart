import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_app/services/cloudinary_service.dart';
import 'package:mobile_app/services/feed_network_service.dart';
import 'package:mobile_app/services/image_picker_service.dart';

/// Implicit touch feedback wrapper that micro-scales down to 0.96 using Curves.easeOutCubic on tap down
class PremiumTouchCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const PremiumTouchCard({super.key, required this.child, this.onTap, this.borderRadius});

  @override
  State<PremiumTouchCard> createState() => _PremiumTouchCardState();
}

class _PremiumTouchCardState extends State<PremiumTouchCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null ? null : (_) => setState(() => _isPressed = true),
      onTapUp: widget.onTap == null ? null : (_) {
        setState(() => _isPressed = false);
        widget.onTap!();
      },
      onTapCancel: widget.onTap == null ? null : () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

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

  XFile? _capturedImage;
  String? _demoImageUrl;
  String? _cloudinarySecureUrl;
  bool _isUploadingToCloudinary = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _rtoCodeController.dispose();
    super.dispose();
  }

  /// Prominent debug action: auto-fills realistic civic issue and Unsplash image
  void _autoFillPitchMock() {
    setState(() {
      _titleController.text = 'Massive Crater on SG Highway';
      _descriptionController.text = 'Unfinished drainage trench left wide open across all 3 fast lanes without reflective warning signs or barricades during monsoon commute.';
      _rtoCodeController.text = 'GJ-01';
      _demoImageUrl = 'https://images.unsplash.com/photo-1515162816999-a0c47dc192f7?auto=format&fit=crop&w=800&q=80';
      _capturedImage = null;
      _cloudinarySecureUrl = null;
      _isUploadingToCloudinary = false;
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFFFBBC04), size: 20),
            SizedBox(width: 10),
            Text('🪄 Pitch Mock Data Auto-Filled Successfully!', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF171C20))),
          ],
        ),
        backgroundColor: const Color(0xFFF6FAFF),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Color(0xFFDEE3E8), width: 1.5)),
      ),
    );
  }

  /// Displays interactive bottom modal popup sheet with camera and gallery selection
  void _showMediaPickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDEE3E8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Hazard Documentation Source',
                  style: TextStyle(color: Color(0xFF171C20), fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Upload real-time infrastructure defects directly to Cloudinary CDN',
                  style: TextStyle(color: Color(0xFF70757A), fontSize: 12),
                ),
                const SizedBox(height: 20),
                // Media attachment action block 1 wrapped in implicit micro-scale animation
                PremiumTouchCard(
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _pickAndUploadImage(fromCamera: true);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4285F4).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8), // 8dp boundary
                      border: Border.all(color: const Color(0xFF4285F4), width: 1.5),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.camera_alt_rounded, color: Color(0xFF0058BD), size: 24),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Take Real-time Photo 📸', style: TextStyle(color: Color(0xFF171C20), fontWeight: FontWeight.w700, fontSize: 14)),
                              Text('Capture geo-tagged hazard evidence with device camera', style: TextStyle(color: Color(0xFF424753), fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Media attachment action block 2 wrapped in implicit micro-scale animation
                PremiumTouchCard(
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _pickAndUploadImage(fromCamera: false);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF34A853).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8), // 8dp boundary
                      border: Border.all(color: const Color(0xFF34A853), width: 1.5),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.photo_library_rounded, color: Color(0xFF047857), size: 24),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pick from Local Device Gallery 🖼️', style: TextStyle(color: Color(0xFF171C20), fontWeight: FontWeight.w700, fontSize: 14)),
                              Text('Select high-resolution structural documentation', style: TextStyle(color: Color(0xFF424753), fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Orchestrates image picking via ImagePickerService and uploads to Cloudinary CDN
  Future<void> _pickAndUploadImage({required bool fromCamera}) async {
    try {
      final imagePickerService = ref.read(imagePickerServiceProvider);
      final XFile? file = await imagePickerService.pickImage(fromCamera);

      if (file == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No image selected. Operation cancelled.')),
          );
        }
        return;
      }

      setState(() {
        _capturedImage = file;
        _demoImageUrl = null;
        _cloudinarySecureUrl = null;
        _isUploadingToCloudinary = true;
      });

      final cloudinaryService = ref.read(cloudinaryServiceProvider);
      final secureUrl = await cloudinaryService.uploadToCloudinary(file);

      if (!mounted) return;

      setState(() {
        _cloudinarySecureUrl = secureUrl;
        _isUploadingToCloudinary = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.cloud_done_rounded, color: Color(0xFF34A853), size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text('Cloudinary Direct CDN Upload Successful!', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF171C20)))),
            ],
          ),
          backgroundColor: const Color(0xFFF6FAFF),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Color(0xFF34A853), width: 1.5)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUploadingToCloudinary = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e. Falling back to local device file preview.', style: const TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFFEA4335),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _submitToEdgeAgents() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    String targetImageUrl;
    if (_cloudinarySecureUrl != null && _cloudinarySecureUrl!.isNotEmpty) {
      targetImageUrl = _cloudinarySecureUrl!;
    } else if (_capturedImage != null) {
      targetImageUrl = 'https://images.unsplash.com/photo-1515162816999-a0c47dc192f7?auto=format&fit=crop&w=800&q=80';
    } else if (_demoImageUrl != null && _demoImageUrl!.isNotEmpty) {
      targetImageUrl = _demoImageUrl!;
    } else {
      targetImageUrl = 'https://images.unsplash.com/photo-1541888946425-d0ebb18086f6?auto=format&fit=crop&w=800&q=80';
    }

    try {
      await ref.read(feedNotifierProvider.notifier).submitComplaint(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        rtoCode: _rtoCodeController.text.trim().toUpperCase(),
        imageUrl: targetImageUrl,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF34A853), size: 20),
              SizedBox(width: 10),
              Expanded(child: Text('Complaint Transmitted to Edge Agents & Broadcasted!', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF171C20)))),
            ],
          ),
          backgroundColor: const Color(0xFFF6FAFF),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Color(0xFF34A853), width: 1.5)),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transmission Error: $e', style: const TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFFEA4335),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Solid white (#FFFFFF) Scaffold background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Report Civic Issue', style: TextStyle(color: Color(0xFF171C20), fontWeight: FontWeight.w700)),
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
                    avatar: const Icon(Icons.auto_awesome, color: Color(0xFFFBBC04), size: 18),
                    label: const Text(
                      '🪄 Auto-Fill Pitch Mock',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0058BD)),
                    ),
                    backgroundColor: const Color(0xFF4285F4).withValues(alpha: 0.08),
                    side: const BorderSide(color: Color(0xFF4285F4), width: 1.5), // 8dp rectangular boundary
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
                  style: const TextStyle(color: Color(0xFF171C20), fontWeight: FontWeight.w600),
                  decoration: _buildInputDecoration(
                    hintText: 'e.g., Massive Crater on SG Highway',
                    prefixIcon: Icons.title_rounded,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Please enter an issue title' : null,
                ),
                const SizedBox(height: 20),

                // RTO Code Input Field
                _buildSectionLabel('RTO Jurisdiction Code'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _rtoCodeController,
                  style: const TextStyle(color: Color(0xFF171C20), fontWeight: FontWeight.w700, letterSpacing: 1),
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
                  style: const TextStyle(color: Color(0xFF171C20), fontWeight: FontWeight.w400, height: 1.4),
                  decoration: _buildInputDecoration(
                    hintText: 'Describe the civic hazard, exact location, and structural details...',
                    prefixIcon: Icons.description_outlined,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a description' : null,
                ),
                const SizedBox(height: 24),

                // Interactive Infrastructure Image Preview Container
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionLabel('Infrastructure Image Preview (Tap Box to Capture)'),
                    if (_capturedImage != null || _demoImageUrl != null)
                      GestureDetector(
                        onTap: _isUploadingToCloudinary ? null : _showMediaPickerBottomSheet,
                        child: const Text(
                          'Change Photo',
                          style: TextStyle(color: Color(0xFF4285F4), fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                // Media attachment action block wrapped in implicit micro-scale animation (scale: 0.96 with Curves.easeOutCubic)
                PremiumTouchCard(
                  onTap: _isUploadingToCloudinary ? null : _showMediaPickerBottomSheet,
                  child: Container(
                    height: 230,
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAEEF4),
                      borderRadius: BorderRadius.circular(8), // Exactly 8dp rectangular boundary
                      border: Border.all(
                        color: _isUploadingToCloudinary
                            ? const Color(0xFF4285F4)
                            : (_cloudinarySecureUrl != null ? const Color(0xFF34A853) : const Color(0xFFDEE3E8)),
                        width: _isUploadingToCloudinary || _cloudinarySecureUrl != null ? 2.0 : 1.5,
                      ),
                    ),
                    child: _buildImagePreviewContent(),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit to Edge Agents Button (8dp rectangular boundary, translucent fill, sharp 1.5dp outline)
                ElevatedButton(
                  onPressed: _isSubmitting || _isUploadingToCloudinary ? null : _submitToEdgeAgents,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4285F4).withValues(alpha: 0.10),
                    disabledBackgroundColor: const Color(0xFFDEE3E8),
                    foregroundColor: const Color(0xFF0058BD),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Exactly 8dp boundary
                      side: const BorderSide(color: Color(0xFF4285F4), width: 1.5), // Sharp 1.5dp Google Blue outline
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.send_rounded, size: 20, color: Color(0xFF0058BD)),
                      const SizedBox(width: 10),
                      Text(
                        _isUploadingToCloudinary
                            ? 'Waiting for Cloudinary Upload...'
                            : (_isSubmitting ? 'Transmitting to Edge Agents...' : 'Submit to Edge Agents'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5),
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
      style: const TextStyle(color: Color(0xFF424753), fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.3),
    );
  }

  /// White rectangular shapes with light translucent gray boundaries (8dp radius)
  InputDecoration _buildInputDecoration({required String hintText, required IconData prefixIcon}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white, // White rectangular shape
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF70757A), fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF70757A)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8), // Exactly 8dp radius
        borderSide: const BorderSide(color: Color(0xFFDEE3E8), width: 1.5), // Light translucent gray boundary
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDEE3E8), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF4285F4), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFEA4335), width: 1.5),
      ),
    );
  }

  Widget _buildImagePreviewContent() {
    if (_isUploadingToCloudinary) {
      return Stack(
        fit: StackFit.expand,
        children: [
          if (_capturedImage != null)
            Image.file(
              io.File(_capturedImage!.path),
              fit: BoxFit.cover,
            ),
          Container(
            color: Colors.white.withValues(alpha: 0.85),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Color(0xFF4285F4), strokeWidth: 3.5),
                const SizedBox(height: 16),
                const Text(
                  'Uploading to Cloudinary CDN...',
                  style: TextStyle(color: Color(0xFF171C20), fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  _capturedImage?.name ?? 'Processing media file...',
                  style: const TextStyle(color: Color(0xFF424753), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_cloudinarySecureUrl != null && _cloudinarySecureUrl!.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            _cloudinarySecureUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image_outlined, color: Color(0xFFEA4335), size: 40),
                  SizedBox(height: 8),
                  Text('Failed to load Cloudinary asset', style: TextStyle(color: Color(0xFFEA4335), fontSize: 13)),
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
                  color: const Color(0xFF4285F4),
                ),
              );
            },
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: _buildValidationBadge('Cloudinary CDN Asset Live ⚡', isSuccess: true),
          ),
        ],
      );
    }

    if (_capturedImage != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            io.File(_capturedImage!.path),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.broken_image_outlined, color: Color(0xFFEA4335), size: 40),
                  const SizedBox(height: 8),
                  const Text('Failed to render device media', style: TextStyle(color: Color(0xFFEA4335), fontSize: 13)),
                  Text(_capturedImage!.path, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF70757A), fontSize: 11)),
                ],
              );
            },
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: _buildValidationBadge('Local Device Media (${_capturedImage!.name})', isSuccess: true),
          ),
        ],
      );
    }

    if (_demoImageUrl != null && _demoImageUrl!.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            _demoImageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.broken_image_outlined, color: Color(0xFFEA4335), size: 40),
                  const SizedBox(height: 8),
                  const Text('Failed to load demo image', style: TextStyle(color: Color(0xFFEA4335), fontSize: 13)),
                  Text(_demoImageUrl!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF70757A), fontSize: 11)),
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
                  color: const Color(0xFF4285F4),
                ),
              );
            },
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: _buildValidationBadge('Pitch Mock Media Loaded', isSuccess: true),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.add_a_photo_outlined, color: Color(0xFF4285F4), size: 48),
        const SizedBox(height: 12),
        const Text(
          'Tap Box to Select Hazard Media',
          style: TextStyle(color: Color(0xFF171C20), fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        const Text(
          'Choose between real-time camera capture or device gallery',
          style: TextStyle(color: Color(0xFF424753), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildValidationBadge(String label, {bool isSuccess = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isSuccess ? const Color(0xFF34A853).withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isSuccess ? const Color(0xFF34A853) : const Color(0xFF4285F4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
