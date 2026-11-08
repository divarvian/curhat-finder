import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:curhat_finder/core/widgets/app_skeleton.dart';

/// Widget Avatar Mandiri & Terpusat untuk Seluruh Aplikasi Curhat Finder.
/// Mendukung:
/// - Remote image URL dari Supabase Storage (`imageUrl`)
/// - Local file path untuk zero-flicker preview (`localPath`)
/// - Shimmer loading state selama pengunduhan gambar remote
/// - Fallback aman ke asset lokal saat URL kosong/gagal memuat
/// - Border kustom dan Online Presence Indicator Badge
class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? localPath;
  final double size;
  final String fallbackAsset;
  final BoxBorder? border;
  final bool isOnline;
  final bool showOnlineBadge;
  final double? badgeSize;
  final Color badgeColor;
  final Color badgeBorderColor;
  final double badgeBorderWidth;
  final BoxFit fit;
  final Color? backgroundColor;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.localPath,
    this.size = 48,
    this.fallbackAsset = 'assets/images/profile.png',
    this.border,
    this.backgroundColor = const Color(0xFFFCEDED),
    this.isOnline = false,
    this.showOnlineBadge = false,
    this.badgeSize,
    this.badgeColor = const Color(0xFF00E676),
    this.badgeBorderColor = Colors.white,
    this.badgeBorderWidth = 2,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBadgeSize = badgeSize ?? (size * 0.27).clamp(10.0, 24.0);

    Widget imageWidget = _buildImageContent();

    Widget avatarCircle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        border: border,
      ),
      child: ClipOval(
        child: imageWidget,
      ),
    );

    if (showOnlineBadge && isOnline) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          avatarCircle,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: effectiveBadgeSize,
              height: effectiveBadgeSize,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: badgeBorderColor,
                  width: badgeBorderWidth,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return avatarCircle;
  }

  Widget _buildImageContent() {
    // 1. Cek file lokal valid dari galeri/kamera untuk zero-flicker preview
    if (localPath != null &&
        localPath!.isNotEmpty &&
        !kIsWeb &&
        File(localPath!).existsSync()) {
      return Image.file(
        File(localPath!),
        fit: fit,
        width: size,
        height: size,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }

    // 2. Cek remote URL dari Supabase Storage
    final effectiveUrl = (imageUrl != null && imageUrl!.isNotEmpty)
        ? imageUrl
        : (localPath != null && localPath!.startsWith('http') ? localPath : null);

    if (effectiveUrl != null && effectiveUrl.isNotEmpty) {
      return Image.network(
        effectiveUrl,
        fit: fit,
        width: size,
        height: size,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return const AppShimmer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }

    // 3. Fallback ke asset default jika tidak ada gambar
    return _buildFallback();
  }

  Widget _buildFallback() {
    return Image.asset(
      fallbackAsset.isNotEmpty ? fallbackAsset : 'assets/images/profile.png',
      fit: fit,
      width: size,
      height: size,
    );
  }
}
