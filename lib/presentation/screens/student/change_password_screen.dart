import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/l10n/app_localizations.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/data/remote/dio_client.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _oldPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  Future<void> _updatePassword() async {
    final l10n = AppLocalizations.of(context)!;
    final oldPass = _oldPasswordCtrl.text;
    final newPass = _newPasswordCtrl.text;
    final confirmPass = _confirmPasswordCtrl.text;

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      _showSnack(l10n.fillAllFields, Colors.orange);
      return;
    }

    if (newPass != confirmPass) {
      _showSnack(l10n.passwordsDoNotMatch, Colors.redAccent);
      return;
    }

    if (newPass.length < 8) {
      _showSnack(l10n.passwordLengthError, Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await DioClient.instance.dio.post('auth/password/change/', data: {
        'old_password': oldPass,
        'new_password': newPass,
      });

      if (!mounted) return;
      _showSnack(l10n.passwordUpdateSuccess, Colors.green);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showSnack(l10n.passwordUpdateError, Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _oldPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          l10n.changePassword,
          style: AppTextStyles.titleLarge.copyWith(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildGlassInput(
              controller: _oldPasswordCtrl,
              label: l10n.currentPassword,
              icon: Icons.lock_open_rounded,
              obscure: _obscureOld,
              onToggleObscure: () => setState(() => _obscureOld = !_obscureOld),
            ),
            const SizedBox(height: 16),
            _buildGlassInput(
              controller: _newPasswordCtrl,
              label: l10n.newPassword,
              icon: Icons.lock_outline_rounded,
              obscure: _obscureNew,
              onToggleObscure: () => setState(() => _obscureNew = !_obscureNew),
            ),
            const SizedBox(height: 16),
            _buildGlassInput(
              controller: _confirmPasswordCtrl,
              label: l10n.confirmPassword,
              icon: Icons.lock_reset_rounded,
              obscure: _obscureConfirm,
              onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updatePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        l10n.updatePassword,
                        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool obscure,
    required VoidCallback onToggleObscure,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.blueAccent),
          labelText: label,
          labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
            onPressed: onToggleObscure,
          ),
        ),
      ),
    );
  }
}
