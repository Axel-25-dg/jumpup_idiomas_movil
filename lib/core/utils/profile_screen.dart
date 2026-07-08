import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/dashboard_models.dart';
import '../../models/dashboard_providers.dart';

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
    final updateNotifier = ref.read(profileUpdateNotifierProvider.notifier);
    await updateNotifier.updateProfile({
      'username': _usernameController.text,
      'bio': _bioController.text,
      'native_language': _nativeLangController.text,
    });
    setState(() => _isEditing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final updateState = ref.watch(profileUpdateNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1828),
        title: const Text('Mi Perfil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          if (profileAsync.hasValue && !profileAsync.isLoading)
            IconButton(
              icon: Icon(_isEditing ? Icons.check : Icons.edit, color: Colors.white),
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
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
        error: (_, __) => const Center(child: Text('Error al cargar perfil', style: TextStyle(color: Colors.redAccent))),
        data: (profile) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Avatar ──────────────────────────────────────────────
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFF7C4DFF).withOpacity(0.2),
                    backgroundImage: profile.avatarUrl != null ? NetworkImage(profile.avatarUrl!) : null,
                    child: profile.avatarUrl == null
                        ? Text(
                            profile.username.isNotEmpty ? profile.username[0].toUpperCase() : '?',
                            style: const TextStyle(fontSize: 48, color: Color(0xFF7C4DFF), fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  if (_isEditing)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Color(0xFF7C4DFF), shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Formulario ──────────────────────────────────────────
              _buildField('Nombre de usuario', _usernameController, profile.username, Icons.person),
              const SizedBox(height: 16),
              _buildField('Correo electrónico', TextEditingController(), profile.email, Icons.email, isReadOnly: true),
              const SizedBox(height: 16),
              _buildField('Idioma nativo', _nativeLangController, profile.nativeLanguage, Icons.language),
              const SizedBox(height: 16),
              _buildField('Biografía', _bioController, profile.bio ?? 'Sin biografía', Icons.info_outline, maxLines: 3),
              const SizedBox(height: 24),

              // ── Idiomas aprendiendo ─────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1828),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Idiomas que aprendes', style: TextStyle(color: Colors.white54, fontSize: 13)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: profile.learningLanguages.map((lang) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C4DFF).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF7C4DFF).withOpacity(0.5)),
                          ),
                          child: Text(lang, style: const TextStyle(color: Color(0xFF7C4DFF), fontWeight: FontWeight.bold)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Miembro desde ${_formatDate(profile.joinedAt)}',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String displayValue, IconData icon, {bool isReadOnly = false, int maxLines = 1}) {
    if (!_isEditing) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1828),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white54, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(displayValue, style: const TextStyle(color: Colors.white, fontSize: 15)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return TextField(
      controller: controller,
      readOnly: isReadOnly,
      maxLines: maxLines,
      style: TextStyle(color: isReadOnly ? Colors.white54 : Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white54),
        filled: true,
        fillColor: isReadOnly ? Colors.white12 : const Color(0xFF1A1828),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF7C4DFF), width: 1.5),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
