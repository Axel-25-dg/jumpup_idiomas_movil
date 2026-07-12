import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/presentation/providers/exercise_provider.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${next.error}'), backgroundColor: Colors.redAccent));
      } else if (next is AsyncData && prev?.isLoading == true) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Ejercicio creado con éxito'), backgroundColor: Colors.greenAccent));
        Navigator.pop(context);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Crear Ejercicio', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 100,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFD54F).withValues(alpha: 0.05),
                boxShadow: [BoxShadow(color: const Color(0xFFFFD54F).withValues(alpha: 0.05), blurRadius: 90)],
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GlassContainer(
                    opacity: 0.05,
                    padding: const EdgeInsets.all(20),
                    borderRadius: BorderRadius.circular(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.quiz_rounded, color: Color(0xFFFFD54F), size: 20),
                            SizedBox(width: 8),
                            Text('Configuración del Ejercicio', 
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text('Tipo de actividad', 
                          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          dropdownColor: const Color(0xFF1A1828),
                          initialValue: _selectedType,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.05),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                          items: _exerciseTypes.entries
                              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                              .toList(),
                          onChanged: (val) => setState(() => _selectedType = val!),
                        ),
                        const SizedBox(height: 20),
                        BrandedTextField(
                          controller: _lessonCtrl,
                          label: 'ID de la Lección vinculada',
                          keyboardType: TextInputType.number,
                          hint: 'Ej: 42',
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'El ID de la lección es obligatorio';
                            final id = int.tryParse(v.trim());
                            if (id == null || id <= 0) return 'Ingresa un ID válido (número mayor a 0)';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        BrandedTextField(
                          controller: _questionCtrl, 
                          label: 'Enunciado de la pregunta',
                          hint: 'Ej: ¿Cómo se dice "Hola" en inglés?',
                          maxLines: 2,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'El enunciado es obligatorio';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        BrandedTextField(
                          controller: _answerCtrl, 
                          label: 'Respuesta Correcta',
                          hint: 'Ej: Hello',
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'La respuesta correcta es obligatoria';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  PrimaryButton(
                    label: 'Publicar Ejercicio',
                    loading: state.isLoading,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ref.read(exerciseNotifierProvider.notifier).createExercise({
                          'lesson': int.parse(_lessonCtrl.text.trim()),
                          'question_text': _questionCtrl.text.trim(),
                          'exercise_type': _selectedType,
                          'correct_answer': _answerCtrl.text.trim(),
                        });
                      }
                    },
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
