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
    
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
        backgroundImage: (imageUrl != null && imageUrl!.isNotEmpty)
            ? CachedNetworkImageProvider(imageUrl!)
            : null,
        child: (imageUrl == null || imageUrl!.isEmpty)
            ? Text(
                initials,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: radius * 0.8,
                ),
              )
            : null,
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}
