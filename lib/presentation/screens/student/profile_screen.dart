import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:jumpup_app/presentation/screens/student/widgets/student_shared_widgets.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/domain/model/dashboard_models.dart';
import 'package:jumpup_app/presentation/providers/auth_provider.dart';
import 'package:jumpup_app/presentation/providers/dashboard_providers.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/data/remote/dio_client.dart';
import 'package:jumpup_app/core/config/app_config.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  bool _uploadingAvatar = false;
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

    setState(() => _uploadingAvatar = true);
    try {
      final file = File(picked.path);
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          file.path,
          filename: 'avatar.jpg',
        ),
      });
      await DioClient.instance.dio.patch('auth/me/', data: formData);
      if (mounted) {
        ref.invalidate(userProfileProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto actualizada'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String msg = 'No se pudo subir la foto.';
        if (e is DioException) {
          final code = e.response?.statusCode;
          if (code == 413) msg = 'Imagen demasiado grande (max 2 MB).';
          else if (code == 401) msg = 'Sesion expirada. Inicia sesion de nuevo.';
          else if (code == 400) {
            final detail = e.response?.data?['avatar'];
            msg = detail?.toString() ?? 'Formato de imagen no valido.';
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
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
        ),
      );
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cerrar sesión',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            )),
        content: Text('¿Seguro que quieres salir?',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            )),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              expandedHeight: 240,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: FadeInDown(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Builder(
                                builder: (context) {
                                  final avatarUrl = _resolveAvatarUrl(profile.avatarUrl);
                                  return CircleAvatar(
                                    radius: 60,
                                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                                    backgroundImage: avatarUrl != null
                                        ? NetworkImage(avatarUrl)
                                        : null,
                                    child: avatarUrl == null
                                        ? Text(
                                            profile.username.isNotEmpty
                                                ? profile.username[0].toUpperCase()
                                                : '?',
                                            style: AppTextStyles.displayMedium.copyWith(
                                              color: Colors.white,
                                              fontSize: 48,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          )
                                        : null,
                                  );
                                },
                              ),
                            ),
                            GestureDetector(
                              onTap: _uploadingAvatar ? null : _pickAndUploadAvatar,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: AppColors.secondary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: _uploadingAvatar
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.camera_alt_rounded,
                                        color: Colors.white, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    _isEditing ? Icons.check_rounded : Icons.edit_rounded,
                    color: Colors.white,
                  ),
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
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.white),
                  onPressed: () => context.push('/student/settings'),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    FadeIn(
                      delay: const Duration(milliseconds: 200),
                      child: Column(
                        children: [
                          Text(profile.username,
                              style: AppTextStyles.headlineSmall.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                              )),
                          const SizedBox(height: 4),
                          Text(profile.email,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: Row(
                        children: [
                          Expanded(
                            child: StudentCard(
                              padding: const EdgeInsets.symmetric(vertical: 16),
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
                              padding: const EdgeInsets.symmetric(vertical: 16),
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
                    const SizedBox(height: 24),
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
                          const SizedBox(height: 16),
                          _buildInfoCard(
                            icon: Icons.language_rounded,
                            label: 'Idioma nativo',
                            value: profile.nativeLanguage,
                            controller: _nativeLangController,
                            isEditing: _isEditing,
                          ),
                          const SizedBox(height: 16),
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
                      const SizedBox(height: 32),
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
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: AppColors.primary.withValues(alpha: 0.2)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.language_rounded,
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
                    const SizedBox(height: 40),
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
                    const SizedBox(height: 24),
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
              color: AppColors.background,
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
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(value,
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
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
    final cleanBase = apiFreeBase.endsWith('/') ? apiFreeBase.substring(0, apiFreeBase.length - 1) : apiFreeBase;
    final cleanPath = url.startsWith('/') ? url : '/$url';
    return '$cleanBase$cleanPath';
  }
}

