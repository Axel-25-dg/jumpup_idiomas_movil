import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jumpup_app/presentation/widgets/shared/user_avatar.dart';
import 'package:jumpup_app/presentation/providers/images/image_upload_provider.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/presentation/providers/auth_provider.dart';
import 'package:jumpup_app/presentation/providers/dashboard_providers.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'package:jumpup_app/data/local/token_storage.dart';
import 'package:jumpup_app/core/config/app_config.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(userProfileProvider);
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;

    final token = await TokenStorage().getAccessToken();
    if (token == null) return;

    final uploadUrl = '${AppConfig.baseUrl}auth/me/';

    try {
      final uploadedUrl =
          await ref.read(imageUploadProvider.notifier).uploadUserAvatar(
                File(picked.path),
                uploadUrl,
                token,
              );

      if (uploadedUrl != null && mounted) {
        ref.invalidate(userProfileProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto de perfil actualizada'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo subir la foto.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo subir la foto.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _startEditing(String firstName, String lastName) {
    _firstNameController.text = firstName;
    _lastNameController.text = lastName;
    setState(() => _isEditing = true);
  }

  Future<void> _saveProfile() async {
    final data = <String, dynamic>{
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
    };

    final notifier = ref.read(profileUpdateNotifierProvider.notifier);
    await notifier.updateProfile(data);
    if (mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.logout_rounded,
              color: AppColors.error, size: 28),
        ),
        title: Text('Cerrar sesión',
            textAlign: TextAlign.center,
            style: AppTextStyles.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            )),
        content: Text('¿Seguro que quieres salir de tu cuenta?',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white70,
            )),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar',
                style: AppTextStyles.labelLarge
                    .copyWith(color: Colors.white54)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).logout();
              if (mounted) context.go(AppRoutes.login);
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authUser = authState.user;
    final profileAsync = ref.watch(userProfileProvider);
    final updateState = ref.watch(profileUpdateNotifierProvider);

    final profileData = profileAsync.valueOrNull;

    final displayFirstName =
        profileData?.firstName ?? (authUser?.name ?? '');
    final displayLastName = profileData?.lastName ?? '';
    final authName = authUser?.name;
    final authEmail = authUser?.email;
    final displayFullName = profileData?.fullName ??
        (authName != null && authName.isNotEmpty ? authName : 'Usuario');
    final displayUsername = profileData?.username ?? '';
    final displayEmail = profileData?.email ??
        (authEmail != null && authEmail.isNotEmpty ? authEmail : '');

    final displayAvatarRaw = profileData?.avatarUrl ?? authUser?.avatarUrl;
    final displayAvatar =
        (displayAvatarRaw != null && displayAvatarRaw.isNotEmpty)
            ? AppConfig.resolveImageUrl(displayAvatarRaw)
            : '';

    final isUploading = ref.watch(imageUploadProvider);
    final isSaving = updateState.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      body: Stack(
        children: [
          Positioned(top: -50, left: -50, child: _blob(Colors.purpleAccent, 250)),
          Positioned(bottom: 100, right: -50, child: _blob(Colors.blueAccent, 200)),
          ListView(
            padding: EdgeInsets.zero,
            children: [
              _ProfileHeader(
                fullName: displayFullName,
                email: displayEmail,
                avatarUrl: displayAvatar,
                isUploading: isUploading,
                isEditing: _isEditing,
                onAvatarTap: isUploading ? null : _pickAndUploadAvatar,
                onEditTap: () {
                  if (_isEditing) {
                    _saveProfile();
                  } else {
                    _startEditing(displayFirstName, displayLastName);
                  }
                },
                onSettingsTap: () => context.push('/student/settings'),
                isSaving: isSaving,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                child: Column(
                  children: [
                    _ProfileInfoSection(
                      isEditing: _isEditing,
                      firstName: displayFirstName,
                      lastName: displayLastName,
                      username: displayUsername,
                      email: displayEmail,
                      firstNameController: _firstNameController,
                      lastNameController: _lastNameController,
                    ),
                    const SizedBox(height: 24),
                    _DangerZone(onLogout: _confirmLogout),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _blob(Color color, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.1),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 100)],
        ),
      );
}

// ─── Header con avatar, nombre y acciones ─────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final String fullName;
  final String email;
  final String avatarUrl;
  final bool isUploading;
  final bool isEditing;
  final bool isSaving;
  final VoidCallback? onAvatarTap;
  final VoidCallback onEditTap;
  final VoidCallback onSettingsTap;

  const _ProfileHeader({
    required this.fullName,
    required this.email,
    required this.avatarUrl,
    required this.isUploading,
    required this.isEditing,
    this.onAvatarTap,
    required this.onEditTap,
    required this.onSettingsTap,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A0533), Color(0xFF0F111A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  const Spacer(),
                  IconButton(
                    onPressed: onSettingsTap,
                    icon: const Icon(Icons.settings_outlined,
                        color: Colors.white, size: 22),
                    tooltip: 'Configuración',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Avatar con glow
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.purpleAccent.withValues(alpha: 0.4),
                        Colors.blueAccent.withValues(alpha: 0.1),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1E1E2E),
                    ),
                    child: UserAvatar(
                      imageUrl: avatarUrl.isNotEmpty ? avatarUrl : null,
                      fullName: fullName,
                      radius: 48,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onAvatarTap,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Colors.purpleAccent, Colors.blueAccent]),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF0F111A), width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purpleAccent.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isUploading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.camera_alt_rounded,
                            color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Nombre
            Text(
              fullName,
              style: AppTextStyles.headlineMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            // Email badge
            if (email.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.email_outlined,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.6)),
                    const SizedBox(width: 6),
                    Text(
                      email,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            // Botones de acción
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: isEditing ? Icons.check_rounded : Icons.edit_rounded,
                      label: isEditing ? 'Guardar' : 'Editar perfil',
                      onTap: isSaving ? null : onEditTap,
                      isPrimary: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.share_outlined,
                      label: 'Compartir',
                      onTap: () {},
                      isPrimary: false,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isPrimary ? const LinearGradient(colors: [Colors.purpleAccent, Colors.blueAccent]) : null,
          color: isPrimary ? null : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: isPrimary
              ? null
              : Border.all(
                  color: Colors.white.withValues(alpha: 0.1), width: 1),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: Colors.blueAccent.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sección de información del perfil ─────────────────────────────────────────

class _ProfileInfoSection extends StatelessWidget {
  final bool isEditing;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;

  const _ProfileInfoSection({
    required this.isEditing,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.firstNameController,
    required this.lastNameController,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              'Información Personal',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          isEditing
              ? _EditableField(
                  controller: firstNameController,
                  label: 'Nombre',
                  icon: Icons.badge_outlined,
                )
              : _InfoTile(
                  icon: Icons.badge_outlined,
                  label: 'Nombre',
                  value: firstName.isNotEmpty ? firstName : 'Sin nombre',
                  iconColor: Colors.blueAccent,
                ),
          _divider(),
          isEditing
              ? _EditableField(
                  controller: lastNameController,
                  label: 'Apellido',
                  icon: Icons.badge_outlined,
                )
              : _InfoTile(
                  icon: Icons.badge_outlined,
                  label: 'Apellido',
                  value: lastName.isNotEmpty ? lastName : 'Sin apellido',
                  iconColor: Colors.blueAccent,
                ),
          _divider(),
          _InfoTile(
            icon: Icons.alternate_email_rounded,
            label: 'Usuario',
            value: username.isNotEmpty ? username : 'Sin usuario',
            iconColor: Colors.purpleAccent,
          ),
          _divider(),
          _InfoTile(
            icon: Icons.email_outlined,
            label: 'Correo electrónico',
            value: email.isNotEmpty ? email : 'Sin correo',
            iconColor: Colors.greenAccent,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      indent: 56,
      endIndent: 20,
      color: Colors.white10,
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;

  const _EditableField({
    required this.controller,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: TextFormField(
        controller: controller,
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500, color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(icon, size: 20, color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ─── Zona de peligro (cerrar sesión) ──────────────────────────────────────────

class _DangerZone extends StatelessWidget {
  final VoidCallback onLogout;

  const _DangerZone({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Cuenta',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout_rounded,
                  size: 18, color: AppColors.error),
            ),
            title: Text(
              'Cerrar Sesión',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'Volver a la pantalla de inicio',
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),
            trailing: Icon(Icons.chevron_right_rounded,
                color: AppColors.error.withValues(alpha: 0.6)),
            onTap: onLogout,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
