// lib/presentation/screens/admin/certificates_dialogs.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/certificate_model.dart';
import 'package:jumpup_app/domain/model/admin/admin_user_model.dart';
import 'package:jumpup_app/presentation/providers/certificate_provider.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';

// ─── DIALOGO CREAR/EDITAR ──────────────────────────────────────────────

Future<void> showCertificateDialog(
  WidgetRef ref,
  BuildContext context,
  AsyncValue<List<User>> studentsAsync, {
  Certificate? certificate,
}) async {
  final isEditing = certificate != null;
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController(text: certificate?.title ?? '');
  final descriptionController = TextEditingController(text: certificate?.description ?? '');
  var selectedStudentId = certificate?.student;
  var selectedLevel = certificate?.level;

  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E2A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            title: Text(
              isEditing ? 'Editar Certificado' : 'Crear Certificado',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    studentsAsync.when(
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(color: Color(0xFF7C4DFF), strokeWidth: 2),
                        ),
                      ),
                      error: (_, __) => const Text(
                        'Error al cargar estudiantes',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      data: (students) => DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText: 'Estudiante',
                          labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
                          prefixIcon: const Icon(Icons.person_rounded, color: Colors.white54, size: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        hint: const Text('Selecciona un estudiante', style: TextStyle(color: Colors.white38, fontSize: 12)),
                        value: selectedStudentId,
                        items: students.map((user) {
                          final displayName = '${user.firstName} ${user.lastName}'.trim();
                          return DropdownMenuItem(
                            value: user.id,
                            child: Text(
                              displayName.isNotEmpty ? displayName : user.username,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => selectedStudentId = value),
                        validator: (v) => v == null ? 'Selecciona un estudiante' : null,
                        dropdownColor: const Color(0xFF2A2A3A),
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedLevel,
                      decoration: InputDecoration(
                        labelText: 'Nivel',
                        labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
                        prefixIcon: const Icon(Icons.signal_cellular_alt_rounded, color: Colors.white54, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      hint: const Text('Selecciona un nivel', style: TextStyle(color: Colors.white38, fontSize: 12)),
                      items: const [
                        DropdownMenuItem(value: 'A1', child: Text('A1 - Principiante', style: TextStyle(color: Colors.white, fontSize: 13))),
                        DropdownMenuItem(value: 'A2', child: Text('A2 - Elemental', style: TextStyle(color: Colors.white, fontSize: 13))),
                        DropdownMenuItem(value: 'B1', child: Text('B1 - Intermedio', style: TextStyle(color: Colors.white, fontSize: 13))),
                        DropdownMenuItem(value: 'B2', child: Text('B2 - Intermedio Alto', style: TextStyle(color: Colors.white, fontSize: 13))),
                        DropdownMenuItem(value: 'C1', child: Text('C1 - Avanzado', style: TextStyle(color: Colors.white, fontSize: 13))),
                        DropdownMenuItem(value: 'C2', child: Text('C2 - Maestría', style: TextStyle(color: Colors.white, fontSize: 13))),
                      ],
                      onChanged: (value) => setState(() => selectedLevel = value),
                      validator: (v) => v == null ? 'Selecciona un nivel' : null,
                      dropdownColor: const Color(0xFF2A2A3A),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    BrandedTextField(
                      controller: titleController,
                      label: 'Título',
                      prefixIcon: Icons.title_rounded,
                      validator: (v) => v?.isEmpty ?? true ? 'El título es obligatorio' : null,
                    ),
                    const SizedBox(height: 12),
                    BrandedTextField(
                      controller: descriptionController,
                      label: 'Descripción',
                      prefixIcon: Icons.description_rounded,
                      maxLines: 2,
                    ),
                    if (isEditing && certificate != null) ...[
                      const SizedBox(height: 12),
                      _CompactInfoRow(label: 'Estado', value: _getStatusText(certificate.status), color: _getStatusColor(certificate.status)),
                      _CompactInfoRow(label: 'Código', value: certificate.certificateCode ?? 'N/A', color: Colors.white38),
                    ],
                  ],
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar', style: TextStyle(color: Colors.white54, fontSize: 13)),
              ),
              PrimaryButton(
                label: isEditing ? 'Actualizar' : 'Crear',
                onPressed: () {
                  if (formKey.currentState!.validate() && selectedStudentId != null && selectedLevel != null) {
                    final notifier = ref.read(certificateNotifierProvider.notifier);
                    final data = {
                      'student': selectedStudentId!,
                      'level': selectedLevel!,
                      'title': titleController.text.trim(),
                      'description': descriptionController.text.trim(),
                    };
                    HapticFeedback.mediumImpact();
                    if (isEditing && certificate != null) {
                      notifier.updateCertificate(certificate.id!, data).then((_) => notifier.refresh());
                    } else {
                      notifier.createCertificate(data).then((_) => notifier.refresh());
                    }
                    Navigator.pop(ctx);
                  }
                },
              ),
            ],
          );
        },
      );
    },
  );
}

// ─── OTROS DIÁLOGOS ────────────────────────────────────────────────────

Future<void> showDetailDialog(BuildContext context, Certificate certificate) async {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1E1E2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      title: Row(
        children: [
          Icon(_getStatusIcon(certificate.status), color: _getStatusColor(certificate.status), size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              certificate.title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CompactInfoRow(label: 'Estudiante', value: certificate.studentEmail ?? 'N/A'),
            _CompactInfoRow(label: 'Nivel', value: certificate.levelDisplay ?? certificate.level),
            _CompactInfoRow(label: 'Estado', value: _getStatusText(certificate.status), color: _getStatusColor(certificate.status)),
            _CompactInfoRow(label: 'Código', value: certificate.certificateCode ?? 'N/A'),
            if (certificate.issuedAt != null)
              _CompactInfoRow(label: 'Emitido el', value: _formatDate(certificate.issuedAt!)),
            if (certificate.issuedByEmail != null)
              _CompactInfoRow(label: 'Emitido por', value: certificate.issuedByEmail!),
            _CompactInfoRow(label: 'Creado el', value: _formatDate(certificate.createdAt!)),
            if (certificate.description != null && certificate.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Descripción', style: TextStyle(color: Colors.white38, fontSize: 11)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        certificate.description!,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cerrar', style: TextStyle(color: Colors.white54, fontSize: 13)),
        ),
      ],
    ),
  );
}

Future<void> showIssueDialog(WidgetRef ref, BuildContext context, Certificate certificate) async {
  return _showConfirmDialog(
    context: context,
    icon: Icons.check_circle_outline_rounded,
    iconColor: const Color(0xFF69F0AE),
    title: 'Emitir Certificado',
    message: '¿Emitir este certificado a ${certificate.studentEmail ?? 'el estudiante'}?',
    subtitle: 'Título: ${certificate.title}',
    buttonText: 'Emitir',
    onConfirm: () {
      HapticFeedback.mediumImpact();
      final notifier = ref.read(certificateNotifierProvider.notifier);
      notifier.issueCertificate(certificate.id!).then((_) => notifier.refresh());
      Navigator.pop(context);
    },
  );
}

Future<void> showRevokeDialog(WidgetRef ref, BuildContext context, Certificate certificate) async {
  return _showConfirmDialog(
    context: context,
    icon: Icons.cancel_outlined,
    iconColor: const Color(0xFFFF5252),
    title: 'Revocar Certificado',
    message: '¿Revocar este certificado de ${certificate.studentEmail ?? 'el estudiante'}?',
    subtitle: 'Título: ${certificate.title}',
    warning: 'Esta acción no se puede deshacer.',
    buttonText: 'Revocar',
    onConfirm: () {
      HapticFeedback.mediumImpact();
      final notifier = ref.read(certificateNotifierProvider.notifier);
      notifier.revokeCertificate(certificate.id!).then((_) => notifier.refresh());
      Navigator.pop(context);
    },
  );
}

Future<void> showDeleteDialog(WidgetRef ref, BuildContext context, Certificate certificate) async {
  return _showConfirmDialog(
    context: context,
    icon: Icons.delete_outline_rounded,
    iconColor: const Color(0xFFFF5252),
    title: 'Eliminar Certificado',
    message: '¿Eliminar este certificado?',
    subtitle: 'Título: ${certificate.title}',
    warning: 'Esta acción no se puede deshacer.',
    buttonText: 'Eliminar',
    onConfirm: () {
      HapticFeedback.mediumImpact();
      final notifier = ref.read(certificateNotifierProvider.notifier);
      notifier.deleteCertificate(certificate.id!).then((_) => notifier.refresh());
      Navigator.pop(context);
    },
  );
}

// ─── WIDGET COMPACTO DE CONFIRMACIÓN ──────────────────────────────────

Future<void> _showConfirmDialog({
  required BuildContext context,
  required IconData icon,
  required Color iconColor,
  required String title,
  required String message,
  String? subtitle,
  String? warning,
  required String buttonText,
  required VoidCallback onConfirm,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1E1E2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: iconColor),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Colors.white70, fontSize: 13), textAlign: TextAlign.center),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12), textAlign: TextAlign.center),
          ],
          if (warning != null) ...[
            const SizedBox(height: 4),
            Text(warning, style: const TextStyle(color: Color(0xFFFF5252), fontSize: 11), textAlign: TextAlign.center),
          ],
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancelar', style: TextStyle(color: Colors.white54, fontSize: 13)),
        ),
        PrimaryButton(
          label: buttonText,
          onPressed: onConfirm,
        ),
      ],
    ),
  );
}

// ─── WIDGETS COMPACTOS ─────────────────────────────────────────────────

class _CompactInfoRow extends StatelessWidget {
  const _CompactInfoRow({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w500)),
          Flexible(
            child: Text(
              value,
              style: TextStyle(color: color ?? Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── HELPERS ────────────────────────────────────────────────────────────

String _getStatusText(String status) {
  switch (status) {
    case 'issued': return 'Emitido';
    case 'pending': return 'Pendiente';
    case 'revoked': return 'Revocado';
    default: return status;
  }
}

Color _getStatusColor(String status) {
  switch (status) {
    case 'issued': return const Color(0xFF69F0AE);
    case 'pending': return const Color(0xFFFFA726);
    case 'revoked': return const Color(0xFFFF5252);
    default: return Colors.grey;
  }
}

IconData _getStatusIcon(String status) {
  switch (status) {
    case 'issued': return Icons.check_circle_rounded;
    case 'pending': return Icons.pending_rounded;
    case 'revoked': return Icons.cancel_rounded;
    default: return Icons.help_rounded;
  }
}

String _formatDate(DateTime? date) {
  if (date == null) return 'N/A';
  return '${date.day}/${date.month}/${date.year}';
}