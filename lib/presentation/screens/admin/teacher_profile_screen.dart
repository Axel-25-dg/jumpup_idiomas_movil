import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/presentation/providers/auth_provider.dart';
import 'package:jumpup_app/presentation/providers/dashboard_providers.dart';
import 'package:jumpup_app/presentation/providers/course_provider.dart';
import 'package:jumpup_app/presentation/providers/language_provider.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';

class TeacherProfileScreen extends ConsumerStatefulWidget {
  const TeacherProfileScreen({super.key});

  @override
  ConsumerState<TeacherProfileScreen> createState() =>
      _TeacherProfileScreenState();
}

class _TeacherProfileScreenState
    extends ConsumerState<TeacherProfileScreen> {
  bool _isEditing = false;
  final _usernameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final notifier = ref.read(profileUpdateNotifierProvider.notifier);
    await notifier.updateProfile({
      'username': _usernameCtrl.text.trim(),
      'bio': _bioCtrl.text.trim(),
    });
    if (mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final langsAsync = ref.watch(adminLanguagesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      body: Stack(
        children: [
          // Decorative Blobs
          Positioned(
            top: -100,
            right: -100,
            child: _blob(const Color(0xFF7C4DFF), 300),
          ),
          Positioned(
            bottom: 100,
            left: -50,
            child: _blob(const Color(0xFF00E5FF), 250),
          ),

          RefreshIndicator(
            color: const Color(0xFF7C4DFF),
            onRefresh: () async => ref.invalidate(userProfileProvider),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 120,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    title: const Text(
                      'Mi Perfil',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    centerTitle: false,
                  ),
                  actions: [
                    if (!_isEditing)
                      IconButton(
                        onPressed: () {
                          final profile = profileAsync.valueOrNull;
                          if (profile != null) {
                            _usernameCtrl.text = profile.username;
                            _bioCtrl.text = profile.bio ?? '';
                          }
                          setState(() => _isEditing = true);
                        },
                        icon: const Icon(Icons.edit_rounded, color: Colors.white70),
                      )
                    else
                      IconButton(
                        onPressed: _saveProfile,
                        icon: const Icon(Icons.check_rounded, color: Color(0xFF00E5FF)),
                      ),
                  ],
                ),

                profileAsync.when(
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
                  ),
                  error: (e, stack) {
                    debugPrint('Profile Error: $e\n$stack');
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                          ),
                          child: const Text(
                            'Error al cargar el perfil. Por favor, intenta de nuevo.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    );
                  },
                  data: (profile) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            // ── Avatar Section ────────────────────────────────
                            Center(
                              child: Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [Color(0xFF7C4DFF), Color(0xFF00E5FF)],
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 60,
                                      backgroundColor: const Color(0xFF1E1E2A),
                                      backgroundImage: (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty)
                                          ? NetworkImage(profile.avatarUrl!)
                                          : null,
                                      onBackgroundImageError: (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty)
                                          ? (exception, stackTrace) => debugPrint('Avatar Image Error: $exception')
                                          : null,
                                      child: (profile.avatarUrl == null || profile.avatarUrl!.isEmpty)
                                          ? Text(
                                              (profile.username.isNotEmpty)
                                                  ? profile.username[0].toUpperCase()
                                                  : '?',
                                              style: const TextStyle(
                                                fontSize: 40,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            )
                                          : null,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF7C4DFF),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ── User Info ─────────────────────────────────────
                            if (_isEditing) ...[
                              _buildTextField('Nombre de Usuario', _usernameCtrl),
                              const SizedBox(height: 16),
                              _buildTextField('Biografía', _bioCtrl, maxLines: 3),
                            ] else ...[
                              Text(
                                profile.username,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                profile.email,
                                style: const TextStyle(color: Colors.white38, fontSize: 14),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFF7C4DFF).withValues(alpha: 0.3)),
                                ),
                                child: const Text(
                                  'TEACHER PORTAL ACCESS',
                                  style: TextStyle(
                                    color: Color(0xFF7C4DFF),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                                const SizedBox(height: 24),
                                GlassContainer(
                                  padding: const EdgeInsets.all(16),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Acerca de mí', style: TextStyle(color: Color(0xFF00E5FF), fontSize: 12, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      Text(profile.bio!, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
                                    ],
                                  ),
                                ),
                              ],
                            ],

                            const SizedBox(height: 32),

                            // ── Languages Section ─────────────────────────────
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Idiomas de Enseñanza',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 16),
                            langsAsync.when(
                              loading: () => const CircularProgressIndicator(color: Color(0xFF7C4DFF)),
                              error: (e, _) => Text('Error cargando idiomas: $e', style: const TextStyle(color: Colors.redAccent)),
                              data: (languages) => Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: languages.map((lang) {
                                  return GlassContainer(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.language_rounded, size: 16, color: Color(0xFF00E5FF)),
                                        const SizedBox(width: 8),
                                        Text(lang.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                            const SizedBox(height: 40),
                            PrimaryButton(
                              label: 'Cerrar Sesión',
                              onPressed: () => _confirmLogout(context, ref),
                              backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                              textColor: Colors.redAccent,
                            ),
                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          borderRadius: BorderRadius.circular(16),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _blob(Color color, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.05),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 80)],
        ),
      );

  void _confirmLogout(BuildContext context, WidgetRef ref) {
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
            content: const Text('¿Estás seguro que deseas salir?', style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.white38))),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () async {
                  Navigator.pop(ctx);
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) context.go(AppRoutes.login);
                },
                child: const Text('Salir'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
