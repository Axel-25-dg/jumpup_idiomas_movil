import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jumpup_app/presentation/widgets/shared/user_avatar.dart';
import 'package:jumpup_app/presentation/providers/images/image_upload_provider.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/domain/model/dashboard_models.dart';
import 'package:jumpup_app/presentation/providers/auth_provider.dart';
import 'package:jumpup_app/presentation/providers/dashboard_providers.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/data/local/token_storage.dart';
import 'package:jumpup_app/core/config/app_config.dart';
import 'package:jumpup_app/presentation/screens/student/widgets/student_shared_widgets.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _nativeLangController = TextEditingController();
  final _imagePicker = ImagePicker();

  Future<void> _pickAndUploadAvatar() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
    );
    if (picked == null) return;

    final token = await TokenStorage().getAccessToken();
    if (token == null) return;

    final uploadUrl = '${AppConfig.baseUrl}/auth/me/'; // Ajustar según backend

    try {
      final uploadedUrl = await ref.read(imageUploadProvider.notifier).uploadUserAvatar(
            File(picked.path),
            uploadUrl,
            token,
          );

      if (uploadedUrl != null && mounted) {
        ref.invalidate(userProfileProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto actualizada'),
            backgroundColor: AppColors.success,
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

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _nativeLangController.dispose();
    super.dispose();
  }

  void _startEditing(UserProfileModel profile) {
    _usernameController.text = profile.username;
    _bioController.text = profile.bio ?? '';
    _nativeLangController.text = profile.nativeLanguage;
    setState(() => _isEditing = true);
  }

  Future<void> _saveProfile() async {
    final notifier = ref.read(profileUpdateNotifierProvider.notifier);
    await notifier.updateProfile({
      'username': _usernameController.text.trim(),
      'bio': _bioController.text.trim(),
      'native_language': _nativeLangController.text.trim(),
    });
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
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 28),
        ),
        title: Text('Cerrar sesión',
            textAlign: TextAlign.center,
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            )),
        content: Text('¿Seguro que quieres salir de tu cuenta?',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            )),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar',
                style: AppTextStyles.labelLarge
                    .copyWith(color: AppColors.textSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
    final profileAsync = ref.watch(userProfileProvider);
    final updateState = ref.watch(profileUpdateNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: profileAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('No se pudo cargar el perfil',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => ref.invalidate(userProfileProvider),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Reintentar'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        data: (profile) => CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              stretch: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground],
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Fondo con gradiente
                    Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                      ),
                    ),
                    // Círculos decorativos sutiles
                    Positioned(
                      top: -40,
                      right: -30,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: -50,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                    // Contenido: avatar + nombre
                    SafeArea(
                      child: Center(
                        child: FadeInDown(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 24),
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(alpha: 0.25),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.6),
                                        width: 3,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 16,
                                          offset: Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: UserAvatar(
                                      imageUrl: _resolveAvatarUrl(profile.avatarUrl),
                                      fullName: profile.username,
                                      radius: 56,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: ref.watch(imageUploadProvider)
                                        ? null
                                        : _pickAndUploadAvatar,
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2.5,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 8,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ref.watch(imageUploadProvider)
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(Icons.camera_alt_rounded,
                                              color: Colors.white, size: 18),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                profile.username,
                                style: AppTextStyles.headlineSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  profile.email,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.white.withValues(alpha: 0.95),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                _GlassIconButton(
                  icon: _isEditing ? Icons.check_rounded : Icons.edit_rounded,
                  onPressed: updateState.isLoading
                      ? null
                      : () {
                          if (_isEditing) {
                            _saveProfile();
                          } else {
                            _startEditing(profile);
                          }
                        },
                ),
                _GlassIconButton(
                  icon: Icons.settings_outlined,
                  onPressed: () => context.push('/student/settings'),
                ),
                const SizedBox(width: 8),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: Row(
                        children: [
                          Expanded(
                            child: StudentCard(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              child: StatBadge(
                                icon: Icons.bolt_rounded,
                                value: '${profile.currentStreak}',
                                label: 'Racha',
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: StudentCard(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              child: StatBadge(
                                icon: Icons.workspace_premium_rounded,
                                value: '${profile.level}',
                                label: 'Nivel',
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    FadeInUp(
                      delay: const Duration(milliseconds: 350),
                      child: const _AchievementBadges(),
                    ),
                    const SizedBox(height: 28),
                    FadeInUp(
                      delay: const Duration(milliseconds: 375),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeader(title: 'Suscripción'),
                          StudentCard(
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(Icons.verified_user_rounded,
                                      color: AppColors.success),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Plan Premium Anual',
                                          style: AppTextStyles.bodyLarge.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          )),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: AppColors.success,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text('Activa hasta el 12/12/2025',
                                              style: AppTextStyles.labelSmall.copyWith(
                                                color: AppColors.textSecondary,
                                              )),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                FilledButton.tonal(
                                  onPressed: () =>
                                      context.push('/student/subscriptions'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor:
                                        AppColors.primary.withValues(alpha: 0.1),
                                    foregroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Gestionar'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeader(title: 'Información Personal'),
                          _buildInfoCard(
                            icon: Icons.person_outline_rounded,
                            label: 'Nombre de usuario',
                            value: profile.username,
                            controller: _usernameController,
                            isEditing: _isEditing,
                          ),
                          const SizedBox(height: 14),
                          _buildInfoCard(
                            icon: Icons.language_rounded,
                            label: 'Idioma nativo',
                            value: profile.nativeLanguage,
                            controller: _nativeLangController,
                            isEditing: _isEditing,
                          ),
                          const SizedBox(height: 14),
                          _buildInfoCard(
                            icon: Icons.info_outline_rounded,
                            label: 'Biografía',
                            value: profile.bio?.isNotEmpty == true
                                ? profile.bio!
                                : 'Sin biografía',
                            controller: _bioController,
                            isEditing: _isEditing,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    if (profile.learningLanguages.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      FadeInUp(
                        delay: const Duration(milliseconds: 500),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionHeader(title: 'Idiomas en Curso'),
                            StudentCard(
                              padding: const EdgeInsets.all(20),
                              child: Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: profile.learningLanguages.map((lang) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.2)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.translate_rounded,
                                            size: 16, color: AppColors.primary),
                                        const SizedBox(width: 8),
                                        Text(lang,
                                            style: AppTextStyles.labelLarge.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w700,
                                            )),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 36),
                    FadeInUp(
                      delay: const Duration(milliseconds: 600),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: _confirmLogout,
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text('Cerrar Sesión'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: AppTextStyles.buttonText.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Miembro desde ${_formatDate(profile.joinedAt)}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required TextEditingController controller,
    required bool isEditing,
    int maxLines = 1,
  }) {
    if (isEditing) {
      return FadeIn(
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: AppTextStyles.inputLabel,
            prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      );
    }
    return StudentCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment:
            maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(value,
                    style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String? _resolveAvatarUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    final base = AppConfig.baseUrl;
    final apiFreeBase = base.replaceFirst(RegExp(r'/?api/?$'), '');
    final cleanBase = apiFreeBase.endsWith('/')
        ? apiFreeBase.substring(0, apiFreeBase.length - 1)
        : apiFreeBase;
    final cleanPath = url.startsWith('/') ? url : '/$url';
    return '$cleanBase$cleanPath';
  }
}

/// Botón de icono con efecto "glass" para el AppBar sobre el gradiente.
class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _GlassIconButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Material(
        color: Colors.white.withValues(alpha: 0.2),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}

class _AchievementBadges extends StatelessWidget {
  const _AchievementBadges();

  @override
  Widget build(BuildContext context) {
    final achievements = [
      (Icons.auto_awesome_rounded, 'Primer Paso', AppColors.primary),
      (Icons.local_fire_department_rounded, 'En Racha', AppColors.warning),
      (Icons.psychology_rounded, 'Mente Maestra', AppColors.secondary),
      (Icons.emoji_events_rounded, 'Campeón', AppColors.success),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Pines de Logro'),
        StudentCard(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: achievements.map((a) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: a.$3.withValues(alpha: 0.12),
                      border: Border.all(color: a.$3.withValues(alpha: 0.25)),
                    ),
                    child: Icon(a.$1, color: a.$3, size: 26),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 64,
                    child: Text(
                      a.$2,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
