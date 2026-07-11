// lib/presentation/screens/admin/users_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/admin_user_model.dart';
import 'package:jumpup_app/presentation/providers/correcciones/user_provider.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/empty_state.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/theme/app_theme.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _roleFilter = 'TODOS';

  @override
  void initState() {
    super.initState();
    // ✅ Agregar listener para el search
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(userNotifierProvider);
    final notifier = ref.read(userNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => notifier.refresh(),
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: BrandedTextField(
              controller: _searchController,
              label: 'Buscar usuario',
              hint: 'Nombre, email o usuario...',
              prefixIcon: Icons.search_rounded,
            ),
          ),
          // Filters
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
                    selected: _roleFilter == 'Student',
                    onSelected: () => setState(() => _roleFilter = 'Student'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Profesores',
                    selected: _roleFilter == 'Teacher',
                    onSelected: () => setState(() => _roleFilter = 'Teacher'),
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
          // List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => notifier.refresh(),
              child: usersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorView(error, notifier),
                data: (users) {
                  final filtered = _filterUsers(users);
                  if (filtered.isEmpty) {
                    return EmptyState(
                      title: 'No se encontraron usuarios',
                      subtitle: _searchQuery.isNotEmpty || _roleFilter != 'TODOS'
                          ? 'Intenta con otros filtros de búsqueda'
                          : 'No hay usuarios registrados en la plataforma',
                      icon: Icons.people_outline_rounded,
                      buttonText: _searchQuery.isNotEmpty ? 'Limpiar búsqueda' : null,
                      onButtonPressed: _searchQuery.isNotEmpty
                          ? () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            }
                          : null,
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final user = filtered[index];
                      return _UserCard(
                        user: user,
                        onToggleStatus: () {
                          notifier.toggleUserStatus(user.id, !user.isActive);
                        },
                        onEdit: () => _showEditDialog(context, user, notifier),
                      );
                    },
                  );
                },
              ),
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

  Widget _buildErrorView(Object error, UserNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text('Error al cargar usuarios', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Reintentar',
            onPressed: () => notifier.refresh(),
            icon: Icons.refresh_rounded,
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, User user, UserNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Editar usuario: ${user.username}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(label: 'ID', value: user.id.toString()),
            _InfoRow(label: 'Email', value: user.email),
            _InfoRow(label: 'Nombre', value: '${user.firstName} ${user.lastName}'),
            _InfoRow(label: 'Rol', value: user.roleName),
            _InfoRow(
              label: 'Estado',
              value: user.isActive ? 'Activo ✅' : 'Inactivo ❌',
              valueColor: user.isActive ? Colors.green : Colors.red,
            ),
            const Divider(height: 24),
            const Text(
              'Cambiar rol:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: 'Admin',
                    onPressed: user.roleName == 'Admin'
                        ? null
                        : () {
                            notifier.changeUserRole(user.id, 1);
                            Navigator.pop(ctx);
                          },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PrimaryButton(
                    label: 'Profesor',
                    onPressed: user.roleName == 'Teacher'
                        ? null
                        : () {
                            notifier.changeUserRole(user.id, 2);
                            Navigator.pop(ctx);
                          },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PrimaryButton(
                    label: 'Estudiante',
                    onPressed: user.roleName == 'Student'
                        ? null
                        : () {
                            notifier.changeUserRole(user.id, 3);
                            Navigator.pop(ctx);
                          },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: user.isActive ? 'Desactivar' : 'Activar',
              onPressed: () {
                notifier.toggleUserStatus(user.id, !user.isActive);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
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
      backgroundColor: AppColors.white,
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: valueColor ?? Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.onToggleStatus,
    required this.onEdit,
  });

  final User user;
  final VoidCallback onToggleStatus;
  final VoidCallback onEdit;

  Color _getRoleColor(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'admin':
        return Colors.purple;
      case 'teacher':
        return Colors.orange;
      case 'student':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = _getRoleColor(user.roleName);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: user.isActive ? AppColors.divider : AppColors.error.withValues(alpha: 0.3),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: roleColor.withValues(alpha: 0.2),
          child: Text(
            '${user.firstName.isNotEmpty ? user.firstName[0] : ''}${user.lastName.isNotEmpty ? user.lastName[0] : ''}',
            style: TextStyle(
              color: roleColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          '${user.firstName} ${user.lastName}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                user.roleName,
                style: TextStyle(fontSize: 10, color: roleColor),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                user.email,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: user.isActive,
              onChanged: (_) => onToggleStatus(),
              activeColor: Colors.green,
            ),
            IconButton(
              icon: const Icon(Icons.edit_rounded, size: 20),
              onPressed: onEdit,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}