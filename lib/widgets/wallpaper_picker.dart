import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

typedef WallpaperCallback = void Function(File wallpaperFile);

class WallpaperPicker {
  static final ImagePicker _picker = ImagePicker();

  /// Pick a wallpaper image from gallery or camera
  static Future<File?> pickWallpaper({
    bool fromCamera = false,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      debugPrint('Error picking wallpaper: $e');
    }
    return null;
  }

  /// Show a dialog to pick wallpaper
  static Future<File?> showWallpaperDialog(BuildContext context) async {
    File? selectedFile;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF12121A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Choose Wallpaper',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _WallpaperOption(
                    icon: Icons.image_outlined,
                    label: 'Gallery',
                    onTap: () async {
                      selectedFile = await pickWallpaper(fromCamera: false);
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _WallpaperOption(
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    onTap: () async {
                      selectedFile = await pickWallpaper(fromCamera: true);
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return selectedFile;
  }
}

class _WallpaperOption extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _WallpaperOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_WallpaperOption> createState() => _WallpaperOptionState();
}

class _WallpaperOptionState extends State<_WallpaperOption> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFF1A1A2E) : const Color(0xFF0A0A0F),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? const Color(0xFF6C63FF)
                  : Colors.white.withAlpha(20),
              width: _isHovered ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: _isHovered
                    ? const Color(0xFF6C63FF)
                    : Colors.white60,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: _isHovered
                      ? const Color(0xFF6C63FF)
                      : Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
