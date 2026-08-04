import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';

/// A resilient image container that shows a BlurHash placeholder
/// while progressively loading the high-resolution network image.
class ResilientImageContainer extends StatelessWidget {
  final String? imageUrl;
  final String? blurHash;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ResilientImageContainer({
    super.key,
    this.imageUrl,
    this.blurHash,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // BlurHash placeholder (shown immediately)
            if (blurHash != null && blurHash!.isNotEmpty)
              BlurHash(hash: blurHash!)
            else
              _buildDefaultPlaceholder(),
            
            // Network image (loaded progressively)
            CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: fit,
              width: width,
              height: height,
              placeholder: (context, url) => const SizedBox.shrink(),
              errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget(),
              fadeInDuration: const Duration(milliseconds: 300),
              fadeOutDuration: const Duration(milliseconds: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.clayLight,
        borderRadius: borderRadius,
      ),
      child: placeholder ?? _buildDefaultPlaceholder(),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppTheme.clayLight,
      child: const Center(
        child: Icon(
          Icons.auto_stories_rounded,
          size: 48,
          color: AppTheme.warmGray,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: AppTheme.clayLight,
      child: const Center(
        child: Icon(
          Icons.error_outline_rounded,
          size: 32,
          color: AppTheme.warmGray,
        ),
      ),
    );
  }
}

/// Simple story card image with BlurHash support
class StoryImage extends StatelessWidget {
  final String? imageUrl;
  final String? blurHash;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const StoryImage({
    super.key,
    this.imageUrl,
    this.blurHash,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ResilientImageContainer(
      imageUrl: imageUrl,
      blurHash: blurHash,
      width: width,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      fit: BoxFit.cover,
    );
  }
}
