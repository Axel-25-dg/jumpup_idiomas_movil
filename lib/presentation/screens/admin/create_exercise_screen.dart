import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/presentation/providers/exercise_provider.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'package:jumpup_app/theme/colors.dart';

class CreateExerciseScreen extends ConsumerStatefulWidget {
  const CreateExerciseScreen({super.key});

  @override
  ConsumerState<CreateExerciseScreen> createState() =>
      _CreateExerciseScreenState();
}

class _CreateExerciseScreenState extends ConsumerState<CreateExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lessonCtrl = TextEditingController();
  final _questionCtrl = TextEditingController();
  final _answerCtrl = TextEditingController();

  String _selectedType = 'multiple_choice';
  final Map<String, String> _exerciseTypes = {
    'multiple_choice': 'Opción Múltiple',
    'translate': 'Traducción',
    'listen': 'Escucha (Listening)',
    'fill_blank': 'Completar espacio',
    'match': 'Relacionar columnas'
  };

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exerciseNotifierProvider);

    ref.listen(exerciseNotifierProvider, (prev, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${next.error}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      } else if (next is AsyncData && prev?.isLoading == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ejercicio creado con éxito'),
            backgroundColor: Colors.greenAccent,
          ),
        );
        Navigator.pop(context);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Crear Ejercicio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background Blobs
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                    blurRadius: 100,
                  )
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Configuración del Ejercicio",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    borderRadius: BorderRadius.circular(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tipo de actividad',
                          style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          dropdownColor: const Color(0xFF1A1828),
                          initialValue: _selectedType,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.category_rounded,
                                color: Colors.white70),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Colors.white12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: AppColors.secondary),
                            ),
                          ),
                          items: _exerciseTypes.entries
                              .map((e) => DropdownMenuItem(
                                  value: e.key, child: Text(e.value)))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedType = val!),
                        ),
                        const SizedBox(height: 20),
                        BrandedTextField(
                          controller: _lessonCtrl,
                          label: 'ID de la Lección',
                          keyboardType: TextInputType.number,
                          hint: 'Ej: 42',
                          prefixIcon: Icons.play_lesson_rounded,
                        ),
                        const SizedBox(height: 20),
                        BrandedTextField(
                          controller: _questionCtrl,
                          label: 'Enunciado',
                          hint: 'Ej: ¿Cómo se dice "Hola" en inglés?',
                          prefixIcon: Icons.quiz_rounded,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 20),
                        BrandedTextField(
                          controller: _answerCtrl,
                          label: 'Respuesta Correcta',
                          hint: 'Ej: Hello',
                          prefixIcon: Icons.check_circle_outline_rounded,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      label: 'Publicar Ejercicio',
                      loading: state.isLoading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ref
                              .read(exerciseNotifierProvider.notifier)
                              .createExercise({
                            'lesson': int.tryParse(_lessonCtrl.text) ?? 0,
                            'question_text': _questionCtrl.text,
                            'exercise_type': _selectedType,
                            'correct_answer': _answerCtrl.text,
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
