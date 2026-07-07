import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Expert media capture service utilizing the image_picker package
class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Captures an image from either the native camera or system gallery.
  /// If [fromCamera] is true, launches [ImageSource.camera]; otherwise launches [ImageSource.gallery].
  /// Returns an [XFile?] object, handling cancellations and permission blocks gracefully without throwing exceptions.
  Future<XFile?> pickImage(bool fromCamera) async {
    final source = fromCamera ? ImageSource.camera : ImageSource.gallery;
    developer.log(
      '[ImagePickerService] Launching media capture via ${source.name.toUpperCase()}...',
      name: 'ImagePickerService',
    );

    try {
      // Launch native picker with optimized image quality
      final XFile? capturedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (capturedFile == null) {
        // Handle user cancellation gracefully
        developer.log(
          '[ImagePickerService] Media selection cancelled by user. No file captured.',
          name: 'ImagePickerService',
        );
        return null;
      }

      // Log selection success with file telemetry
      developer.log(
        '[ImagePickerService] Selection SUCCESS! Captured file: "${capturedFile.name}" at path: ${capturedFile.path}',
        name: 'ImagePickerService',
      );
      return capturedFile;
    } on PlatformException catch (e) {
      // Handle permission blocks or hardware access failures gracefully
      developer.log(
        '[ImagePickerService] PERMISSION BLOCK OR HARDWARE FAILURE: Unable to access ${source.name}. Error: ${e.message} (${e.code})',
        name: 'ImagePickerService',
        error: e,
      );
      return null;
    } catch (e) {
      // Catch-all for any runtime exceptions without propagating null errors
      developer.log(
        '[ImagePickerService] Unexpected exception during image selection: $e',
        name: 'ImagePickerService',
        error: e,
      );
      return null;
    }
  }
}

/// Global Riverpod Provider exposing the ImagePickerService instance
final imagePickerServiceProvider = Provider<ImagePickerService>((ref) => ImagePickerService());
