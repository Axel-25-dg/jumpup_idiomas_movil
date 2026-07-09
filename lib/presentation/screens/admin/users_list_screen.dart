import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin_user_model.dart';
import 'package:jumpup_app/presentation/providers/user_list_provider.dart';

class UsersListScreen extends ConsumerStatefulWidget {
  const UsersListScreen({super.key});

  @override
  ConsumerState<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends ConsumerState<UsersListScreen> {
  final _searchController = TextEditingController();
  String _roleFilter = 'TODOS';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(userListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Usuarios')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Todos',
                    selected: _roleFilter == 'TODOS',
                    onSelected: () => setState(() => _roleFilter = 'TODOS'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Estudiantes',
                    selected: _roleFilter == 'Estudiante',
                    onSelected: () =>
                        setState(() => _roleFilter = 'Estudiante'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Profesores',
                    selected: _roleFilter == 'Profesor',
                    onSelected: () => setState(() => _roleFilter = 'Profesor'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Admin',
                    selected: _roleFilter == 'Admin',
                    onSelected: () => setState(() => _roleFilter = 'Admin'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: usersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error al cargar: $err')),
              data: (users) {
                final filtered = _filterUsers(users);
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: theme.colorScheme.outline),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isNotEmpty || _roleFilter != 'TODOS'
                              ? 'No se encontraron usuarios con esos filtros'
                              : 'No hay usuarios registrados',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(userListProvider.notifier).fetchUsers(),
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final user = filtered[index];
                      return _UserTile(
                        user: user,
                        onToggle: (val) {
                          ref
                              .read(userListProvider.notifier)
                              .updateUserStatus(user.id, val);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<User> _filterUsers(List<User> users) {
    var filtered = users;
    if (_roleFilter != 'TODOS') {
      filtered = filtered
          .where((u) => u.roleName.toLowerCase() == _roleFilter.toLowerCase())
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((u) {
        final fullName = '${u.firstName} ${u.lastName}'.toLowerCase();
        return fullName.contains(_searchQuery) ||
            u.email.toLowerCase().contains(_searchQuery) ||
            u.username.toLowerCase().contains(_searchQuery);
      }).toList();
    }
    return filtered;
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.user,
    required this.onToggle,
  });

  final User user;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final roleColor = switch (user.roleName.toLowerCase()) {
      'admin' => Colors.red,
      'profesor' => Colors.blue,
      _ => colors.outline,
    };

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: roleColor.withValues(alpha: 0.12),
        child: Text(
          '${user.firstName.isNotEmpty ? user.firstName[0] : ''}${user.lastName.isNotEmpty ? user.lastName[0] : ''}',
          style: TextStyle(color: roleColor, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        '${user.firstName} ${user.lastName}',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              user.roleName,
              style: TextStyle(fontSize: 11, color: roleColor),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              user.email,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
      trailing: Switch(
        value: user.isActive,
        onChanged: onToggle,
      ),
    );
  }
}
