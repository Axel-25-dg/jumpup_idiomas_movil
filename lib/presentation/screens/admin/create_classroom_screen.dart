import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/classroom_model.dart';
import 'package:jumpup_app/presentation/providers/classroom_provider.dart';
// import 'package:jumpup_app/presentation/providers/course_provider.dart';
import 'package:jumpup_app/presentation/widgets/classroom_form.dart';

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
  int? _selectedCourseId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.classroom?.name ?? '');
    _descController = TextEditingController(text: widget.classroom?.description ?? '');
    _selectedCourseId = widget.classroom?.courseId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_nameController.text.trim().isEmpty || _selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa el nombre y selecciona un curso')),
      );
      return;
    }
    await ref.read(classroomNotifierProvider.notifier).create(
          _nameController.text.trim(),
          _descController.text.trim(),
          _selectedCourseId!,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(classroomNotifierProvider);

    ref.listen(classroomNotifierProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${next.error}')));
        return;
      }
      final classroom = next.valueOrNull;
      if (classroom != null && previous?.isLoading == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.greenAccent,
              content: Text(
                  'Aula guardada. Código: ${classroom.accessCode}')),
        );
        ref.invalidate(classroomsListProvider);
        Navigator.pop(context);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.classroom == null ? 'Crear Aula' : 'Editar Aula',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned(top: -100, right: -100, child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
              boxShadow: [BoxShadow(color: const Color(0xFF7C4DFF).withValues(alpha: 0.1), blurRadius: 100)],
            ),
          )),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ClassroomForm(
              nameController: _nameController,
              descController: _descController,
              selectedCourseId: _selectedCourseId,
              onCourseChanged: (val) => setState(() => _selectedCourseId = val),
              loading: state.isLoading,
              onSubmit: _handleSubmit,
              isEdit: widget.classroom != null,
            ),
          ),
        ],
      ),
    );
  }
}
