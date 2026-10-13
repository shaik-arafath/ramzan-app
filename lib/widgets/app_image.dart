import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppImage extends StatelessWidget {
  final String source;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final double iconSize;

  const AppImage({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.iconSize = 32,
  });

  bool get _isAsset {
    if (source.isEmpty) {
      return true;
    }

    final uri = Uri.tryParse(source);
    if (uri == null) {
      return true;
    }

    final scheme = uri.scheme.toLowerCase();
    return scheme != 'http' && scheme != 'https';
  }

  @override
  Widget build(BuildContext context) {
    if (source.trim().isEmpty) {
      return _buildFallback();
    }

    final image = _isAsset
        ? Image.asset(
            source,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, __, ___) => _buildFallback(),
          )
        : Image.network(
            source,
            width: width,
            height: height,
            fit: fit,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: width,
                height: height,
                color: AppColors.mediumBlack,
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                  color: AppColors.gold,
                ),
              );
            },
            errorBuilder: (_, __, ___) => _buildFallback(),
          );

    if (borderRadius == null) {
      return image;
    }

    return ClipRRect(
      borderRadius: borderRadius!,
      child: image,
    );
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      color: AppColors.mediumBlack,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported,
        size: iconSize,
        color: AppColors.silverDark,
      ),
    );
  }
}
