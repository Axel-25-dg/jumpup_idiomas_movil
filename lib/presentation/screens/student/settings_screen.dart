import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/presentation/providers/auth_provider.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/presentation/providers/feedback_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Configuración',
          style: AppTextStyles.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          const _SectionHeader(label: 'PREFERENCIAS'),
          const SizedBox(height: 12),
          _buildGlassTile(
            context: context,
            title: 'Tema Oscuro',
            subtitle: 'Mejora la lectura en la noche',
            icon: Icons.dark_mode_rounded,
            trailing: Switch(
              value: true,
              onChanged: (v) {},
              activeThumbColor: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 12),
          _buildGlassTile(
            context: context,
            title: 'Notificaciones',
            subtitle: 'Recordatorios de clases y retos',
            icon: Icons.notifications_active_rounded,
            trailing: Switch(
              value: true,
              onChanged: (v) {},
              activeThumbColor: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 12),
          _buildGlassTile(
            context: context,
            title: 'Haptics (Vibración)',
            subtitle: 'Feedback táctil al interactuar',
            icon: Icons.vibration_rounded,
            trailing: Switch(
              value: true,
              onChanged: (v) {},
              activeThumbColor: Colors.blueAccent,
            ),
          ),
          
          const SizedBox(height: 32),
          const _SectionHeader(label: 'CUENTA'),
          const SizedBox(height: 12),
          _buildGlassTile(
            context: context,
            title: 'Idiomas de aprendizaje',
            subtitle: 'Gestiona tus cursos activos',
            icon: Icons.language_rounded,
            onTap: () => context.push('/student/profile'),
          ),
          const SizedBox(height: 12),
          _buildGlassTile(
            context: context,
            title: 'Seguridad',
            subtitle: 'Cambiar contraseña y privacidad',
            icon: Icons.lock_outline_rounded,
            onTap: () => context.push(AppRoutes.forgotPassword),
          ),

          const SizedBox(height: 32),
          const _SectionHeader(label: 'SOPORTE'),
          const SizedBox(height: 12),
          _buildGlassTile(
            context: context,
            title: 'Enviar sugerencia',
            icon: Icons.feedback_outlined,
            onTap: () => _showFeedbackDialog(context, ref),
          ),
          const SizedBox(height: 12),
          _buildGlassTile(
            context: context,
            title: 'Centro de Ayuda',
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
                title: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'JumpUp Idiomas v2.0.0 PRO',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white24,
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
          style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white54),
              )
            : null,
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: Colors.white24),
      ),
    );
  }


  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text(
          '¿Estás seguro que deseas cerrar sesión?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    String? selectedCategory;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Enviar sugerencia'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                hint: const Text('Categoría'),
                items: const [
                  DropdownMenuItem(value: 'bug', child: Text('Error')),
                  DropdownMenuItem(value: 'feature', child: Text('Nueva función')),
                  DropdownMenuItem(value: 'improvement', child: Text('Mejora')),
                  DropdownMenuItem(value: 'other', child: Text('Otro')),
                ],
                onChanged: (v) => setDialogState(() => selectedCategory = v),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe tu sugerencia...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;
                await ref.read(feedbackNotifierProvider.notifier).sendSuggestion(
                      message: controller.text.trim(),
                      category: selectedCategory,
                    );
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('¡Gracias por tu sugerencia!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: const Text('Enviar'),
            ),
          ],
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
