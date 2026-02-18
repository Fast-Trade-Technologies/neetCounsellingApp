import 'package:flutter/material.dart';

import '../storage/app_storage.dart';
import 'app_asset_image.dart';

/// Profile image widget that shows network image from [AppStorage.userImageUrl] if available,
/// otherwise shows placeholder asset image.
class ProfileImage extends StatelessWidget {
  const ProfileImage({
    super.key,
    required this.size,
    this.placeholderAsset,
    this.fit,
    this.imageUrl,
  });

  final double size;
  final String? placeholderAsset;
  final BoxFit? fit;
  /// Optional imageUrl override. If null, reads from AppStorage.userImageUrl.
  final String? imageUrl;

  static const String _defaultPlaceholder = 'assets/auth/login-asset.jpg';

  @override
  Widget build(BuildContext context) {
    final url = imageUrl ?? AppStorage.userImageUrl;
    final hasImage = url != null && url.trim().isNotEmpty;

    if (hasImage) {
      return ClipOval(
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: fit ?? BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              width: size,
              height: size,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                  color: Colors.blue,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder();
          },
        ),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return ClipOval(
      child: AppAssetImage(
        placeholderAsset ?? _defaultPlaceholder,
        width: size,
        height: size,
        fit: fit ?? BoxFit.cover,
      ),
    );
  }
}
