import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/presentation/providers/exercise_provider.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'package:jumpup_app/domain/model/admin/admin_course_model.dart';
import 'package:jumpup_app/presentation/providers/teacher_repository_provider.dart';
import 'package:jumpup_app/presentation/providers/course_provider.dart';
import 'package:jumpup_app/presentation/providers/lesson_provider.dart';

class CreateExerciseScreen extends ConsumerStatefulWidget {
  const CreateExerciseScreen({super.key});

  @override
  ConsumerState<CreateExerciseScreen> createState() =>
      _CreateExerciseScreenState();
}

class _CreateExerciseScreenState extends ConsumerState<CreateExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionCtrl = TextEditingController();
  final _answerCtrl = TextEditingController();

  // Multiple Choice distractors
  final _opt1Ctrl = TextEditingController();
  final _opt2Ctrl = TextEditingController();
  final _opt3Ctrl = TextEditingController();

  // Match columns
  final _left1Ctrl = TextEditingController();
  final _right1Ctrl = TextEditingController();
  final _left2Ctrl = TextEditingController();
  final _right2Ctrl = TextEditingController();
  final _left3Ctrl = TextEditingController();
  final _right3Ctrl = TextEditingController();
  final _left4Ctrl = TextEditingController();
  final _right4Ctrl = TextEditingController();

  int? _selectedCourseId;
  int? _selectedModuleId;
  int? _selectedLessonId;

  String _selectedType = 'multiple_choice';
  final Map<String, String> _exerciseTypes = {
    'multiple_choice': 'Opción Múltiple',
    'translate': 'Traducción',
    'listen': 'Escucha (Listening)',
    'fill_blank': 'Completar espacio',
    'match': 'Relacionar columnas'
  };

  @override
  void dispose() {
    _questionCtrl.dispose();
    _answerCtrl.dispose();
    _opt1Ctrl.dispose();
    _opt2Ctrl.dispose();
    _opt3Ctrl.dispose();
    _left1Ctrl.dispose();
    _right1Ctrl.dispose();
    _left2Ctrl.dispose();
    _right2Ctrl.dispose();
    _left3Ctrl.dispose();
    _right3Ctrl.dispose();
    _left4Ctrl.dispose();
    _right4Ctrl.dispose();
    super.dispose();
  }

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
                          value: _selectedType,
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
                        const Text('Curso', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        FutureBuilder<List<Course>>(
                          future: ref.read(teacherRepositoryProvider).fetchCourses(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text('Cargando cursos...', style: TextStyle(color: Colors.white70)),
                              );
                            }
                            if (snapshot.hasError || !snapshot.hasData) {
                              return const Text('Error al cargar cursos', style: TextStyle(color: Colors.redAccent));
                            }
                            final courses = snapshot.data!;
                            return DropdownButtonFormField<int>(
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: Color(0xFF122033),
                              ),
                              value: _selectedCourseId,
                              items: courses.map((c) {
                                return DropdownMenuItem<int>(
                                  value: c.id,
                                  child: Text('${c.title} (id: ${c.id})', style: const TextStyle(color: Colors.white)),
                                );
                              }).toList(),
                              onChanged: (v) {
                                setState(() {
                                  _selectedCourseId = v;
                                  _selectedModuleId = null;
                                  _selectedLessonId = null;
                                });
                              },
                              hint: const Text('Selecciona un curso', style: TextStyle(color: Colors.white70)),
                            );
                          },
                        ),
                        if (_selectedCourseId != null) ...[
                          const SizedBox(height: 20),
                          const Text('Módulo', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Consumer(
                            builder: (context, ref, child) {
                              final modulesAsync = ref.watch(modulesForCourseProvider(_selectedCourseId!));
                              return modulesAsync.when(
                                loading: () => const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text('Cargando módulos...', style: TextStyle(color: Colors.white70)),
                                ),
                                error: (err, _) => const Text('Error al cargar módulos', style: TextStyle(color: Colors.redAccent)),
                                data: (modules) {
                                  if (modules.isEmpty) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 8.0),
                                      child: Text('No hay módulos creados para este curso. Por favor, crea un módulo primero.', style: TextStyle(color: Colors.orangeAccent)),
                                    );
                                  }
                                  return DropdownButtonFormField<int>(
                                    decoration: const InputDecoration(
                                      filled: true,
                                      fillColor: Color(0xFF122033),
                                    ),
                                    value: _selectedModuleId,
                                    items: modules.map((m) {
                                      final id = m['id'] as int;
                                      final title = m['title'] as String;
                                      return DropdownMenuItem<int>(
                                        value: id,
                                        child: Text('$title (ID: $id)', style: const TextStyle(color: Colors.white)),
                                      );
                                    }).toList(),
                                    onChanged: (v) {
                                      setState(() {
                                        _selectedModuleId = v;
                                        _selectedLessonId = null;
                                      });
                                    },
                                    hint: const Text('Selecciona un módulo', style: TextStyle(color: Colors.white70)),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                        if (_selectedModuleId != null) ...[
                          const SizedBox(height: 20),
                          const Text('Lección', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Consumer(
                            builder: (context, ref, child) {
                              final lessonsAsync = ref.watch(lessonsByModuleProvider(_selectedModuleId!));
                              return lessonsAsync.when(
                                loading: () => const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text('Cargando lecciones...', style: TextStyle(color: Colors.white70)),
                                ),
                                error: (err, _) => const Text('Error al cargar lecciones', style: TextStyle(color: Colors.redAccent)),
                                data: (lessons) {
                                  if (lessons.isEmpty) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 8.0),
                                      child: Text('No hay lecciones en este módulo.', style: TextStyle(color: Colors.orangeAccent)),
                                    );
                                  }
                                  return DropdownButtonFormField<int>(
                                    decoration: const InputDecoration(
                                      filled: true,
                                      fillColor: Color(0xFF122033),
                                    ),
                                    value: _selectedLessonId,
                                    items: lessons.map((l) {
                                      return DropdownMenuItem<int>(
                                        value: l.id,
                                        child: Text('${l.title} (ID: ${l.id})', style: const TextStyle(color: Colors.white)),
                                      );
                                    }).toList(),
                                    onChanged: (v) => setState(() => _selectedLessonId = v),
                                    hint: const Text('Selecciona una lección', style: TextStyle(color: Colors.white70)),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                        const SizedBox(height: 20),
                        if (_selectedType == 'match') ...[
                          BrandedTextField(
                            controller: _questionCtrl, 
                            label: 'Instrucciones del ejercicio',
                            hint: 'Ej: Relaciona los animales con sus nombres en inglés',
                            maxLines: 2,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Las instrucciones son obligatorias';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          const Text('Columnas de Emparejamiento', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 12),
                          _buildMatchPairRow(1, _left1Ctrl, _right1Ctrl),
                          const SizedBox(height: 12),
                          _buildMatchPairRow(2, _left2Ctrl, _right2Ctrl),
                          const SizedBox(height: 12),
                          _buildMatchPairRow(3, _left3Ctrl, _right3Ctrl),
                          const SizedBox(height: 12),
                          _buildMatchPairRow(4, _left4Ctrl, _right4Ctrl),
                        ] else ...[
                          BrandedTextField(
                            controller: _questionCtrl, 
                            label: _selectedType == 'listen' 
                                ? 'Texto/Palabra para escuchar' 
                                : (_selectedType == 'translate' ? 'Frase en idioma origen' : 'Enunciado de la pregunta'),
                            hint: _selectedType == 'listen' 
                                ? 'Ej: Hello world' 
                                : (_selectedType == 'translate' ? 'Ej: ¿Cómo estás?' : 'Ej: ¿Cómo se dice "Hola" en inglés?'),
                            maxLines: 2,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Este campo es obligatorio';
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
                          if (_selectedType == 'multiple_choice') ...[
                            const SizedBox(height: 20),
                            const Text('Opciones Incorrectas (Distractores)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            BrandedTextField(
                              controller: _opt1Ctrl,
                              label: 'Opción Incorrecta 1',
                              hint: 'Ej: Bye',
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Esta opción es obligatoria';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            BrandedTextField(
                              controller: _opt2Ctrl,
                              label: 'Opción Incorrecta 2',
                              hint: 'Ej: Good morning',
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Esta opción es obligatoria';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            BrandedTextField(
                              controller: _opt3Ctrl,
                              label: 'Opción Incorrecta 3',
                              hint: 'Ej: Thank you',
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Esta opción es obligatoria';
                                return null;
                              },
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  PrimaryButton(
                    label: 'Publicar Ejercicio',
                    loading: state.isLoading,
                    onPressed: () {
                      if (_selectedLessonId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Por favor, selecciona una lección'), backgroundColor: Colors.orangeAccent)
                        );
                        return;
                      }
                      if (_formKey.currentState!.validate()) {
                        final Map<String, dynamic> payload = {
                          'lesson': _selectedLessonId,
                          'exercise_type': _selectedType,
                        };

                        if (_selectedType == 'match') {
                          final List<String> lefts = [
                            _left1Ctrl.text.trim(),
                            _left2Ctrl.text.trim(),
                            _left3Ctrl.text.trim(),
                            _left4Ctrl.text.trim(),
                          ];
                          final List<String> rights = [
                            _right1Ctrl.text.trim(),
                            _right2Ctrl.text.trim(),
                            _right3Ctrl.text.trim(),
                            _right4Ctrl.text.trim(),
                          ];

                          payload['question_text'] = _questionCtrl.text.trim();
                          payload['options'] = lefts;
                          payload['correct_answer'] = rights.join(',');
                        } else {
                          payload['question_text'] = _questionCtrl.text.trim();
                          payload['correct_answer'] = _answerCtrl.text.trim();

                          if (_selectedType == 'multiple_choice') {
                            payload['options'] = [
                              _answerCtrl.text.trim(),
                              _opt1Ctrl.text.trim(),
                              _opt2Ctrl.text.trim(),
                              _opt3Ctrl.text.trim(),
                            ];
                          }
                        }

                        ref.read(exerciseNotifierProvider.notifier).createExercise(payload);
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

  Widget _buildMatchPairRow(int number, TextEditingController left, TextEditingController right) {
    return Row(
      children: [
        Expanded(
          child: BrandedTextField(
            controller: left,
            label: 'Fila $number - Izquierda',
            hint: 'Ej: Dog',
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Obligatorio';
              return null;
            },
          ),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.swap_horiz_rounded, color: Colors.blueAccent),
        const SizedBox(width: 12),
        Expanded(
          child: BrandedTextField(
            controller: right,
            label: 'Fila $number - Derecha',
            hint: 'Ej: Perro',
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Obligatorio';
              return null;
            },
          ),
        ),
      ],
    );
  }
}
