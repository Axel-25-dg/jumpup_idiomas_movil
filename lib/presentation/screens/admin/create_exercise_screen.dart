import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/presentation/providers/exercise_provider.dart';


class CreateExerciseScreen extends ConsumerStatefulWidget {
  const CreateExerciseScreen({super.key});

  @override
  ConsumerState<CreateExerciseScreen> createState() => _CreateExerciseScreenState();
}

class _CreateExerciseScreenState extends ConsumerState<CreateExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lessonCtrl = TextEditingController();
  final _questionCtrl = TextEditingController();
  final _answerCtrl = TextEditingController();
  
  String _selectedType = 'multiple_choice';
  final List<String> _exerciseTypes = ['multiple_choice', 'translate', 'listen', 'fill_blank', 'match'];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exerciseNotifierProvider);

    ref.listen(exerciseNotifierProvider, (prev, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${next.error}')));
      } else if (next is AsyncData && prev?.isLoading == true) {
        Navigator.pop(context);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Ejercicio')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              BrandedTextField(controller: _lessonCtrl, label: 'ID de la Lección', keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(labelText: 'Tipo de Ejercicio', border: OutlineInputBorder()),
                items: _exerciseTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
              const SizedBox(height: 16),
              BrandedTextField(controller: _questionCtrl, label: 'Enunciado'),
              const SizedBox(height: 16),
              BrandedTextField(controller: _answerCtrl, label: 'Respuesta Correcta'),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Guardar Ejercicio',
                loading: state.isLoading,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ref.read(exerciseNotifierProvider.notifier).createExercise({
                      'lesson': int.tryParse(_lessonCtrl.text) ?? 0,
                      'question_text': _questionCtrl.text,
                      'exercise_type': _selectedType,
                      'correct_answer': _answerCtrl.text,
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    ); 
  }
}