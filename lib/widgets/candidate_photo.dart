import 'package:flutter/material.dart';
import '../../services/data_service.dart';

/// Returns the correct ImageProvider based on the imagePath format:
/// - 'memory://id' → MemoryImage from DataService cache
/// - 'http...'     → NetworkImage
/// - else          → AssetImage (local assets)
ImageProvider getImageProvider(String imagePath) {
  final ds = DataService();
  if (imagePath.startsWith('memory://')) {
    final id = imagePath.replaceFirst('memory://', '');
    final bytes = ds.getImageBytes(id);
    if (bytes != null) return MemoryImage(bytes);
  }
  if (imagePath.startsWith('http')) return NetworkImage(imagePath);
  return AssetImage(imagePath);
}

/// Widget that shows a candidate photo correctly regardless of source
class CandidatePhoto extends StatelessWidget {
  final String imagePath;
  final double height;
  final double? width;
  final BorderRadius? borderRadius;
  final Alignment alignment;

  const CandidatePhoto({
    super.key,
    required this.imagePath,
    this.height = 200,
    this.width,
    this.borderRadius,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath.isEmpty) return const SizedBox.shrink();

    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        image: DecorationImage(
          image: getImageProvider(imagePath),
          fit: BoxFit.cover,
          alignment: alignment,
        ),
      ),
    );
  }
}
