import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/course_providers.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'package:jumpup_app/theme/app_theme.dart';

class ClassroomResourcesScreen extends ConsumerWidget {
  const ClassroomResourcesScreen({super.key});

  FileType _parseFileType(String? typeStr) {
    switch (typeStr?.toLowerCase()) {
      case 'pdf':
        return FileType.pdf;
      case 'spreadsheet':
      case 'excel':
      case 'csv':
        return FileType.spreadsheet;
      case 'audio':
      case 'mp3':
      case 'wav':
        return FileType.audio;
      default:
        return FileType.document;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Demo classroomId = 1. En producción esto vendría de los argumentos o un provider de selección.
    final resourcesAsync = ref.watch(teacherResourcesProvider(1));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F111A) : const Color(0xFFF0F4F8);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Background Decorative Blobs
          Positioned(
            top: -100,
            right: -50,
            child: _blob(const Color(0xFF6A11CB), 300),
          ),
          Positioned(
            bottom: 200,
            left: -100,
            child: _blob(const Color(0xFF2575FC), 400),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Modern Header ───────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
                flexibleSpace: FlexibleSpaceBar(
                  background: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF6A11CB).withValues(alpha: 0.8),
                              const Color(0xFF2575FC).withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              '📚 Biblioteca',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'Recursos y materiales de estudio',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Content ──────────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                sliver: resourcesAsync.when(
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF2575FC))),
                  ),
                  error: (err, _) => SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Error: $err',
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ),
                  data: (folders) {
                    if (folders.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.folder_open_rounded, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No hay recursos disponibles',
                                style: TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final folder = folders[i];
                          final folderName = folder['folder']?.toString() ?? 'General';
                          final filesList = folder['files'] as List<dynamic>? ?? [];

                          return _FolderGlassWidget(
                            title: folderName,
                            fileCount: filesList.length,
                            isExpanded: i == 0, // Expand first by default
                            files: filesList.map((f) {
                              return _FileItem(
                                name: f['name']?.toString() ?? 'Archivo',
                                size: f['size']?.toString() ?? 'N/A',
                                type: _parseFileType(f['type']?.toString()),
                              );
                            }).toList(),
                          );
                        },
                        childCount: folders.length,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _blob(Color color, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.1),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 100)
          ],
        ),
      );
}

class _FolderGlassWidget extends StatefulWidget {
  const _FolderGlassWidget({
    required this.title,
    required this.fileCount,
    required this.isExpanded,
    required this.files,
  });

  final String title;
  final int fileCount;
  final bool isExpanded;
  final List<_FileItem> files;

  @override
  State<_FolderGlassWidget> createState() => _FolderGlassWidgetState();
}

class _FolderGlassWidgetState extends State<_FolderGlassWidget> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            ListTile(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2575FC).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.folder_rounded, color: Color(0xFF2575FC), size: 28),
              ),
              title: Text(
                widget.title,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                '${widget.fileCount} archivos',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontSize: 12,
                ),
              ),
              trailing: Icon(
                _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
            if (_isExpanded && widget.files.isNotEmpty) ...[
              const Divider(height: 1, indent: 20, endIndent: 20, color: Colors.white12),
              ...widget.files,
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

enum FileType { pdf, spreadsheet, audio, document, unknown }

class _FileItem extends StatelessWidget {
  const _FileItem({
    required this.name,
    required this.size,
    required this.type,
  });

  final String name;
  final String size;
  final FileType type;

  IconData get _icon {
    switch (type) {
      case FileType.pdf: return Icons.picture_as_pdf_rounded;
      case FileType.spreadsheet: return Icons.table_chart_rounded;
      case FileType.audio: return Icons.audiotrack_rounded;
      case FileType.document: return Icons.description_rounded;
      case FileType.unknown: return Icons.insert_drive_file_rounded;
    }
  }

  Color get _color {
    switch (type) {
      case FileType.pdf: return const Color(0xFFFF5252);
      case FileType.spreadsheet: return const Color(0xFF00C853);
      case FileType.audio: return const Color(0xFFAA00FF);
      default: return const Color(0xFF00B0FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(_icon, color: _color, size: 20),
      ),
      title: Text(
        name,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        size,
        style: TextStyle(
          color: isDark ? Colors.white38 : Colors.black38,
          fontSize: 11,
        ),
      ),
      trailing: IconButton(
        icon: Icon(Icons.download_rounded, color: isDark ? Colors.white24 : Colors.black26),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Descargando $name...'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        },
      ),
    );
  }
}
