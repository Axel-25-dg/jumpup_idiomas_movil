import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/l10n/app_localizations.dart';
import 'package:jumpup_app/widgets/logout_dialog.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/presentation/providers/preferences_provider.dart';
import 'package:jumpup_app/presentation/providers/feedback_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);

    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.settings,
          style: AppTextStyles.titleLarge.copyWith(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          _SectionHeader(label: l10n.preferences),
          const SizedBox(height: 12),
          _buildGlassTile(
            context: context,
            title: l10n.darkMode,
            subtitle: l10n.darkModeSubtitle,
            icon: Icons.dark_mode_rounded,
            trailing: Switch(
              value: prefs.darkMode,
              onChanged: (_) => ref.read(preferencesProvider.notifier).toggleDarkMode(),
              activeThumbColor: Colors.blueAccent,
              activeTrackColor: Colors.blueAccent.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 12),
          _buildGlassTile(
            context: context,
            title: l10n.notifications,
            subtitle: l10n.notificationsSubtitle,
            icon: Icons.notifications_active_rounded,
            trailing: Switch(
              value: prefs.notifications,
              onChanged: (_) => ref.read(preferencesProvider.notifier).toggleNotifications(),
              activeThumbColor: Colors.blueAccent,
              activeTrackColor: Colors.blueAccent.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 12),
          _buildGlassTile(
            context: context,
            title: l10n.haptics,
            subtitle: l10n.hapticsSubtitle,
            icon: Icons.vibration_rounded,
            trailing: Switch(
              value: prefs.haptics,
              onChanged: (_) => ref.read(preferencesProvider.notifier).toggleHaptics(),
              activeThumbColor: Colors.blueAccent,
              activeTrackColor: Colors.blueAccent.withValues(alpha: 0.3),
            ),
          ),
          
          const SizedBox(height: 12),
          _buildGlassTile(
            context: context,
            title: l10n.appLanguage,
            subtitle: prefs.language == 'es' ? 'Español' : 'English',
            icon: Icons.translate_rounded,
            onTap: () => _showLanguageDialog(context, ref),
          ),
          const SizedBox(height: 32),
          _SectionHeader(label: l10n.account),
          const SizedBox(height: 12),
          _buildGlassTile(
            context: context,
            title: l10n.learningLanguages,
            subtitle: l10n.manageCourses,
            icon: Icons.language_rounded,
            onTap: () => context.push(AppRoutes.studentProfile),
          ),
          const SizedBox(height: 12),
          _buildGlassTile(
            context: context,
            title: l10n.security,
            subtitle: l10n.securitySubtitle,
            icon: Icons.lock_outline_rounded,
            onTap: () => context.push(AppRoutes.studentChangePassword),
          ),

          const SizedBox(height: 32),
          _SectionHeader(label: l10n.support),
          const SizedBox(height: 12),
          _buildGlassTile(
            context: context,
            title: l10n.sendFeedback,
            icon: Icons.feedback_outlined,
            onTap: () => _showFeedbackDialog(context, ref),
          ),
          const SizedBox(height: 12),
          _buildGlassTile(
            context: context,
            title: l10n.helpCenter,
            icon: Icons.help_outline_rounded,
            onTap: () {},
          ),

          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
              ),
              child: ListTile(
                onTap: () => _confirmLogout(context, ref),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                title: Text(
                  l10n.logout,
                  style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'JumpUp Idiomas v2.0.0 PRO',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? Colors.white24 : Colors.black26,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGlassTile({
    required BuildContext context,
    required String title,
    String? subtitle,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      padding: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.blueAccent),
        ),
        title: Text(
          title,
          style: AppTextStyles.labelLarge.copyWith(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              )
            : null,
        trailing: trailing ?? Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white24 : Colors.black26),
      ),
    );
  }


  void _confirmLogout(BuildContext context, WidgetRef ref) {
    LogoutDialog.show(context);
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final prefs = ref.read(preferencesProvider);
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Español'),
              trailing: prefs.language == 'es' ? const Icon(Icons.check, color: Colors.blueAccent) : null,
              onTap: () {
                ref.read(preferencesProvider.notifier).setLanguage('es');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('English'),
              trailing: prefs.language == 'en' ? const Icon(Icons.check, color: Colors.blueAccent) : null,
              onTap: () {
                ref.read(preferencesProvider.notifier).setLanguage('en');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    String? selectedCategory;
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black12),
            ),
            title: Text(
              l10n.sendFeedback,
              style: AppTextStyles.titleLarge.copyWith(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w800,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  dropdownColor: isDark ? const Color(0xFF2A2D3E) : Colors.white,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  hint: Text(
                    l10n.category,
                    style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                  ),
                  items: [
                    DropdownMenuItem(value: 'bug', child: Text(l10n.bug)),
                    DropdownMenuItem(value: 'feature', child: Text(l10n.feature)),
                    DropdownMenuItem(value: 'improvement', child: Text(l10n.improvement)),
                    DropdownMenuItem(value: 'other', child: Text(l10n.other)),
                  ],
                  onChanged: (v) => setDialogState(() => selectedCategory = v),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  maxLines: 4,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.feedbackHint,
                    hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26),
                    filled: true,
                    fillColor: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  l10n.cancel.toUpperCase(),
                  style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (controller.text.trim().isEmpty) return;
                  await ref.read(feedbackNotifierProvider.notifier).sendSuggestion(
                        message: controller.text.trim(),
                        category: selectedCategory,
                      );
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.feedbackSuccess),
                        backgroundColor: Colors.blueAccent,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(l10n.send),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: Colors.blueAccent,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
