// lib/presentation/screens/admin/admin_profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:jumpup_app/presentation/providers/auth_provider.dart';
import 'package:jumpup_app/presentation/providers/dashboard_providers.dart';
import 'package:jumpup_app/presentation/providers/images/image_upload_provider.dart';
import 'package:jumpup_app/presentation/providers/stats_provider.dart';
import 'package:jumpup_app/presentation/widgets/shared/user_avatar.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'package:jumpup_app/widgets/logout_dialog.dart';
import 'package:jumpup_app/data/local/secure_storage.dart';
import 'package:jumpup_app/core/config/app_config.dart';
import 'package:jumpup_app/l10n/app_localizations.dart';

class AdminProfileScreen extends ConsumerStatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  ConsumerState<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends ConsumerState<AdminProfileScreen> {
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

    final token = await SecureStorage().getAccessToken();
    if (token == null) return;

    final uploadUrl = '${AppConfig.baseUrl}auth/me/';

    try {
      final uploadedUrl = await ref.read(imageUploadProvider.notifier).uploadUserAvatar(
            File(picked.path),
            uploadUrl,
            token,
          );

      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      if (uploadedUrl != null) {
        ref.invalidate(userProfileProvider);
        ref.invalidate(authProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profilePictureUpdated),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profilePictureError),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profilePictureError),
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
      final l10n = AppLocalizations.of(context)!;
      setState(() => _isEditing = false);
      ref.invalidate(userProfileProvider);
      ref.invalidate(authProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.profileUpdated),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _confirmLogout() {
    LogoutDialog.show(context);
  }

  void _shareProfile(String fullName) {
    Share.share(
      '¡Hola! Soy administrador de JumpUp. Únete a nuestra plataforma de aprendizaje de idiomas. Descarga la app aquí: https://jumpup.app',
      subject: 'JumpUp - Aprende idiomas',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final authUser = authState.user;
    final profileAsync = ref.watch(userProfileProvider);
    final updateState = ref.watch(profileUpdateNotifierProvider);

    final profileData = profileAsync.valueOrNull;

    final displayFirstName = profileData?.firstName ?? (authUser?.firstName ?? '');
    final displayLastName = profileData?.lastName ?? (authUser?.lastName ?? '');
    final authFullName = authUser?.fullName;
    final authEmail = authUser?.email;
    final displayFullName = profileData?.fullName ??
        (authFullName != null && authFullName.isNotEmpty ? authFullName : l10n.administrator);
    final displayEmail = profileData?.email ??
        (authEmail != null && authEmail.isNotEmpty ? authEmail : '');

    final displayAvatarRaw = profileData?.avatarUrl ?? authUser?.avatarUrl;
    final displayAvatar = (displayAvatarRaw != null && displayAvatarRaw.isNotEmpty)
        ? AppConfig.resolveImageUrl(displayAvatarRaw)
        : '';

    final isUploading = ref.watch(imageUploadProvider);
    final isSaving = updateState.isLoading;

    final isSuperuser = authUser?.isSuperuser ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      body: Stack(
        children: [
          Positioned(top: -50, left: -50, child: _blob(Colors.purpleAccent, 250)),
          Positioned(bottom: 100, right: -50, child: _blob(Colors.blueAccent, 200)),
          SafeArea(
            bottom: false,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _AdminProfileHeader(
                  fullName: displayFullName,
                  email: displayEmail,
                  avatarUrl: displayAvatar,
                  isUploading: isUploading,
                  isEditing: _isEditing,
                  isSuperuser: isSuperuser,
                  onAvatarTap: isUploading ? null : _pickAndUploadAvatar,
                  onEditTap: () {
                    if (_isEditing) {
                      _saveProfile();
                    } else {
                      _startEditing(displayFirstName, displayLastName);
                    }
                  },
                  onShareTap: () => _shareProfile(displayFullName),
                  isSaving: isSaving,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  child: Column(
                    children: [
                      _AdminStatsSection(),
                      const SizedBox(height: 24),
                      _AdminProfileInfoSection(
                        isEditing: _isEditing,
                        firstName: displayFirstName,
                        lastName: displayLastName,
                        email: displayEmail,
                        isSuperuser: isSuperuser,
                        firstNameController: _firstNameController,
                        lastNameController: _lastNameController,
                      ),
                      const SizedBox(height: 24),
                      _AdminDangerZone(onLogout: _confirmLogout),
                    ],
                  ),
                ),
              ],
            ),
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

// ─── HEADER DE ADMIN ──────────────────────────────────────────────────

class _AdminProfileHeader extends StatelessWidget {
  final String fullName;
  final String email;
  final String avatarUrl;
  final bool isUploading;
  final bool isEditing;
  final bool isSaving;
  final bool isSuperuser;
  final VoidCallback? onAvatarTap;
  final VoidCallback onEditTap;
  final VoidCallback onShareTap;

  const _AdminProfileHeader({
    required this.fullName,
    required this.email,
    required this.avatarUrl,
    required this.isUploading,
    required this.isEditing,
    required this.isSuperuser,
    this.onAvatarTap,
    required this.onEditTap,
    required this.onShareTap,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A0533), const Color(0xFF0F111A)]
              : [const Color(0xFF6A11CB).withValues(alpha: 0.15), Theme.of(context).scaffoldBackgroundColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 8),
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
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        UserAvatar(
                          imageUrl: avatarUrl.isNotEmpty ? avatarUrl : null,
                          fullName: fullName,
                          radius: 48,
                        ),
                      ],
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
                      border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2.5),
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
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            // Email badge
            if (email.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.email_outlined,
                        size: 14,
                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.6)),
                    const SizedBox(width: 6),
                    Text(
                      email,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            // Badge de Admin
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSuperuser ? Icons.star_rounded : Icons.admin_panel_settings_rounded,
                    color: const Color(0xFF7C4DFF),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isSuperuser ? 'SUPER ADMIN' : 'ADMINISTRADOR',
                    style: const TextStyle(
                      color: Color(0xFF7C4DFF),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
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
                    child: _AdminActionButton(
                      icon: isEditing ? Icons.check_rounded : Icons.edit_rounded,
                      label: isEditing ? l10n.save : l10n.editProfile,
                      onTap: isSaving ? null : onEditTap,
                      isPrimary: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AdminActionButton(
                      icon: Icons.share_outlined,
                      label: l10n.share,
                      onTap: onShareTap,
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

class _AdminActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isPrimary;

  const _AdminActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isPrimary ? const LinearGradient(colors: [Colors.purpleAccent, Colors.blueAccent]) : null,
          color: isPrimary ? null : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: isPrimary
              ? null
              : Border.all(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                  width: 1,
                ),
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
              color: isPrimary ? Colors.white : (isDark ? Colors.white : Colors.black87),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : (isDark ? Colors.white : Colors.black87),
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

// ─── SECCIÓN DE ESTADÍSTICAS ──────────────────────────────────────────

class _AdminStatsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              'Estadísticas de la Plataforma',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          statsAsync.when(
            data: (stats) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _AdminStatItem(
                    label: 'Usuarios',
                    value: stats.totalUsers.toString(),
                    icon: Icons.people_alt_rounded,
                    iconColor: const Color(0xFF7C4DFF),
                    isDark: isDark,
                  ),
                  _AdminStatItem(
                    label: 'Cursos',
                    value: stats.courses.toString(),
                    icon: Icons.menu_book_rounded,
                    iconColor: const Color(0xFF00C853),
                    isDark: isDark,
                  ),
                  _AdminStatItem(
                    label: 'Certificados',
                    value: stats.certificates.toString(),
                    icon: Icons.verified_rounded,
                    iconColor: const Color(0xFFFF4081),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (e, __) => const SizedBox(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _AdminStatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final bool isDark;

  const _AdminStatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: iconColor.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: Icon(icon, size: 28, color: iconColor),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
        ),
      ],
    );
  }
}

// ─── SECCIÓN DE INFORMACIÓN DEL PERFIL ───────────────────────────────

class _AdminProfileInfoSection extends StatelessWidget {
  final bool isEditing;
  final String firstName;
  final String lastName;
  final String email;
  final bool isSuperuser;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;

  const _AdminProfileInfoSection({
    required this.isEditing,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.isSuperuser,
    required this.firstNameController,
    required this.lastNameController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassContainer(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              l10n.personalInformation,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          isEditing
              ? _AdminEditableField(
                  controller: firstNameController,
                  label: l10n.firstName,
                  icon: Icons.badge_outlined,
                )
              : _AdminInfoTile(
                  icon: Icons.badge_outlined,
                  label: l10n.firstName,
                  value: firstName.isNotEmpty ? firstName : l10n.noName,
                  iconColor: Colors.blueAccent,
                ),
          _divider(),
          isEditing
              ? _AdminEditableField(
                  controller: lastNameController,
                  label: l10n.lastName,
                  icon: Icons.badge_outlined,
                )
              : _AdminInfoTile(
                  icon: Icons.badge_outlined,
                  label: l10n.lastName,
                  value: lastName.isNotEmpty ? lastName : l10n.noLastName,
                  iconColor: Colors.blueAccent,
                ),
          _divider(),
          _AdminInfoTile(
            icon: Icons.email_outlined,
            label: l10n.email,
            value: email.isNotEmpty ? email : l10n.noEmail,
            iconColor: Colors.greenAccent,
          ),
          _divider(),
          _AdminInfoTile(
            icon: Icons.admin_panel_settings_rounded,
            label: 'Rol',
            value: isSuperuser ? 'Super Administrador' : 'Administrador',
            iconColor: const Color(0xFF7C4DFF),
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

class _AdminInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _AdminInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
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

class _AdminEditableField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;

  const _AdminEditableField({
    required this.controller,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: TextFormField(
        controller: controller,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
          prefixIcon: Icon(icon, size: 20, color: Colors.blueAccent),
          filled: true,
          fillColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

// ─── ZONA DE PELIGRO ──────────────────────────────────────────────────

class _AdminDangerZone extends StatelessWidget {
  final VoidCallback onLogout;

  const _AdminDangerZone({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                l10n.account,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
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
              l10n.logout,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              l10n.logoutSubtitle,
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
                fontSize: 11,
              ),
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