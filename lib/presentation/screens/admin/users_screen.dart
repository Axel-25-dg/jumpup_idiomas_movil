import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/admin_user_model.dart';
import 'package:jumpup_app/presentation/providers/user_provider.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/empty_state.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _roleFilter = 'TODOS';
  late AnimationController _blobController;

  @override
  void initState() {
    super.initState();
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
    
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _blobController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(userNotifierProvider);
    final notifier = ref.read(userNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('User Management',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              letterSpacing: -0.5,
            )),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.transparent),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              HapticFeedback.lightImpact();
              notifier.refresh();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Blobs Animated
          AnimatedBuilder(
            animation: _blobController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: -100 + (30 * _blobController.value),
                    right: -50 + (20 * _blobController.value),
                    child: _blob(const Color(0xFF7C4DFF), 350, 0.12),
                  ),
                  Positioned(
                    bottom: 100 - (30 * _blobController.value),
                    left: -80 + (15 * _blobController.value),
                    child: _blob(const Color(0xFF00E5FF), 300, 0.08),
                  ),
                ],
              );
            },
          ),
          
          Column(
            children: [
              const SizedBox(height: kToolbarHeight + 40),
              // Search & Filter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassContainer(
                  borderRadius: BorderRadius.circular(24),
                  padding: const EdgeInsets.all(16),
                  blur: 20,
                  opacity: 0.08,
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
                        physics: const BouncingScrollPhysics(),
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
                  backgroundColor: const Color(0xFF1E1E2A),
                  onRefresh: () => notifier.refresh(),
                  child: usersAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
                    error: (error, stack) => _buildErrorView(error, notifier),
                    data: (users) {
                      final filtered = _filterUsers(users);
                      if (filtered.isEmpty) {
                        return const Center(
                          child: EmptyState(
                            title: 'No users found',
                            subtitle: 'Try adjusting filters or search',
                            icon: Icons.people_outline_rounded,
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final user = filtered[index];
                          return _UserCard(
                            user: user,
                            onToggleStatus: () {
                              HapticFeedback.mediumImpact();
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
        ],
      ),
    );
  }

  Widget _blob(Color color, double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: opacity + 0.05),
              blurRadius: 100,
              spreadRadius: 20,
            ),
          ],
        ),
      );

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
        padding: const EdgeInsets.all(24),
        blur: 24,
        opacity: 0.1,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 56, color: Color(0xFFFF5252)),
            const SizedBox(height: 20),
            const Text('Connection Error', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(error.toString(), style: const TextStyle(color: Colors.white54, fontSize: 13), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(label: 'Retry', onPressed: () => notifier.refresh(), icon: Icons.refresh_rounded),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, User user, UserNotifier notifier) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (ctx, a1, a2) => Container(),
      transitionBuilder: (ctx, a1, a2, child) => Transform.scale(
        scale: a1.value,
        child: Opacity(
          opacity: a1.value,
          child: AlertDialog(
            backgroundColor: const Color(0xFF1E1E2A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text('Manage @${user.username}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _InfoRow(label: 'Current Role', value: user.roleName.toUpperCase(), valueColor: const Color(0xFF00E5FF)),
                _InfoRow(label: 'Status', value: user.isActive ? 'ACTIVE' : 'INACTIVE', valueColor: user.isActive ? Colors.greenAccent : Colors.redAccent),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: Colors.white10, height: 1),
                ),
                const Text('Assign New Role', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _RoleButton(label: 'ADMIN', color: const Color(0xFF7C4DFF), isSelected: user.roleName == 'admin', onTap: () { notifier.changeUserRole(user.id, 1); Navigator.pop(ctx); })),
                    const SizedBox(width: 10),
                    Expanded(child: _RoleButton(label: 'TEACHER', color: const Color(0xFF00E5FF), isSelected: user.roleName == 'teacher', onTap: () { notifier.changeUserRole(user.id, 2); Navigator.pop(ctx); })),
                  ],
                ),
                const SizedBox(height: 10),
                _RoleButton(label: 'STUDENT', color: const Color(0xFF00C853), isSelected: user.roleName == 'student', onTap: () { notifier.changeUserRole(user.id, 3); Navigator.pop(ctx); }),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: user.isActive ? Colors.redAccent.withValues(alpha: 0.1) : Colors.greenAccent.withValues(alpha: 0.1),
                      foregroundColor: user.isActive ? Colors.redAccent : Colors.greenAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: user.isActive ? Colors.redAccent.withValues(alpha: 0.3) : Colors.greenAccent.withValues(alpha: 0.3)),
                    ),
                    icon: Icon(user.isActive ? Icons.block_flipped : Icons.check_circle_outline, size: 18),
                    onPressed: () { 
                      HapticFeedback.mediumImpact();
                      notifier.toggleUserStatus(user.id, !user.isActive); 
                      Navigator.pop(ctx); 
                    },
                    label: Text(user.isActive ? 'Suspend User' : 'Activate User', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
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
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          HapticFeedback.lightImpact();
          onSelected();
        },
        backgroundColor: Colors.white.withValues(alpha: 0.05),
        selectedColor: const Color(0xFF7C4DFF).withValues(alpha: 0.2),
        checkmarkColor: const Color(0xFF7C4DFF),
        labelStyle: TextStyle(
          color: selected ? const Color(0xFF7C4DFF) : Colors.white60, 
          fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          fontSize: 13,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), 
          side: BorderSide(color: selected ? const Color(0xFF7C4DFF).withValues(alpha: 0.5) : Colors.white10),
        ),
      ),
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
      onTap: isSelected ? null : () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? color.withValues(alpha: 0.5) : Colors.white10),
        ),
        alignment: Alignment.center,
        child: Text(
          label, 
          style: TextStyle(
            color: isSelected ? color : Colors.white54, 
            fontWeight: FontWeight.w900, 
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: valueColor ?? Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
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
                     const Color(0xFF00C853);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        blur: 20,
        opacity: 0.06,
        borderRadius: BorderRadius.circular(20),
        padding: EdgeInsets.zero,
        onTap: onEdit,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [roleColor.withValues(alpha: 0.2), roleColor.withValues(alpha: 0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle, 
              border: Border.all(color: roleColor.withValues(alpha: 0.2)),
            ),
            child: Center(
              child: Text(
                user.username.substring(0, 1).toUpperCase(), 
                style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          title: Text(
            '${user.firstName} ${user.lastName}', 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: -0.2),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(user.email, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  user.roleName.toUpperCase(),
                  style: TextStyle(color: roleColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          trailing: Switch(
            value: user.isActive,
            onChanged: (_) => onToggleStatus(),
            activeTrackColor: Colors.greenAccent.withValues(alpha: 0.2),
            activeColor: Colors.greenAccent,
            inactiveThumbColor: Colors.white24,
            inactiveTrackColor: Colors.white10,
          ),
        ),
      ),
    );
  }
}
