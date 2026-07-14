// lib/presentation/screens/admin/broadcast_email_dialogs.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/broadcast_email_model.dart';
import 'package:jumpup_app/presentation/providers/courses_provider.dart';
import 'package:jumpup_app/presentation/providers/email_provider.dart';
import 'package:jumpup_app/presentation/providers/course_provider.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';

// ─── DIALOGO CREAR/EDITAR ──────────────────────────────────────────────

Future<void> showBroadcastDialog(
  WidgetRef ref,
  BuildContext context, {
  BroadcastEmail? broadcast,
}) async {
  final isEditing = broadcast != null;
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController(text: broadcast?.subject ?? '');
  final messageController = TextEditingController(text: broadcast?.message ?? '');
  final actionUrlController = TextEditingController(text: broadcast?.actionUrl ?? '');
  final actionTextController = TextEditingController(text: broadcast?.actionText ?? '');
  var selectedAudience = broadcast?.audience ?? 'all';
  var selectedCourseId = broadcast?.targetCourse;

  final coursesAsync = ref.watch(coursesProvider);

  // Si la audiencia es 'course' pero no hay curso seleccionado
  if (selectedAudience == 'course' && selectedCourseId == null) {
    selectedAudience = 'all';
  }

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
              isEditing ? 'Editar Envío Masivo' : 'Crear Envío Masivo',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Asunto
                    BrandedTextField(
                      controller: titleController,
                      label: 'Asunto',
                      prefixIcon: Icons.subject_rounded,
                      validator: (v) => v?.isEmpty ?? true ? 'El asunto es obligatorio' : null,
                    ),
                    const SizedBox(height: 12),
                    
                    // Mensaje
                    BrandedTextField(
                      controller: messageController,
                      label: 'Mensaje',
                      prefixIcon: Icons.message_rounded,
                      maxLines: 4,
                      validator: (v) => v?.isEmpty ?? true ? 'El mensaje es obligatorio' : null,
                    ),
                    const SizedBox(height: 12),

                    // Audiencia
                    DropdownButtonFormField<String>(
                      value: selectedAudience,
                      decoration: InputDecoration(
                        labelText: 'Audiencia',
                        labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
                        prefixIcon: const Icon(Icons.people_rounded, color: Colors.white54, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      hint: const Text('Selecciona una audiencia', style: TextStyle(color: Colors.white38, fontSize: 12)),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('Todos los usuarios', style: TextStyle(color: Colors.white, fontSize: 13))),
                        DropdownMenuItem(value: 'students', child: Text('Estudiantes', style: TextStyle(color: Colors.white, fontSize: 13))),
                        DropdownMenuItem(value: 'teachers', child: Text('Profesores', style: TextStyle(color: Colors.white, fontSize: 13))),
                        DropdownMenuItem(value: 'course', child: Text('Curso específico', style: TextStyle(color: Colors.white, fontSize: 13))),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedAudience = value!;
                          if (value != 'course') {
                            selectedCourseId = null;
                          }
                        });
                      },
                      validator: (v) => v == null ? 'Selecciona una audiencia' : null,
                      dropdownColor: const Color(0xFF2A2A3A),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),

                    // Curso (si aplica)
                    if (selectedAudience == 'course') ...[
                      const SizedBox(height: 12),
                      coursesAsync.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(color: Color(0xFF7C4DFF), strokeWidth: 2),
                          ),
                        ),
                        error: (_, __) => const Text(
                          'Error al cargar cursos',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        data: (courses) => DropdownButtonFormField<int>(
                          value: selectedCourseId,
                          decoration: InputDecoration(
                            labelText: 'Curso',
                            labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
                            prefixIcon: const Icon(Icons.menu_book_rounded, color: Colors.white54, size: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.05),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          hint: const Text('Selecciona un curso', style: TextStyle(color: Colors.white38, fontSize: 12)),
                          items: courses.map((course) {
                            return DropdownMenuItem(
                              value: course.id,
                              child: Text(
                                course.title,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => selectedCourseId = value),
                          validator: (v) => v == null ? 'Selecciona un curso' : null,
                          dropdownColor: const Color(0xFF2A2A3A),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Botón de acción (opcional)
                    const Text(
                      'Botón de acción (Opcional)',
                      style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    BrandedTextField(
                      controller: actionTextController,
                      label: 'Texto del botón',
                      prefixIcon: Icons.smart_button_rounded,
                      hint: 'Ej: Ver más',
                    ),
                    const SizedBox(height: 12),
                    BrandedTextField(
                      controller: actionUrlController,
                      label: 'URL del botón',
                      prefixIcon: Icons.link_rounded,
                      hint: 'https://...',
                    ),

                    if (isEditing && broadcast != null) ...[
                      const SizedBox(height: 12),
                      _CompactInfoRow(
                        label: 'Estado',
                        value: broadcast.isSent ? 'Enviado' : 'Pendiente',
                        color: broadcast.isSent ? const Color(0xFF69F0AE) : const Color(0xFFFFA726),
                      ),
                      _CompactInfoRow(
                        label: 'Enviados',
                        value: '${broadcast.sentCount}',
                        color: Colors.white38,
                      ),
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
                  if (formKey.currentState!.validate()) {
                    if (selectedAudience == 'course' && selectedCourseId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Selecciona un curso'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    final notifier = ref.read(broadcastEmailNotifierProvider.notifier);
                    final data = {
                      'subject': titleController.text.trim(),
                      'message': messageController.text.trim(),
                      'audience': selectedAudience,
                      if (selectedCourseId != null) 'target_course': selectedCourseId,
                      if (actionUrlController.text.trim().isNotEmpty) 'action_url': actionUrlController.text.trim(),
                      if (actionTextController.text.trim().isNotEmpty) 'action_text': actionTextController.text.trim(),
                    };

                    HapticFeedback.mediumImpact();

                    if (isEditing && broadcast != null) {
                      notifier.update(broadcast.id, data).then((_) => notifier.refresh());
                    } else {
                      notifier.create(data).then((_) => notifier.refresh());
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

// ─── DIALOGO DETALLE ────────────────────────────────────────────────────

Future<void> showBroadcastDetailDialog(BuildContext context, BroadcastEmail broadcast) async {
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
          Icon(
            broadcast.isSent ? Icons.check_circle_rounded : Icons.pending_rounded,
            color: broadcast.isSent ? const Color(0xFF69F0AE) : const Color(0xFFFFA726),
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              broadcast.subject,
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
            _CompactInfoRow(label: 'Audiencia', value: broadcast.audienceDisplay),
            _CompactInfoRow(
              label: 'Estado',
              value: broadcast.isSent ? 'Enviado' : 'Pendiente',
              color: broadcast.isSent ? const Color(0xFF69F0AE) : const Color(0xFFFFA726),
            ),
            _CompactInfoRow(label: 'Enviados', value: broadcast.sentCount.toString()),
            if (broadcast.targetCourseTitle != null)
              _CompactInfoRow(label: 'Curso', value: broadcast.targetCourseTitle!),
            if (broadcast.actionText != null && broadcast.actionText!.isNotEmpty)
              _CompactInfoRow(label: 'Botón', value: broadcast.actionText!),
            if (broadcast.actionUrl != null && broadcast.actionUrl!.isNotEmpty)
              _CompactInfoRow(label: 'URL', value: broadcast.actionUrl!),
            if (broadcast.sentAt != null)
              _CompactInfoRow(label: 'Enviado el', value: _formatDate(broadcast.sentAt!)),
            _CompactInfoRow(label: 'Creado el', value: _formatDate(broadcast.createdAt)),
            if (broadcast.message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Mensaje', style: TextStyle(color: Colors.white38, fontSize: 11)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        broadcast.message,
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

// ─── DIALOGO ENVIAR ────────────────────────────────────────────────────

Future<void> showSendBroadcastDialog(
  WidgetRef ref,
  BuildContext context,
  BroadcastEmail broadcast,
) async {
  return _showConfirmDialog(
    context: context,
    icon: Icons.send_rounded,
    iconColor: const Color(0xFF00E5FF),
    title: 'Enviar Correo Masivo',
    message: '¿Enviar este correo a ${broadcast.audienceDisplay}?',
    subtitle: 'Asunto: ${broadcast.subject}',
    warning: 'Esta acción no se puede deshacer.',
    buttonText: 'Enviar',
    onConfirm: () {
      HapticFeedback.mediumImpact();
      final notifier = ref.read(broadcastEmailNotifierProvider.notifier);
      notifier.send(broadcast.id).then((_) => notifier.refresh());
      Navigator.pop(context);
    },
  );
}

// ─── DIALOGO ELIMINAR ──────────────────────────────────────────────────

Future<void> showDeleteBroadcastDialog(
  WidgetRef ref,
  BuildContext context,
  BroadcastEmail broadcast,
) async {
  return _showConfirmDialog(
    context: context,
    icon: Icons.delete_outline_rounded,
    iconColor: const Color(0xFFFF5252),
    title: 'Eliminar Envío',
    message: '¿Eliminar este envío?',
    subtitle: 'Asunto: ${broadcast.subject}',
    warning: 'Esta acción no se puede deshacer.',
    buttonText: 'Eliminar',
    onConfirm: () {
      HapticFeedback.mediumImpact();
      final notifier = ref.read(broadcastEmailNotifierProvider.notifier);
      notifier.delete(broadcast.id).then((_) => notifier.refresh());
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

String _formatDate(DateTime? date) {
  if (date == null) return 'N/A';
  return '${date.day}/${date.month}/${date.year}';
}