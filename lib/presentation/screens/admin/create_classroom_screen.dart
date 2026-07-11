import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/classroom_provider.dart';
import 'package:jumpup_app/presentation/providers/course_provider.dart';

class CreateClassroomScreen extends ConsumerStatefulWidget {
  final ClassroomModel? classroom;
  const CreateClassroomScreen({super.key, this.classroom});

  @override
  ConsumerState<CreateClassroomScreen> createState() =>
      _CreateClassroomScreenState();
}

class _CreateClassroomScreenState extends ConsumerState<CreateClassroomScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _courseController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descController = TextEditingController();
    _courseController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    await ref.read(classroomNotifierProvider.notifier).create(
          _nameController.text,
          _descController.text,
          int.parse(_courseController.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(classroomNotifierProvider);
    final coursesAsync = ref.watch(coursesProvider);

    ref.listen(classroomNotifierProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${next.error}')));
        return;
      }
      final classroom = next.valueOrNull;
      if (classroom != null && previous?.isLoading == true) {
        final isEdit = widget.classroom != null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.greenAccent,
              content: Text(
                  'Aula creada con éxito. Código: ${classroom.accessCode}')),
        );
        ref.invalidate(classroomsListProvider);
        Navigator.pop(context);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Aula')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ClassroomForm(
          nameController: _nameController,
          descController: _descController,
          courseController: _courseController,
          loading: state.isLoading,
          onSubmit: _handleCreate,
        ),
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary));
  }
}

class _InputField extends StatelessWidget {
  const _InputField(
      {required this.controller, required this.hint, this.maxLines = 1});
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.divider)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.divider)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 2)),
      ),
    );
  }
}
