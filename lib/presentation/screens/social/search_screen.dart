import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/social_media_models.dart';
import 'package:jumpup_app/presentation/providers/social_providers.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> with AutomaticKeepAliveClientMixin {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final resultsAsync = ref.watch(searchResultsProvider(_query));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white54 : Colors.black54;
    final hintColor = isDark ? Colors.white38 : Colors.black38;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Column(
          children: [
            GlassContainer(
              opacity: isDark ? 0.06 : 0.08,
              blur: 24,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              borderRadius: BorderRadius.circular(20),
              child: TextField(
                controller: _searchController,
                autofocus: false,
                style: AppTextStyles.bodyMedium.copyWith(color: textColor, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Buscar cursos, lecciones, personas...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: hintColor),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF2575FC)),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, color: hintColor),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  filled: false,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onChanged: (v) => setState(() => _query = v.trim()),
                onSubmitted: (v) => setState(() => _query = v.trim()),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _query.isEmpty
                  ? _buildPlaceholder(isDark, textColor, subtextColor)
                  : resultsAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF6A11CB))),
                      error: (e, _) => Center(
                        child: Text('Error: $e',
                            style: AppTextStyles.bodyMedium.copyWith(color: Colors.redAccent)),
                      ),
                      data: (results) {
                        if (results.isEmpty) return _buildNoResults(isDark);
                        return ListView.separated(
                          padding: const EdgeInsets.only(bottom: 100),
                          physics: const BouncingScrollPhysics(),
                          itemCount: results.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) =>
                              _SearchResultTile(result: results[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark, Color textColor, Color subtextColor) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6A11CB).withValues(alpha: 0.1),
                  const Color(0xFF2575FC).withValues(alpha: 0.1),
                ],
              ),
            ),
            child: const Icon(Icons.search_rounded, size: 56, color: Color(0xFF2575FC)),
          ),
          const SizedBox(height: 24),
          Text('Busca en JumpUp',
              style: AppTextStyles.headlineSmall.copyWith(
                color: textColor, 
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              )),
          const SizedBox(height: 8),
          Text('Encuentra cursos, lecciones y personas',
              style: AppTextStyles.bodyMedium.copyWith(color: subtextColor)),
        ],
      ),
    );
  }

  Widget _buildNoResults(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: isDark ? Colors.white24 : Colors.black26),
          const SizedBox(height: 12),
          Text('Sin resultados para "$_query"',
              style: AppTextStyles.titleMedium.copyWith(
                  color: isDark ? Colors.white38 : Colors.black38)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white54 : Colors.black54;

    final icon = switch (result.type) {
      'course' || 'cursos' => Icons.book_rounded,
      'lesson' || 'lecciones' => Icons.play_circle_rounded,
      'user' || 'profile' => Icons.person_rounded,
      'forum' || 'foro' => Icons.forum_rounded,
      'live-session' || 'sesiones' => Icons.live_tv_rounded,
      _ => Icons.article_rounded,
    };

    return GlassContainer(
      opacity: isDark ? 0.06 : 0.08,
      blur: 24,
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(20),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF6A11CB).withValues(alpha: 0.1),
          ),
          child: Icon(icon, color: const Color(0xFF2575FC), size: 24),
        ),
        title: Text(result.title,
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w800, 
              color: textColor,
              letterSpacing: -0.3,
            )),
        subtitle: result.subtitle != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(result.subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(color: subtextColor, fontWeight: FontWeight.w500)),
              )
            : null,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF6A11CB).withValues(alpha: 0.2),
                const Color(0xFF2575FC).withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            result.type[0].toUpperCase() + result.type.substring(1),
            style: AppTextStyles.labelSmall.copyWith(
                color: const Color(0xFF2575FC), fontWeight: FontWeight.w900, fontSize: 10),
          ),
        ),
        onTap: () {},
      ),
    );
  }
}
