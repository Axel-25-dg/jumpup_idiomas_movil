import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jumpup_app/core/config/app_config.dart';
import 'shimmer_loading.dart';

class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final String? seed;
  final double width;
  final double height;
  final BoxFit fit;

  static const List<String> _themeImages = [
    'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?q=80&w=1000&auto=format&fit=crop', // Books, studying
    'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?q=80&w=1000&auto=format&fit=crop', // Student writing, studying
    'https://images.unsplash.com/photo-1513001900722-370f803f498d?q=80&w=1000&auto=format&fit=crop', // Library, books stacked
    'https://images.unsplash.com/photo-1506784983877-45594efa4cbe?q=80&w=1000&auto=format&fit=crop', // Work/study desk with notes
    'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?q=80&w=1000&auto=format&fit=crop', // Bookshelf and globes
    'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?q=80&w=1000&auto=format&fit=crop', // Students working together
    'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?q=80&w=1000&auto=format&fit=crop', // E-learning / Laptop
    'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?q=80&w=1000&auto=format&fit=crop', // Colorful stack of books
    'https://images.unsplash.com/photo-1501504905252-473c47e087f8?q=80&w=1000&auto=format&fit=crop', // Studying desk
    'https://images.unsplash.com/photo-1491841573190-73f1d8c11e7b?q=80&w=1000&auto=format&fit=crop', // Library table
    'https://images.unsplash.com/photo-1509062522246-3755977927d7?q=80&w=1000&auto=format&fit=crop', // Classroom blackboard
    'https://images.unsplash.com/photo-1516979187457-637abb4f9353?q=80&w=1000&auto=format&fit=crop', // Open book
    'https://images.unsplash.com/photo-1488190211105-8b0e65b80b4e?q=80&w=1000&auto=format&fit=crop', // Notebook and pencil
    'https://images.unsplash.com/photo-1517842645767-c639042777db?q=80&w=1000&auto=format&fit=crop', // Notepad and coffee
    'https://images.unsplash.com/photo-1510070112810-d4e9a46d9e91?q=80&w=1000&auto=format&fit=crop', // Studying outdoors
    'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?q=80&w=1000&auto=format&fit=crop', // Books
    'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?q=80&w=1000&auto=format&fit=crop', // Stack of books on table
    'https://images.unsplash.com/photo-1523240795612-9a054b0db644?q=80&w=1000&auto=format&fit=crop', // Group studying/laughing
    'https://images.unsplash.com/photo-1516534775068-ba3e84589d90?q=80&w=1000&auto=format&fit=crop', // Studying with tablet
    'https://images.unsplash.com/photo-1580582932707-520aed937b7b?q=80&w=1000&auto=format&fit=crop', // Classroom desks
    'https://images.unsplash.com/photo-1513258496099-48168024aec0?q=80&w=1000&auto=format&fit=crop', // Writing in classroom
    'https://images.unsplash.com/photo-1527891751199-7225231a68dd?q=80&w=1000&auto=format&fit=crop', // Map/globes/travel
    'https://images.unsplash.com/photo-1473186578172-c141e6798cf4?q=80&w=1000&auto=format&fit=crop', // Study desk notebook
    'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?q=80&w=1000&auto=format&fit=crop', // Teacher writing
  ];

  const ProductImage({
    super.key,
    this.imageUrl,
    this.seed,
    this.width = double.infinity,
    this.height = 200,
    this.fit = BoxFit.cover,
  });

  int _djb2Hash(String str) {
    int hash = 5381;
    for (int i = 0; i < str.length; i++) {
      hash = ((hash << 5) + hash) + str.codeUnitAt(i);
    }
    return hash;
  }

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = AppConfig.resolveImageUrl(imageUrl);
    final isDefaultOrEmpty = resolvedUrl.isEmpty || 
        resolvedUrl == 'https://images.unsplash.com/photo-1546410531-bb4caa6b424d?q=80&w=1000&auto=format&fit=crop';
    
    String displayUrl = resolvedUrl;
    if (isDefaultOrEmpty) {
      if (seed != null && seed!.isNotEmpty) {
        final hashVal = _djb2Hash(seed!);
        final index = hashVal.abs() % _themeImages.length;
        displayUrl = _themeImages[index];
      } else {
        displayUrl = 'https://images.unsplash.com/photo-1546410531-bb4caa6b424d?q=80&w=1000&auto=format&fit=crop';
      }
    }

    return CachedNetworkImage(
      imageUrl: displayUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => ShimmerLoading(
        isLoading: true,
        child: Container(
          width: width,
          height: height,
          color: Colors.grey[300],
        ),
      ),
      errorWidget: (context, url, error) => _buildPlaceholder(context),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      color: isDark ? Colors.grey[800] : Colors.grey[200],
      child: Icon(
        Icons.image_not_supported_outlined,
        color: isDark ? Colors.grey[600] : Colors.grey,
        size: 40,
      ),
    );
  }
}
