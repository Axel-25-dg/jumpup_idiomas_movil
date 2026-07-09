import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/classroom_provider.dart';
import 'package:jumpup_app/presentation/widgets/classroom_form.dart';

class CreateClassroomScreen extends ConsumerStatefulWidget {
  const CreateClassroomScreen({super.key});

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
    _courseController.dispose();
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
              content: Text(
                  'Aula creada con éxito. Código: ${classroom.accessCode}')),
        );
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
