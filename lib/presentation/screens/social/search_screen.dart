import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/social_media_models.dart';
import 'package:jumpup_app/presentation/providers/social_providers.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/theme/text_styles.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(searchResultsProvider(_query));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Buscar cursos, lecciones, personas...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              onChanged: (v) => setState(() => _query = v.trim()),
              onSubmitted: (v) => setState(() => _query = v.trim()),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _query.isEmpty
                  ? _buildPlaceholder()
                  : resultsAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                      error: (e, _) => Center(
                        child: Text('Error: $e', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
                      ),
                      data: (results) {
                        if (results.isEmpty) return _buildNoResults();
                        return ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (context, index) => _SearchResultTile(result: results[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
            child: Icon(Icons.search_rounded, size: 56, color: AppColors.primary.withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 16),
          Text('Busca en JumpUp', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text('Encuentra cursos, lecciones y personas',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text('Sin resultados para "$_query"',
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({required this.result});
  final SearchResult result;

  @override
  Widget build(BuildContext context) {
    final icon = switch (result.type) {
      'course' || 'cursos' => Icons.book_rounded,
      'lesson' || 'lecciones' => Icons.play_circle_rounded,
      'user' || 'profile' => Icons.person_rounded,
      'forum' || 'foro' => Icons.forum_rounded,
      'live-session' || 'sesiones' => Icons.live_tv_rounded,
      _ => Icons.article_rounded,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        title: Text(result.title,
            style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        subtitle: result.subtitle != null
            ? Text(result.subtitle!,
                maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.bodySmall)
            : null,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            result.type[0].toUpperCase() + result.type.substring(1),
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
          ),
        ),
        onTap: () {},
      ),
    );
  }
}
