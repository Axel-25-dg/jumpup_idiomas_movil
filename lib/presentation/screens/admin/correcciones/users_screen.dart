import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/admin_user_model.dart';
import 'package:jumpup_app/presentation/providers/correcciones/user_provider.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/empty_state.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

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
      backgroundColor: const Color(0xFF0F0E1A),
      appBar: AppBar(
        title: const Text('User Management',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => notifier.refresh(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Decor
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
              ),
            ),
          ),
          Column(
            children: [
              // Search & Filter
              Padding(
                padding: const EdgeInsets.all(20),
                child: GlassContainer(
                  borderRadius: BorderRadius.circular(25),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      BrandedTextField(
                        controller: _searchController,
                        label: 'Search users',
                        hint: 'Name, email or username...',
                        prefixIcon: Icons.search_rounded,
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _FilterChip(
                              label: 'All',
                              selected: _roleFilter == 'TODOS',
                              onSelected: () => setState(() => _roleFilter = 'TODOS'),
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: 'Students',
                              selected: _roleFilter == 'student',
                              onSelected: () => setState(() => _roleFilter = 'student'),
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: 'Teachers',
                              selected: _roleFilter == 'teacher',
                              onSelected: () => setState(() => _roleFilter = 'teacher'),
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: 'Admins',
                              selected: _roleFilter == 'admin',
                              onSelected: () => setState(() => _roleFilter = 'admin'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // List
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFF7C4DFF),
                  onRefresh: () => notifier.refresh(),
                  child: usersAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
                    error: (error, stack) => _buildErrorView(error, notifier),
                    data: (users) {
                      final filtered = _filterUsers(users);
                      if (filtered.isEmpty) {
                        return EmptyState(
                          title: 'No users found',
                          subtitle: 'Try adjusting your filters or search query',
                          icon: Icons.people_outline_rounded,
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final user = filtered[index];
                          return _UserCard(
                            user: user,
                            onToggleStatus: () => notifier.toggleUserStatus(user.id, !user.isActive),
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
      child: GlassContainer(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFFF5252)),
            const SizedBox(height: 16),
            const Text('Connection Error', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(error.toString(), style: const TextStyle(color: Colors.white54, fontSize: 12), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            PrimaryButton(label: 'Retry', onPressed: () => notifier.refresh(), icon: Icons.refresh_rounded),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, User user, UserNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Manage ${user.username}', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _InfoRow(label: 'Role', value: user.roleName.toUpperCase(), valueColor: const Color(0xFF00E5FF)),
            _InfoRow(label: 'Status', value: user.isActive ? 'ACTIVE' : 'INACTIVE', valueColor: user.isActive ? Colors.green : Colors.red),
            const Divider(color: Colors.white10, height: 24),
            const Text('Assign New Role', style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _RoleButton(label: 'ADMIN', color: const Color(0xFF7C4DFF), isSelected: user.roleName == 'admin', onTap: () { notifier.changeUserRole(user.id, 1); Navigator.pop(ctx); })),
                const SizedBox(width: 8),
                Expanded(child: _RoleButton(label: 'TEACHER', color: const Color(0xFF00E5FF), isSelected: user.roleName == 'teacher', onTap: () { notifier.changeUserRole(user.id, 2); Navigator.pop(ctx); })),
              ],
            ),
            const SizedBox(height: 8),
            _RoleButton(label: 'STUDENT', color: const Color(0xFF2575FC), isSelected: user.roleName == 'student', onTap: () { notifier.changeUserRole(user.id, 3); Navigator.pop(ctx); }),
            const SizedBox(height: 20),
            PrimaryButton(
              label: user.isActive ? 'Suspend User' : 'Activate User',
              color: user.isActive ? const Color(0xFFFF5252) : const Color(0xFF00C853),
              onPressed: () { notifier.toggleUserStatus(user.id, !user.isActive); Navigator.pop(ctx); },
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onSelected});
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      selectedColor: const Color(0xFF7C4DFF).withValues(alpha: 0.2),
      checkmarkColor: const Color(0xFF7C4DFF),
      labelStyle: TextStyle(color: selected ? const Color(0xFF7C4DFF) : Colors.white60, fontWeight: selected ? FontWeight.bold : FontWeight.normal),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: selected ? const Color(0xFF7C4DFF) : Colors.white12)),
    );
  }
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({required this.label, required this.color, required this.isSelected, required this.onTap});
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isSelected ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : Colors.white10),
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(color: isSelected ? color : Colors.white60, fontWeight: FontWeight.bold, fontSize: 10)),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          Text(value, style: TextStyle(color: valueColor ?? Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user, required this.onToggleStatus, required this.onEdit});
  final User user;
  final VoidCallback onToggleStatus;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final roleColor = user.roleName.toLowerCase() == 'admin' ? const Color(0xFF7C4DFF) : 
                     user.roleName.toLowerCase() == 'teacher' ? const Color(0xFF00E5FF) : 
                     const Color(0xFF2575FC);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(20),
        child: ListTile(
          onTap: onEdit,
          leading: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(color: roleColor.withValues(alpha: 0.1), shape: BoxShape.circle, border: Border.all(color: roleColor.withValues(alpha: 0.3))),
            child: Center(child: Text(user.username.substring(0, 1).toUpperCase(), style: TextStyle(color: roleColor, fontWeight: FontWeight.bold))),
          ),
          title: Text('${user.firstName} ${user.lastName}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(user.email, style: const TextStyle(color: Colors.white38, fontSize: 12)),
          trailing: Switch(
            value: user.isActive,
            onChanged: (_) => onToggleStatus(),
            activeColor: const Color(0xFF00E676),
          ),
        ),
      ),
    );
  }
}
