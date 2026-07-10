import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/social_media_models.dart';
import 'package:jumpup_app/presentation/providers/social_providers.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

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
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Column(
          children: [
            GlassContainer(
              opacity: 0.1,
              blur: 15,
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(16),
              child: TextField(
                controller: _searchController,
                autofocus: false,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Buscar cursos, lecciones, personas...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white38),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF7C4DFF)),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: Colors.white38),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  filled: false,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: (v) => setState(() => _query = v.trim()),
                onSubmitted: (v) => setState(() => _query = v.trim()),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _query.isEmpty
                  ? _buildPlaceholder()
                  : resultsAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
                      error: (e, _) => Center(
                        child: Text('Error: $e', style: AppTextStyles.bodyMedium.copyWith(color: Colors.redAccent)),
                      ),
                      data: (results) {
                        if (results.isEmpty) return _buildNoResults();
                        return ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: results.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
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
              color: const Color(0xFF7C4DFF).withOpacity(0.1),
            ),
            child: const Icon(Icons.search_rounded, size: 56, color: Color(0xFF7C4DFF)),
          ),
          const SizedBox(height: 20),
          Text('Busca en JumpUp', style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Encuentra cursos, lecciones y personas',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_rounded, size: 48, color: Colors.white24),
          const SizedBox(height: 12),
          Text('Sin resultados para "$_query"',
              style: AppTextStyles.titleMedium.copyWith(color: Colors.white38)),
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

    return GlassContainer(
      opacity: 0.08,
      blur: 10,
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(16),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFF7C4DFF).withOpacity(0.15),
          child: Icon(icon, color: const Color(0xFF7C4DFF), size: 24),
        ),
        title: Text(result.title,
            style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: result.subtitle != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(result.subtitle!,
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.bodySmall.copyWith(color: Colors.white54)),
              )
            : null,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF7C4DFF).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            result.type[0].toUpperCase() + result.type.substring(1),
            style: AppTextStyles.labelSmall.copyWith(color: const Color(0xFF7C4DFF), fontWeight: FontWeight.w900, fontSize: 10),
          ),
        ),
        onTap: () {},
      ),
    );
  }
}
