import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? fullName;
  final double radius;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.fullName,
    this.radius = 24,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(fullName);
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.primaryColor.withValues(alpha: 0.1),
        ),
        child: ClipOval(
          child: (imageUrl != null && imageUrl!.isNotEmpty)
              ? CachedNetworkImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.cover,
                  memCacheWidth: (radius * 4).toInt(),
                  memCacheHeight: (radius * 4).toInt(),
                  placeholder: (context, url) => _InitialsWidget(
                    initials: initials,
                    radius: radius,
                    color: theme.primaryColor,
                  ),
                  errorWidget: (context, url, error) => _InitialsWidget(
                    initials: initials,
                    radius: radius,
                    color: theme.primaryColor,
                  ),
                )
              : _InitialsWidget(
                  initials: initials,
                  radius: radius,
                  color: theme.primaryColor,
                ),
        ),
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return 'U';
    final trimmedName = name.trim();
    final parts = trimmedName.split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmedName.isNotEmpty ? trimmedName[0].toUpperCase() : 'U';
  }
}

class _InitialsWidget extends StatelessWidget {
  final String initials;
  final double radius;
  final Color color;

  const _InitialsWidget({
    required this.initials,
    required this.radius,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.7,
        ),
      ),
    );
  }
}
