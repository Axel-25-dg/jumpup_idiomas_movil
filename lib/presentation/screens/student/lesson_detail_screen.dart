import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/course_models.dart';
import 'package:jumpup_app/presentation/providers/course_providers.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:lottie/lottie.dart';
import 'exercise_screen.dart';
import 'package:jumpup_app/core/config/app_config.dart';
import 'package:jumpup_app/presentation/screens/student/resource_webview_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' hide PlayerState;

class LessonDetailScreen extends ConsumerStatefulWidget {
  const LessonDetailScreen({super.key, required this.lessonId});

  final int lessonId;

  @override
  ConsumerState<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends ConsumerState<LessonDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlayingAudio = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio(String? url) async {
    if (url == null || url.isEmpty) return;

    if (_isPlayingAudio) {
      await _audioPlayer.pause();
    } else {
      final source = url.startsWith('http') ? UrlSource(url) : DeviceFileSource(url);
      await _audioPlayer.play(source);
    }
  }

  void _showVideoPlayer(BuildContext context, String videoId, String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (context) => _YouTubePlayerModal(videoId: videoId, title: title),
    );
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
                  '${lesson.title} (ID: ${lesson.id})',
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
              _buildMaterialTab(lesson.id),
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

  Widget _buildReadingTab(LessonModel lesson) {
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
                        'Lectura sugerida',
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
                    lesson.title,
                    style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    lesson.contentBody ?? 'No hay contenido disponible para esta lección.',
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

  Widget _buildAudioTab(LessonModel lesson) {
    if (lesson.audioUrl == null || lesson.audioUrl!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.music_off_rounded, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              'No hay audio disponible',
              style: AppTextStyles.titleMedium.copyWith(color: Colors.white54),
            ),
          ],
        ),
      );
    }

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
                    onTap: () => _toggleAudio(lesson.audioUrl),
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
                'Escucha la pronunciación correcta y mejora tu acento.',
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
                  onPressed: () => _toggleAudio(lesson.audioUrl),
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

  Widget _buildMaterialTab(int lessonId) {
    return Consumer(
      builder: (context, ref, child) {
        final resourcesAsync = ref.watch(lessonResourcesProvider(lessonId));

        return resourcesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
          error: (err, _) => Center(
            child: Text('Error al cargar recursos', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54)),
          ),
          data: (resources) {
            if (resources.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.folder_open_rounded, size: 64, color: Colors.white24),
                    const SizedBox(height: 16),
                    Text(
                      'No hay materiales adicionales',
                      style: AppTextStyles.titleMedium.copyWith(color: Colors.white54),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: resources.length,
              itemBuilder: (context, i) {
                final resource = resources[i];
                final type = resource.resourceType.toLowerCase();
                final isVideo = type == 'video' || (resource.fileUrl?.contains('youtube.com') ?? false) || (resource.fileUrl?.contains('youtu.be') ?? false);
                final isAudio = type == 'audio' || (resource.fileUrl?.endsWith('.mp3') ?? false);
                final isPdf = type == 'pdf' || (resource.fileUrl?.endsWith('.pdf') ?? false);

                return FadeInRight(
                  delay: Duration(milliseconds: i * 100),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GlassContainer(
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        onTap: () {
                          var fileUrl = resource.fileUrl?.trim() ?? '';
                          if (fileUrl.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('URL del recurso no disponible'),
                                backgroundColor: Color(0xFF1E1E2E),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }
                          
                          if (isVideo) {
                            final videoId = YoutubePlayer.convertUrlToId(fileUrl);
                            if (videoId != null) {
                              _showVideoPlayer(context, videoId, resource.title);
                              return;
                            }
                          }

                          if (!fileUrl.startsWith('http://') && !fileUrl.startsWith('https://')) {
                            fileUrl = AppConfig.resolveImageUrl(fileUrl);
                          }
                          
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ResourceWebViewScreen(url: fileUrl, title: resource.title),
                            ),
                          );
                        },
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (isPdf ? Colors.redAccent : isVideo ? Colors.orangeAccent : isAudio ? Colors.greenAccent : Colors.blueAccent).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isPdf ? Icons.picture_as_pdf_rounded : isVideo ? Icons.play_circle_fill_rounded : isAudio ? Icons.audiotrack_rounded : Icons.insert_drive_file_rounded, 
                            color: isPdf ? Colors.redAccent : isVideo ? Colors.orangeAccent : isAudio ? Colors.greenAccent : Colors.blueAccent, 
                            size: 24
                          ),
                        ),
                        title: Text(
                          resource.title,
                          style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        subtitle: Text(
                          resource.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(color: Colors.white54),
                        ),
                        trailing: Icon(isVideo ? Icons.play_arrow_rounded : Icons.open_in_new_rounded, color: Colors.blueAccent),
                      ),
                    ),
                  ),
                );
              },
            );
          },
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

class _YouTubePlayerModal extends StatefulWidget {
  final String videoId;
  final String title;
  const _YouTubePlayerModal({required this.videoId, required this.title});

  @override
  State<_YouTubePlayerModal> createState() => _YouTubePlayerModalState();
}

class _YouTubePlayerModalState extends State<_YouTubePlayerModal> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFF0F111A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.blueAccent,
                onReady: () {
                  // _controller.addListener(listener);
                },
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

