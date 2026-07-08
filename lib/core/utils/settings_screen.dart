import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = true;
  bool _notificationsEnabled = true;
  bool _offlineModeEnabled = false;

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1828),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
        content: const Text('¿Estás seguro que deseas cerrar sesión? Tus datos locales se mantendrán, pero deberás iniciar sesión nuevamente.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Cierre de sesión seguro: borrar token local
              const storage = FlutterSecureStorage();
              await storage.delete(key: 'access_token');
              await storage.delete(key: 'refresh_token');
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sesión cerrada correctamente')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1828),
        title: const Text('Configuración', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // ── Preferencias ───────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text('PREFERENCIAS DE APLICACIÓN', style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          _buildSwitchTile(
            title: 'Tema Oscuro',
            subtitle: 'Mejora la lectura en la noche',
            icon: Icons.dark_mode,
            value: _isDarkMode,
            onChanged: (val) => setState(() => _isDarkMode = val),
          ),
          _buildSwitchTile(
            title: 'Notificaciones',
            subtitle: 'Recordatorios de clases y retos',
            icon: Icons.notifications,
            value: _notificationsEnabled,
            onChanged: (val) => setState(() => _notificationsEnabled = val),
          ),
          _buildSwitchTile(
            title: 'Descarga Automática',
            subtitle: 'Descarga lecciones para modo offline',
            icon: Icons.offline_pin,
            value: _offlineModeEnabled,
            onChanged: (val) => setState(() => _offlineModeEnabled = val),
          ),
          
          const Divider(color: Colors.white12, height: 32),

          // ── Soporte ────────────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text('SOPORTE Y ACERCA DE', style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          _buildActionTile(title: 'Centro de Ayuda', icon: Icons.help_outline, onTap: () {}),
          _buildActionTile(title: 'Política de Privacidad', icon: Icons.privacy_tip_outlined, onTap: () {}),
          _buildActionTile(title: 'Términos de Servicio', icon: Icons.description_outlined, onTap: () {}),
          
          const SizedBox(height: 32),

          // ── Cerrar sesión ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          const Center(
            child: Text('JumpUp Idiomas v1.0.0', style: TextStyle(color: Colors.white24, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF7C4DFF),
      secondary: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
    );
  }

  Widget _buildActionTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
      onTap: onTap,
    );
  }
}
