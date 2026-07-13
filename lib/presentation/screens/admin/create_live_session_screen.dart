import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jumpup_app/presentation/providers/course_provider.dart';
import 'package:jumpup_app/presentation/providers/social_providers.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';

class CreateLiveSessionScreen extends ConsumerStatefulWidget {
  const CreateLiveSessionScreen({super.key});

  @override
  ConsumerState<CreateLiveSessionScreen> createState() =>
      _CreateLiveSessionScreenState();
}

class _CreateLiveSessionScreenState
    extends ConsumerState<CreateLiveSessionScreen> {
  final _titleCtrl = TextEditingController();
  final _meetingUrlCtrl = TextEditingController();
  int? _selectedCourseId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _meetingUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF7C4DFF),
              onPrimary: Colors.white,
              surface: Color(0xFF1A1828),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF0F111A)),
          ),
          child: child!,
        );
      },
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor ingresa el título de la sesión')));
      return;
    }
    if (_selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor selecciona un curso')));
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor selecciona la fecha y hora')));
      return;
    }

    setState(() => _isLoading = true);

    // Combinar fecha+hora y convertir a UTC para el backend
    final startsAt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    ).toUtc();

    try {
      final repo = ref.read(socialRepositoryProvider);
      await repo.createLiveSession(
        title: title,
        courseId: _selectedCourseId!,
        scheduledAt: startsAt,
        meetingUrl: _meetingUrlCtrl.text.trim().isNotEmpty
            ? _meetingUrlCtrl.text.trim()
            : null,
      );
      ref.invalidate(liveSessionsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sesión programada correctamente')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(adminCoursesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1828),
        elevation: 0,
        title: const Text('Programar Videotutoría', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BrandedTextField(
              controller: _titleCtrl,
              label: 'Título de la sesión',
            ),
            const SizedBox(height: 20),
            const Text('Curso asociado', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            coursesAsync.when(
              loading: () => const CircularProgressIndicator(color: Color(0xFF7C4DFF)),
              error: (e, _) => Text('Error al cargar cursos: $e', style: const TextStyle(color: Colors.redAccent)),
              data: (courses) {
                return DropdownButtonFormField<int>(
                  dropdownColor: const Color(0xFF1A1828),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white12,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  initialValue: _selectedCourseId,
                  hint: const Text('Seleccionar curso...', style: TextStyle(color: Colors.white54)),
                  items: courses.map((c) => DropdownMenuItem(value: c.id, child: Text(c.title))).toList(),
                  onChanged: (val) => setState(() => _selectedCourseId = val),
                );
              },
            ),
            const SizedBox(height: 16),
            BrandedTextField(
              controller: _meetingUrlCtrl,
              label: 'Enlace de reunión (opcional)',
              hint: 'https://meet.jit.si/tu-sala',
              prefixIcon: Icons.link_rounded,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)),
                      alignment: Alignment.center,
                      child: Text(
                        _selectedDate == null ? 'Fecha' : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _pickTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)),
                      alignment: Alignment.center,
                      child: Text(
                        _selectedTime == null ? 'Hora' : _selectedTime!.format(context),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            PrimaryButton(
              label: 'Programar Sesión',
              loading: _isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}


