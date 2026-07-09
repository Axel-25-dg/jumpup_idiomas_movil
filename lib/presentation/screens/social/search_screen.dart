import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/social_media_models.dart';
import 'package:jumpup_app/presentation/providers/social_providers.dart';

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
    final theme = Theme.of(context);
    final resultsAsync = ref.watch(searchResultsProvider(_query));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Buscar cursos, lecciones o usuarios...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _query = v.trim()),
              onSubmitted: (v) => setState(() => _query = v.trim()),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _query.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_rounded,
                              size: 64,
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.3)),
                          const SizedBox(height: 12),
                          Text('Busca en JumpUp',
                              style: theme.textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text('Encuentra cursos, lecciones y personas',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme
                                      .onSurfaceVariant)),
                        ],
                      ),
                    )
                  : resultsAsync.when(
                      loading: () => const Center(
                          child: CircularProgressIndicator()),
                      error: (e, _) => Center(
                        child: Text('Error: $e',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(
                                    color: theme.colorScheme.error)),
                      ),
                      data: (results) {
                        if (results.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search_off,
                                    size: 48,
                                    color: theme.colorScheme
                                        .onSurfaceVariant),
                                const SizedBox(height: 12),
                                Text('Sin resultados para "$_query"',
                                    style: theme.textTheme.titleMedium),
                              ],
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final r = results[index];
                            return _SearchResultTile(result: r);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({required this.result});
  final SearchResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = switch (result.type) {
      'course' => Icons.book_rounded,
      'lesson' => Icons.play_circle_rounded,
      'user' || 'profile' => Icons.person_rounded,
      _ => Icons.article_rounded,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
        ),
        title: Text(result.title,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: result.subtitle != null
            ? Text(result.subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall)
            : null,
        trailing: Chip(
          label: Text(
            result.type[0].toUpperCase() + result.type.substring(1),
            style: theme.textTheme.labelSmall,
          ),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
        onTap: () {},
      ),
    );
  }
}
