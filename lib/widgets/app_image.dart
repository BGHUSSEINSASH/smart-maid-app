import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/adaptive.dart';
import '../../core/theme/app_theme.dart';

class AppImage extends StatelessWidget {
  final String url;
  final double? width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AppImage({
    super.key,
    required this.url,
    this.width,
    this.height = 84,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final image = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, _) => Container(
        width: width,
        height: height,
        color: context.isDark ? Colors.white10 : const Color(0xFFE9EDF7),
      ),
      errorWidget: (_, _, _) => Container(
        width: width,
        height: height,
        color: context.isDark ? Colors.white10 : const Color(0xFFE9EDF7),
        child: Icon(Icons.person_rounded,
            size: height * 0.45,
            color: context.isDark ? Colors.white38 : AppColors.muted),
      ),
    );
    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}

/// صورة شخصية مع بديل بالأحرف الأولى.
///
/// التطبيق لا يستخدم صور أشخاص حقيقيين من الإنترنت؛ وعند عدم وجود صورة
/// يُعرض الحرف الأول من الاسم بدل رابط خارجي (Apple 5.1.2 / Play User Data).
class AppAvatar extends StatelessWidget {
  final String url;
  final double radius;
  final String label;

  const AppAvatar({
    super.key,
    required this.url,
    this.radius = 24,
    this.label = '',
  });

  String get _initials {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return '؟';
    final parts = trimmed.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.take(2).map((p) => p.characters.first).join();
  }

  @override
  Widget build(BuildContext context) {
    final background =
        context.isDark ? Colors.white10 : const Color(0xFFE9EDF7);
    if (url.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: background,
        child: Text(
          _initials,
          style: TextStyle(
            fontSize: radius * 0.7,
            fontWeight: FontWeight.w800,
            color: context.isDark ? Colors.white70 : AppColors.primary,
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: background,
      backgroundImage: NetworkImage(url),
      onBackgroundImageError: (_, _) {},
      child: const SizedBox.shrink(),
    );
  }
}
