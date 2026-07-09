import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/course_providers.dart';
import 'exercise_screen.dart';

class LessonDetailScreen extends ConsumerStatefulWidget {
  const LessonDetailScreen({super.key, required this.lessonId});

  final int lessonId;

  @override
  ConsumerState<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends ConsumerState<LessonDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lessonAsync = ref.watch(lessonDetailsProvider(widget.lessonId));

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1828),
        title: lessonAsync.when(
          data: (lesson) => Text(lesson.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          loading: () => const Text('Cargando...', style: TextStyle(color: Colors.white)),
          error: (_, __) => const Text('Detalle de Lección', style: TextStyle(color: Colors.white)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: lessonAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
        error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent))),
        data: (lesson) => Column(
          children: [
            // ── TabBar Multimedia ──────────────────────────────────
            Container(
              color: const Color(0xFF1A1828),
              child: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF7C4DFF),
                labelColor: const Color(0xFF7C4DFF),
                unselectedLabelColor: Colors.white54,
                tabs: const [
                  Tab(icon: Icon(Icons.article_outlined), text: 'Lectura'),
                  Tab(icon: Icon(Icons.headphones_outlined), text: 'Audio'),
                  Tab(icon: Icon(Icons.picture_as_pdf_outlined), text: 'Soporte PDF'),
                ],
              ),
            ),

            // ── TabBarView ─────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 1. Lectura
                  _buildReadingTab(lesson),
                  // 2. Audio
                  _buildAudioTab(lesson),
                  // 3. Soporte PDF
                  _buildPdfTab(lesson),
                ],
              ),
            ),

            // ── Botón Iniciar Quiz ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navega a ExerciseScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _TemporaryExerciseScreenWrapper(lessonId: lesson.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.quiz_outlined, color: Colors.white),
                  label: const Text('Iniciar Quiz Práctico', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C4DFF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingTab(dynamic lesson) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lesson.title,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.access_time, color: Colors.white38, size: 16),
              SizedBox(width: 6),
              Text('5 min de lectura', style: TextStyle(color: Colors.white38, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            '¡Bienvenido a esta lección práctica! En esta sesión aprenderás conceptos clave del idioma, prestando especial atención a las estructuras conversacionales básicas. Estudia detenidamente los siguientes enunciados:\n\n'
            '1. Greeting people (Saludar a las personas):\n'
            '   - "Hello, how are you?" (Hola, ¿cómo estás?)\n'
            '   - "I am doing well, thank you." (Estoy bien, gracias.)\n\n'
            '2. Introducing yourself (Presentarte):\n'
            '   - "My name is Carlos." (Mi nombre es Carlos.)\n'
            '   - "Nice to meet you." (Gusto en conocerte.)\n\n'
            '3. Farwells (Despedidas):\n'
            '   - "Goodbye! Have a nice day." (¡Adiós! Que tengas un buen día.)\n'
            '   - "See you later." (Te veo luego.)\n\n'
            'Consejo: Recuerda practicar la entonación y repasar el vocabulario en voz alta para afianzar tu racha de aprendizaje diaria.',
            style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioTab(dynamic lesson) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1828),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF7C4DFF).withOpacity(0.3), width: 3),
              ),
              child: Icon(
                _isPlayingAudio ? Icons.graphic_eq : Icons.headphones,
                color: const Color(0xFF7C4DFF),
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _isPlayingAudio ? 'Reproduciendo audio de soporte...' : 'Audio de la lección disponible',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Escucha la pronunciación correcta por hablantes nativos.',
              style: TextStyle(color: Colors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _isPlayingAudio = !_isPlayingAudio);
              },
              icon: Icon(_isPlayingAudio ? Icons.pause : Icons.play_arrow, color: Colors.white),
              label: Text(_isPlayingAudio ? 'Pausar Reproducción' : 'Escuchar Lección', style: const TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1828),
                side: const BorderSide(color: Color(0xFF7C4DFF)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfTab(dynamic lesson) {
    final pdfFiles = [
      {'name': 'Guía de Vocabulario Oficial.pdf', 'size': '1.4 MB'},
      {'name': 'Ejercicios Adicionales Resueltos.pdf', 'size': '920 KB'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: pdfFiles.length,
      itemBuilder: (context, i) {
        final pdf = pdfFiles[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1828),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFE53935).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.picture_as_pdf, color: Color(0xFFE53935), size: 24),
            ),
            title: Text(pdf['name']!, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            subtitle: Text(pdf['size']!, style: const TextStyle(color: Colors.white38, fontSize: 12)),
            trailing: IconButton(
              icon: const Icon(Icons.download, color: Colors.white54),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Descargando ${pdf['name']}...')),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// Wrapper temporal importando ExerciseScreen diferida para evitar conflictos circulares
class _TemporaryExerciseScreenWrapper extends StatelessWidget {
  const _TemporaryExerciseScreenWrapper({required this.lessonId});
  final int lessonId;

  @override
  Widget build(BuildContext context) {
    return ExerciseScreen(lessonId: lessonId);
  }
}
