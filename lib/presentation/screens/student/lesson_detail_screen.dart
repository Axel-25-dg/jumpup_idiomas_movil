import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/course_providers.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:lottie/lottie.dart';
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
      backgroundColor: const Color(0xFF0F111A),
      body: lessonAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.blueAccent)),
        error: (err, _) => _ErrorState(onRetry: () => ref.refresh(lessonDetailsProvider(widget.lessonId))),
        data: (lesson) => NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 140.0,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: const Color(0xFF0F111A),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
                title: Text(
                  lesson.title,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1A0533), Color(0xFF0F111A)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Icon(Icons.auto_stories_rounded, size: 140, color: Colors.blueAccent.withValues(alpha: 0.1)),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                Container(
                  color: const Color(0xFF0F111A),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.blueAccent,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: Colors.blueAccent,
                    unselectedLabelColor: Colors.white54,
                    labelStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
                    tabs: const [
                      Tab(icon: Icon(Icons.article_rounded), text: 'Lectura'),
                      Tab(icon: Icon(Icons.volume_up_rounded), text: 'Audio'),
                      Tab(icon: Icon(Icons.file_present_rounded), text: 'Material'),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildReadingTab(lesson),
              _buildAudioTab(lesson),
              _buildMaterialTab(lesson),
            ],
          ),
        ),
      ),
      bottomNavigationBar: lessonAsync.maybeWhen(
        data: (lesson) => Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: FadeInUp(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2575FC).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExerciseScreen(lessonId: lesson.id),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bolt_rounded, color: Colors.amber),
                      const SizedBox(width: 12),
                      Text(
                        'PRACTICAR AHORA',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildReadingTab(dynamic lesson) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: FadeIn(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 16, color: Colors.blueAccent),
                      const SizedBox(width: 6),
                      Text(
                        'Lectura de 5 min',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.stars_rounded, size: 16, color: Colors.purpleAccent),
                      const SizedBox(width: 6),
                      Text(
                        '${lesson.xpReward} XP',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.purpleAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contenido de la Lección',
                    style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '¡Bienvenido a esta lección práctica! En esta sesión aprenderás conceptos clave del idioma, prestando especial atención a las estructuras conversacionales básicas. Estudia detenidamente los siguientes enunciados:\n\n'
                    '1. Greeting people (Saludar a las personas):\n'
                    '   • "Hello, how are you?" (Hola, ¿cómo estás?)\n'
                    '   • "I am doing well, thank you." (Estoy bien, gracias.)\n\n'
                    '2. Introducing yourself (Presentarte):\n'
                    '   • "My name is Carlos." (Mi nombre es Carlos.)\n'
                    '   • "Nice to meet you." (Gusto en conocerte.)\n\n'
                    '3. Farwells (Despedidas):\n'
                    '   • "Goodbye! Have a nice day." (¡Adiós! Que tengas un buen día.)\n'
                    '   • "See you later." (Te veo luego.)\n\n'
                    'Consejo: Recuerda practicar la entonación y repasar el vocabulario en voz alta para afianzar tu racha de aprendizaje diaria.',
                    style: AppTextStyles.bodyLarge.copyWith(
                      height: 1.8,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 120), // Space for bottom button
          ],
        ),
      ),
    );
  }

  Widget _buildAudioTab(dynamic lesson) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: FadeInUp(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blueAccent.withValues(alpha: 0.05),
                      border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.1)),
                    ),
                  ),
                  if (_isPlayingAudio)
                    Lottie.network(
                      'https://assets5.lottiefiles.com/packages/lf20_tiviyv33.json', // Audio wave animation
                      width: 300,
                      height: 300,
                    ),
                  GestureDetector(
                    onTap: () => setState(() => _isPlayingAudio = !_isPlayingAudio),
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2575FC), Color(0xFF6A11CB)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withValues(alpha: 0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isPlayingAudio ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Text(
                _isPlayingAudio ? 'Escuchando ahora' : 'Audio de Soporte',
                style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w900, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                'Escucha la pronunciación correcta por hablantes nativos y mejora tu acento.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 40),
              GlassContainer(
                width: 240,
                opacity: 0.1,
                padding: EdgeInsets.zero,
                borderRadius: BorderRadius.circular(30),
                child: FilledButton(
                  onPressed: () => setState(() => _isPlayingAudio = !_isPlayingAudio),
                  style: FilledButton.styleFrom(
                    backgroundColor: _isPlayingAudio ? Colors.redAccent.withValues(alpha: 0.2) : Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    _isPlayingAudio ? 'DETENER' : 'REPRODUCIR',
                    style: TextStyle(color: _isPlayingAudio ? Colors.redAccent : Colors.blueAccent, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialTab(dynamic lesson) {
    final pdfFiles = [
      {'name': 'Guía de Vocabulario Oficial', 'size': '1.4 MB'},
      {'name': 'Ejercicios Adicionales Resueltos', 'size': '920 KB'},
      {'name': 'Lista de Verbos Irregulares', 'size': '2.1 MB'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: pdfFiles.length,
      itemBuilder: (context, i) {
        final pdf = pdfFiles[i];
        return FadeInRight(
          delay: Duration(milliseconds: i * 100),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GlassContainer(
              padding: EdgeInsets.zero,
              child: ListTile(
                onTap: () {
                   ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Abriendo ${pdf['name']}...'),
                      backgroundColor: const Color(0xFF1E1E2E),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent, size: 24),
                ),
                title: Text(
                  pdf['name']!,
                  style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
                ),
                subtitle: Text(
                  pdf['size']!,
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white54),
                ),
                trailing: const Icon(Icons.download_for_offline_rounded, color: Colors.blueAccent),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._child);

  final Widget _child;

  @override
  double get minExtent => 60;
  @override
  double get maxExtent => 60;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _child;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text('Error al cargar la lección', style: AppTextStyles.titleMedium),
          TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}

