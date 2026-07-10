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
    if (_nameController.text.trim().isEmpty || _courseController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa los campos obligatorios'), backgroundColor: Colors.redAccent)
      );
      return;
    }
    await ref.read(classroomNotifierProvider.notifier).create(
          _nameController.text.trim(),
          _descController.text.trim(),
          int.parse(_courseController.text.trim()),
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(classroomNotifierProvider);

    ref.listen(classroomNotifierProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${next.error}'), backgroundColor: Colors.redAccent));
        return;
      }

      final classroom = next.valueOrNull;
      if (classroom != null && previous?.isLoading == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.greenAccent,
              content: Text(
                  'Aula creada con éxito. Código: ${classroom.accessCode}', style: const TextStyle(color: Colors.black))),
        );
        Navigator.pop(context);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Nueva Aula', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background Blobs
          Positioned(
            top: 20,
            left: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C4DFF).withOpacity(0.05),
                boxShadow: [BoxShadow(color: const Color(0xFF7C4DFF).withOpacity(0.05), blurRadius: 60)],
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ClassroomForm(
              nameController: _nameController,
              descController: _descController,
              courseController: _courseController,
              loading: state.isLoading,
              onSubmit: _handleCreate,
            ),
          ),
        ],
      ),
    );
  }
}
