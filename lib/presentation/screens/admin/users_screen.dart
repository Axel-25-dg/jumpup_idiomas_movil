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

class _UsersScreenState extends ConsumerState<UsersScreen>
    with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _roleFilter = 'TODOS';
  late AnimationController _blobController;

  // Controllers para el diálogo de creación
  final _createFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'teacher';

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
    _emailController.dispose();
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
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
        title: const Text('Gestión de Usuarios',
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
            icon: const Icon(Icons.add_rounded, color: Color(0xFF00E5FF)),
            onPressed: () => _showCreateUserDialog(context),
            tooltip: 'Crear usuario',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              HapticFeedback.lightImpact();
              notifier.refresh();
            },
            tooltip: 'Refrescar',
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
                        label: 'Buscar usuarios',
                        hint: 'Nombre, email o usuario...',
                        prefixIcon: Icons.search_rounded,
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            _FilterChip(
                              label: 'Todos',
                              selected: _roleFilter == 'TODOS',
                              onSelected: () =>
                                  setState(() => _roleFilter = 'TODOS'),
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: 'Estudiantes',
                              selected: _roleFilter == 'student',
                              onSelected: () =>
                                  setState(() => _roleFilter = 'student'),
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: 'Profesores',
                              selected: _roleFilter == 'teacher',
                              onSelected: () =>
                                  setState(() => _roleFilter = 'teacher'),
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: 'Administradores',
                              selected: _roleFilter == 'admin',
                              onSelected: () =>
                                  setState(() => _roleFilter = 'admin'),
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
                    loading: () => const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF7C4DFF))),
                    error: (error, stack) =>
                        _buildErrorView(error, notifier),
                    data: (users) {
                      final filtered = _filterUsers(users);
                      if (filtered.isEmpty) {
                        return const Center(
                          child: EmptyState(
                            title: 'No se encontraron usuarios',
                            subtitle: 'Ajusta los filtros o la búsqueda',
                            icon: Icons.people_outline_rounded,
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                        physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final user = filtered[index];
                          final isStudent =
                              user.roleName.toLowerCase() == 'student';
                          return _UserCard(
                            user: user,
                            isStudent: isStudent,
                            onToggleStatus: () {
                              HapticFeedback.mediumImpact();
                              notifier.toggleUserStatus(
                                  user.id, !user.isActive);
                            },
                            onEdit: () => _showEditDialog(
                                context, user, notifier, isStudent),
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
            const Icon(Icons.error_outline_rounded, size: 56,
                color: Color(0xFFFF5252)),
            const SizedBox(height: 20),
            const Text('Error de conexión',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(error.toString(),
                style: const TextStyle(color: Colors.white54, fontSize: 13),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                  label: 'Reintentar',
                  onPressed: () => notifier.refresh(),
                  icon: Icons.refresh_rounded),
            ),
          ],
        ),
      ),
    );
  }

  // ─── CREAR USUARIO ──────────────────────────────────────────────

  void _showCreateUserDialog(BuildContext context) {
    _emailController.clear();
    _usernameController.clear();
    _firstNameController.clear();
    _lastNameController.clear();
    _passwordController.clear();
    _selectedRole = 'teacher';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: BorderRadius.circular(28),
          padding: const EdgeInsets.all(24),
          blur: 24,
          opacity: 0.12,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C4DFF).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.person_add_rounded,
                          color: Color(0xFF7C4DFF), size: 24),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Crear Usuario',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Form(
                  key: _createFormKey,
                  child: Column(
                    children: [
                      BrandedTextField(
                        controller: _emailController,
                        label: 'Email',
                        prefixIcon: Icons.email_rounded,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'El email es obligatorio';
                          if (!value.contains('@'))
                            return 'Email inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      BrandedTextField(
                        controller: _usernameController,
                        label: 'Usuario',
                        prefixIcon: Icons.person_rounded,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'El usuario es obligatorio';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: BrandedTextField(
                              controller: _firstNameController,
                              label: 'Nombre',
                              prefixIcon: Icons.person_outline_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: BrandedTextField(
                              controller: _lastNameController,
                              label: 'Apellido',
                              prefixIcon: Icons.person_outline_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      BrandedTextField(
                        controller: _passwordController,
                        label: 'Contraseña',
                        prefixIcon: Icons.lock_rounded,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'La contraseña es obligatoria';
                          if (value.length < 6)
                            return 'Mínimo 6 caracteres';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        dropdownColor: const Color(0xFF1E1E2A),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Rol',
                          prefixIcon: const Icon(
                              Icons.admin_panel_settings_rounded,
                              color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          labelStyle: const TextStyle(color: Colors.white54),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'teacher', child: Text('Profesor')),
                          DropdownMenuItem(
                              value: 'admin', child: Text('Administrador')),
                        ],
                        onChanged: (value) {
                          if (value != null) _selectedRole = value;
                        },
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.blue.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, size: 16,
                                color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Los estudiantes se crean desde el registro público.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue[300],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white54,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.1)),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Crear Usuario',
                        onPressed: () {
                          if (_createFormKey.currentState!.validate()) {
                            final notifier =
                                ref.read(userNotifierProvider.notifier);

                            int roleId = _selectedRole == 'admin' ? 2 : 4;

                            notifier.createUser({
                              'username': _usernameController.text.trim(),
                              'email': _emailController.text.trim(),
                              'first_name': _firstNameController.text.trim(),
                              'last_name': _lastNameController.text.trim(),
                              'password': _passwordController.text,
                              'role_id': roleId,
                              'is_active': true,
                            });

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✅ Usuario creado exitosamente'),
                                backgroundColor: Colors.green,
                              ),
                            );

                            Future.delayed(
                                const Duration(milliseconds: 500), () {
                              notifier.refresh();
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── EDITAR USUARIO ──────────────────────────────────────────────

  void _showEditDialog(
      BuildContext context, User user, UserNotifier notifier, bool isStudent) {
    // Controladores para editar nombre y correo
    final firstNameController = TextEditingController(text: user.firstName);
    final lastNameController = TextEditingController(text: user.lastName);
    final emailController = TextEditingController(text: user.email);

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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24)),
            title: Text('Editar @${user.username}',
                style:
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Info actual
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _InfoRow(
                            label: 'Rol actual',
                            value: user.roleName.toUpperCase(),
                            valueColor: const Color(0xFF00E5FF)),
                        _InfoRow(
                            label: 'Estado',
                            value: user.isActive ? 'ACTIVO' : 'INACTIVO',
                            valueColor: user.isActive
                                ? Colors.greenAccent
                                : Colors.redAccent),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 16),

                  // Campos editables
                  const Text(
                    'Editar información',
                    style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 12),

                  BrandedTextField(
                    controller: firstNameController,
                    label: 'Nombre',
                    prefixIcon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  BrandedTextField(
                    controller: lastNameController,
                    label: 'Apellido',
                    prefixIcon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  BrandedTextField(
                    controller: emailController,
                    label: 'Email',
                    prefixIcon: Icons.email_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 16),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 16),

                  // Roles (solo para staff)
                  if (!isStudent) ...[
                    const Text(
                      'Cambiar rol',
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _RoleButton(
                            label: 'ADMIN',
                            color: const Color(0xFF7C4DFF),
                            isSelected: user.roleName == 'admin',
                            onTap: () {
                              notifier.changeUserRole(user.id, 2);
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Rol actualizado a Admin'),
                                    backgroundColor: Colors.green),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _RoleButton(
                            label: 'PROFESOR',
                            color: const Color(0xFF00E5FF),
                            isSelected: user.roleName == 'teacher',
                            onTap: () {
                              notifier.changeUserRole(user.id, 4);
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Rol actualizado a Profesor'),
                                    backgroundColor: Colors.green),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Botón Guardar
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      label: 'Guardar cambios',
                      onPressed: () {
                        final data = {
                          'first_name': firstNameController.text.trim(),
                          'last_name': lastNameController.text.trim(),
                          'email': emailController.text.trim(),
                        };

                        if (isStudent) {
                          notifier.updateStudent(user.id, data);
                        } else {
                          notifier.updateUser(user.id, data);
                        }

                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('✅ Usuario actualizado'),
                              backgroundColor: Colors.green),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ✅ Botón Desactivar (en lugar de Eliminar)
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      label: user.isActive ? 'Desactivar usuario' : 'Activar usuario',
                      onPressed: () {
                        notifier.toggleUserStatus(user.id, !user.isActive);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              user.isActive 
                                ? 'Usuario desactivado correctamente' 
                                : 'Usuario activado correctamente'
                            ),
                            backgroundColor: user.isActive ? Colors.orange : Colors.green,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cerrar',
                    style: TextStyle(color: Colors.white38)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip(
      {required this.label, required this.selected, required this.onSelected});
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
        onSelected: (_) => onSelected(),
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
          side: BorderSide(
              color: selected
                  ? const Color(0xFF7C4DFF).withValues(alpha: 0.5)
                  : Colors.white10),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  const _RoleButton(
      {required this.label,
      required this.color,
      required this.isSelected,
      required this.onTap});
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isSelected
          ? null
          : () {
              HapticFeedback.mediumImpact();
              onTap();
            },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isSelected
                  ? color.withValues(alpha: 0.5)
                  : Colors.white10),
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
  const _InfoRow(
      {required this.label, required this.value, this.valueColor});
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
          Text(label,
              style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          Text(value,
              style: TextStyle(
                  color: valueColor ?? Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13)),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.isStudent,
    required this.onToggleStatus,
    required this.onEdit,
  });

  final User user;
  final bool isStudent;
  final VoidCallback onToggleStatus;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final roleColor = user.roleName.toLowerCase() == 'admin'
        ? const Color(0xFF7C4DFF)
        : user.roleName.toLowerCase() == 'teacher'
            ? const Color(0xFF00E5FF)
            : const Color(0xFF00C853);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        blur: 20,
        opacity: 0.06,
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila superior: Avatar + Info
            Row(
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        roleColor.withValues(alpha: 0.25),
                        roleColor.withValues(alpha: 0.05)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: roleColor.withValues(alpha: 0.25), width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      user.username.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: roleColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${user.firstName} ${user.lastName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 1),
                        decoration: BoxDecoration(
                          color: roleColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: roleColor.withValues(alpha: 0.15),
                              width: 0.5),
                        ),
                        child: Text(
                          user.roleName.toUpperCase(),
                          style: TextStyle(
                            color: roleColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Fila inferior: Botones (alineados a la derecha)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Switch(
                  value: user.isActive,
                  onChanged: (_) => onToggleStatus(),
                  activeTrackColor: Colors.greenAccent.withValues(alpha: 0.2),
                  activeColor: Colors.greenAccent,
                  inactiveThumbColor: Colors.white24,
                  inactiveTrackColor: Colors.white10,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                IconButton(
                  icon: const Icon(Icons.edit_rounded, size: 20),
                  onPressed: onEdit,
                  color: Colors.white38,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}