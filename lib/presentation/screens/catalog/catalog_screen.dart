import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/presentation/widgets/shared/product_image.dart';
import 'package:jumpup_app/presentation/providers/cart/cart_provider.dart';
import 'package:jumpup_app/presentation/providers/course_providers.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';

class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Catálogo de Cursos'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => context.push('/cart'),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: AppColors.secondary,
                  child: Text(
                    '${ref.watch(cartProvider).itemCount}',
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: coursesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('No se pudieron cargar los cursos',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => ref.invalidate(coursesProvider),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Reintentar'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        data: (courses) {
          if (courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.school_outlined,
                      size: 64, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text('No hay cursos disponibles',
                      style: AppTextStyles.titleMedium
                          .copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text('Vuelve pronto para ver nuevos cursos.',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textHint)),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return FadeInUp(
                delay: Duration(milliseconds: index * 80),
                child: _CourseCard(course: course),
              );
            },
          );
        },
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final dynamic course; // CourseModel
  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ProductImage(
              imageUrl: course.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (course.languageName.isNotEmpty)
                  Text(
                    course.languageName,
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.secondary),
                  ),
                const SizedBox(height: 4),
                Text(
                  course.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelLarge
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.signal_cellular_alt_rounded,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      course.difficultyLevel,
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const Spacer(),
                    if (course.lessonsCount > 0)
                      Text(
                        '${course.lessonsCount} lecciones',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.textHint),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
