import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/domain/model/dashboard_models.dart';
import 'package:jumpup_app/presentation/providers/auth_provider.dart';
import 'package:jumpup_app/presentation/providers/dashboard_providers.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/theme/app_theme.dart';
import 'package:jumpup_app/services/api_service.dart';

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
        'avatar': await MultipartFile.fromFile(file.path, filename: 'avatar.jpg'),
      });
      await ApiService().dio.patch('user/avatar/', data: formData);
      if (mounted) {
        ref.invalidate(userProfileProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Foto actualizada!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir foto: $e'), backgroundColor: Colors.red),
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
        const SnackBar(content: Text('Perfil actualizado')),
      );
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Mi Perfil',
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary)),
        actions: [
          if (profileAsync.hasValue && !profileAsync.isLoading)
            IconButton(
              icon: Icon(_isEditing ? Icons.check_rounded : Icons.edit_outlined,
                  color: AppColors.textPrimary),
              onPressed: updateState.isLoading
                  ? null
                  : () {
                      if (_isEditing) {
                        _saveProfile();
                      } else {
                        _startEditing(profileAsync.value!);
                      }
                    },
            ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.textPrimary),
            tooltip: 'Cerrar sesión',
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('No se pudo cargar el perfil',
                  style: AppTextStyles.bodyMedium),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => ref.invalidate(userProfileProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (profile) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Avatar ─────────────────────────────────────────────────
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor:
                          AppColors.primaryLight.withValues(alpha: 0.15),
                      backgroundImage: profile.avatarUrl != null
                          ? NetworkImage(profile.avatarUrl!)
                          : null,
                      child: profile.avatarUrl == null
                          ? Text(
                              profile.username.isNotEmpty
                                  ? profile.username[0].toUpperCase()
                                  : '?',
                              style: AppTextStyles.displayMedium.copyWith(
                                  color: AppColors.primary, fontSize: 40),
                            )
                          : null,
                    ),
                  ),
                  GestureDetector(
                    onTap: _uploadingAvatar ? null : _pickAndUploadAvatar,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle),
                      child: _uploadingAvatar
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(profile.username,
                  style: AppTextStyles.headlineSmall
                      .copyWith(color: AppColors.primaryDark)),
              Text(profile.email,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 24),

              // ── Campos ─────────────────────────────────────────────────
              _buildInfoCard(
                icon: Icons.person_outline,
                label: 'Nombre de usuario',
                value: profile.username,
                controller: _usernameController,
                isEditing: _isEditing,
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.email_outlined,
                label: 'Correo electrónico',
                value: profile.email,
                controller: TextEditingController(text: profile.email),
                isEditing: false, // email siempre read-only
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.language_outlined,
                label: 'Idioma nativo',
                value: profile.nativeLanguage,
                controller: _nativeLangController,
                isEditing: _isEditing,
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.info_outline,
                label: 'Biografía',
                value: profile.bio?.isNotEmpty == true
                    ? profile.bio!
                    : 'Sin biografía',
                controller: _bioController,
                isEditing: _isEditing,
                maxLines: 3,
              ),

              // ── Idiomas que aprende ────────────────────────────────────
              if (profile.learningLanguages.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Idiomas que aprendo',
                          style: AppTextStyles.labelMedium),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: profile.learningLanguages.map((lang) {
                          return Chip(
                            label: Text(lang),
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            labelStyle: AppTextStyles.labelMedium
                                .copyWith(color: AppColors.primary),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
              Text(
                'Miembro desde ${_formatDate(profile.joinedAt)}',
                style: AppTextStyles.labelSmall,
              ),
              const SizedBox(height: 32),

              // ── Cerrar sesión ──────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _confirmLogout,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Cerrar sesión'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
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
      return TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment:
            maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.labelSmall),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
