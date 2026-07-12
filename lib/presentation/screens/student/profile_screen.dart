import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:jumpup_app/widgets/logout_dialog.dart';
import 'package:jumpup_app/presentation/widgets/shared/user_avatar.dart';
import 'package:jumpup_app/presentation/providers/images/image_upload_provider.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';
import 'package:jumpup_app/presentation/providers/auth_provider.dart';
import 'package:jumpup_app/presentation/providers/dashboard_providers.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'package:jumpup_app/data/local/secure_storage.dart';
import 'package:jumpup_app/core/config/app_config.dart';
import 'package:jumpup_app/l10n/app_localizations.dart';

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
      ref.invalidate(progressByLanguageProvider);
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
      final uploadedUrl =
          await ref.read(imageUploadProvider.notifier).uploadUserAvatar(
                File(picked.path),
                uploadUrl,
                token,
              );

      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
    if (uploadedUrl != null) {
      ref.invalidate(userProfileProvider);
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
      '¡Hola! Te invito a unirte a JumpUp y aprender idiomas conmigo. Mi nombre es $fullName. Descarga la app aquí: https://jumpup.app',
      subject: 'Únete a JumpUp',
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

    final displayFirstName =
        profileData?.firstName ?? (authUser?.firstName ?? '');
    final displayLastName = profileData?.lastName ?? (authUser?.lastName ?? '');
    final authFullName = authUser?.fullName;
    final authEmail = authUser?.email;
    final displayFullName = profileData?.fullName ??
        (authFullName != null && authFullName.isNotEmpty ? authFullName : l10n.user);
    final displayUsername = profileData?.username ?? (authUser?.username ?? '');
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned(top: -50, left: -50, child: _blob(Colors.purpleAccent, 250)),
          Positioned(bottom: 100, right: -50, child: _blob(Colors.blueAccent, 200)),
          SafeArea(
            bottom: false,
            child: ListView(
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
                  onShareTap: () => _shareProfile(displayFullName),
                  isSaving: isSaving,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  child: Column(
                    children: [
                      _StatsSection(),
                      const SizedBox(height: 24),
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
                      _AchievementsSection(),
                      const SizedBox(height: 24),
                      _ProgressByLanguageSection(),
                      const SizedBox(height: 24),
                      _DangerZone(onLogout: _confirmLogout),
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

class _StatsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressSummaryProvider);
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
              'Estadísticas',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          progressAsync.when(
            data: (summary) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        label: 'Nivel',
                        value: summary.level.toString(),
                        icon: '⭐',
                        isDark: isDark,
                      ),
                      _StatItem(
                        label: 'XP Total',
                        value: summary.totalXp.toString(),
                        icon: '💎',
                        isDark: isDark,
                      ),
                      _StatItem(
                        label: 'Racha',
                        value: summary.currentStreak.toString(),
                        icon: '🔥',
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // XP Progress Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progreso al siguiente nivel',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${summary.xpProgressInLevel} / ${summary.xpForNextLevel}',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: summary.xpForNextLevel > 0
                              ? summary.xpProgressInLevel / summary.xpForNextLevel
                              : 0,
                          backgroundColor: (isDark ? Colors.white : Colors.black)
                              .withValues(alpha: 0.08),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.blueAccent,
                          ),
                          minHeight: 10,
                        ),
                      ),
                    ],
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

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final bool isDark;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
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
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.blueAccent.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 28)),
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

class _AchievementsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(myAchievementsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mis Logros',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/student/achievements'),
                  child: Text(
                    'Ver todos',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          achievementsAsync.when(
            data: (list) {
              if (list.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('¡Aún no tienes logros! Sigue practicando.',
                      style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 13)),
                );
              }
              // Mostrar solo los últimos 3 logros obtenidos
              final displayList = list.take(3).toList();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: displayList.map((userAch) => _AchievementItem(
                    icon: userAch.achievement.iconUrl ?? '🏆',
                    name: userAch.achievement.name,
                    isDark: isDark,
                  )).toList(),
                ),
              );
            },
            loading: () => const Center(child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            )),
            error: (e, __) => const SizedBox(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _AchievementItem extends StatelessWidget {
  final String icon;
  final String name;
  final bool isDark;

  const _AchievementItem({required this.icon, required this.name, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.amber.withValues(alpha: 0.3), width: 2),
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 28)),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressByLanguageSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressByLanguageProvider);
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
              'Progreso por Idioma',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          progressAsync.when(
            data: (list) {
              if (list.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('No has iniciado ningún curso aún.',
                      style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 20, endIndent: 20, color: Colors.white10),
                itemBuilder: (context, index) {
                  final p = list[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Text(p.languageCode.toUpperCase(), style: const TextStyle(fontSize: 24)),
                    title: Text(p.languageName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: p.percentage / 100,
                            backgroundColor: Colors.white10,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('${p.completed} / ${p.totalLessons} lecciones (${p.percentage.toInt()}%)', 
                          style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            )),
            error: (e, __) => Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Error al cargar progreso: $e'),
            ),
          ),
        ],
      ),
    );
  }
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
  final VoidCallback onShareTap;

  const _ProfileHeader({
    required this.fullName,
    required this.email,
    required this.avatarUrl,
    required this.isUploading,
    required this.isEditing,
    this.onAvatarTap,
    required this.onEditTap,
    required this.onSettingsTap,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  const Spacer(),
                  IconButton(
                    onPressed: onSettingsTap,
                    icon: Icon(Icons.settings_outlined,
                        color: isDark ? Colors.white : Colors.black87, size: 22),
                    tooltip: l10n.settings,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
            const SizedBox(height: 24),
            // Botones de acción
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: isEditing ? Icons.check_rounded : Icons.edit_rounded,
                      label: isEditing ? l10n.save : l10n.editProfile,
                      onTap: isSaving ? null : onEditTap,
                      isPrimary: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
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
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1), width: 1),
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
              ? _EditableField(
                  controller: firstNameController,
                  label: l10n.firstName,
                  icon: Icons.badge_outlined,
                )
              : _InfoTile(
                  icon: Icons.badge_outlined,
                  label: l10n.firstName,
                  value: firstName.isNotEmpty ? firstName : l10n.noName,
                  iconColor: Colors.blueAccent,
                ),
          _divider(),
          isEditing
              ? _EditableField(
                  controller: lastNameController,
                  label: l10n.lastName,
                  icon: Icons.badge_outlined,
                )
              : _InfoTile(
                  icon: Icons.badge_outlined,
                  label: l10n.lastName,
                  value: lastName.isNotEmpty ? lastName : l10n.noLastName,
                  iconColor: Colors.blueAccent,
                ),
          _divider(),
          _InfoTile(
            icon: Icons.alternate_email_rounded,
            label: l10n.username,
            value: username.isNotEmpty ? username : l10n.noUsername,
            iconColor: Colors.purpleAccent,
          ),
          _divider(),
          _InfoTile(
            icon: Icons.email_outlined,
            label: l10n.email,
            value: email.isNotEmpty ? email : l10n.noEmail,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: TextFormField(
        controller: controller,
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
          prefixIcon: Icon(icon, size: 20, color: Colors.blueAccent),
          filled: true,
          fillColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
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
              style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 11),
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
