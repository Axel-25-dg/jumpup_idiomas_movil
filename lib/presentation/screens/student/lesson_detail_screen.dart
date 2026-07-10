import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/course_providers.dart';
import 'package:jumpup_app/presentation/screens/student/widgets/student_shared_widgets.dart';
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
      backgroundColor: AppColors.background,
      body: lessonAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => _ErrorState(onRetry: () => ref.refresh(lessonDetailsProvider(widget.lessonId))),
        data: (lesson) => NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 120.0,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: AppColors.primary,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  lesson.title,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.secondary,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(icon: Icon(Icons.article_rounded), text: 'Lectura'),
                    Tab(icon: Icon(Icons.volume_up_rounded), text: 'Audio'),
                    Tab(icon: Icon(Icons.file_present_rounded), text: 'Material'),
                  ],
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: FadeInUp(
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
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.psychology_alt_rounded),
                    const SizedBox(width: 12),
                    Text(
                      'PRACTICAR AHORA',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 14, color: AppColors.secondary),
                      const SizedBox(width: 4),
                      Text(
                        'Lectura de 5 min',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Contenido de la Lección',
              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800),
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
                color: AppColors.textPrimary.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 100), // Space for bottom button
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
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.05),
                    ),
                  ),
                  if (_isPlayingAudio)
                    Lottie.network(
                      'https://assets5.lottiefiles.com/packages/lf20_tiviyv33.json', // Audio wave animation
                      width: 280,
                      height: 280,
                    ),
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
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
                ],
              ),
              const SizedBox(height: 48),
              Text(
                _isPlayingAudio ? 'Escuchando ahora' : 'Audio de Soporte',
                style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Text(
                'Escucha la pronunciación correcta por hablantes nativos y mejora tu acento.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                child: FilledButton(
                  onPressed: () => setState(() => _isPlayingAudio = !_isPlayingAudio),
                  style: FilledButton.styleFrom(
                    backgroundColor: _isPlayingAudio ? AppColors.error : AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(_isPlayingAudio ? 'DETENER' : 'REPRODUCIR'),
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
          child: StudentCard(
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Abriendo ${pdf['name']}...'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pdf['name']!,
                        style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        pdf['size']!,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.download_for_offline_rounded, color: AppColors.primary),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      child: _tabBar,
    );
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

