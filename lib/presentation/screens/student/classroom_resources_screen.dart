import 'package:flutter/material.dart';
import 'package:jumpup_app/theme/colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/core/config/app_config.dart';
import 'package:jumpup_app/presentation/providers/course_providers.dart';
import 'package:jumpup_app/presentation/screens/student/resource_webview_screen.dart';

class ClassroomResourcesScreen extends ConsumerWidget {
  const ClassroomResourcesScreen({super.key, required this.classroomId});

  final int classroomId;

  FileType _parseFileType(String? typeStr) {
    switch (typeStr?.toLowerCase()) {
      case 'pdf':
        return FileType.pdf;
      case 'spreadsheet':
        return FileType.spreadsheet;
      case 'audio':
        return FileType.audio;
      default:
        return FileType.document;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync =
        ref.watch(teacherResourcesProvider(classroomId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Recursos del Aula',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: resourcesAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(
            child: Text('Error: $err',
                style: const TextStyle(color: Colors.redAccent))),
        data: (flatResources) {
          if (flatResources.isEmpty) {
            return const Center(
                child: Text('No hay recursos disponibles',
                    style: TextStyle(color: AppColors.textSecondary)));
          }

          // Dynamically group flat resources by type
          final Map<String, List<Map<String, dynamic>>> grouped = {};
          for (final res in flatResources) {
            final type = res['resource_type']?.toString() ?? 'document';
            grouped.putIfAbsent(type, () => []).add(res);
          }

          // Transform grouped map into folders structure
          final folders = grouped.entries.map((entry) {
            final type = entry.key;
            final resources = entry.value;
            String folderName;
            switch (type.toLowerCase()) {
              case 'pdf':
                folderName = 'Documentos PDF';
                break;
              case 'spreadsheet':
                folderName = 'Hojas de Cálculo';
                break;
              case 'audio':
                folderName = 'Archivos de Audio';
                break;
              case 'video':
                folderName = 'Videos y Clases Grabadas';
                break;
              default:
                folderName = 'Otros Recursos';
            }
            return {
              'folder': folderName,
              'files': resources.map((r) => {
                'name': r['title'] ?? '',
                'size': r['description'] ?? '',
                'type': type,
                'url': r['file_url'] ?? r['file'] ?? '',
              }).toList(),
            };
          }).toList();

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: folders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (_, i) {
              final folder = folders[i];
              final folderName = folder['folder']?.toString() ?? '';
              final filesList = folder['files'] as List<dynamic>? ?? [];

              debugPrint('[ResourcesData] folder=$folderName filesRaw=${filesList.toString()}');
              final List<_FileWidget> filesWidgets = filesList.map((f) {
                final rawUrl = f['url']?.toString() ?? f['file_url']?.toString() ?? '';
                debugPrint('[ResourcesData] file raw=${f.toString()} url=$rawUrl');
                return _FileWidget(
                  name: f['name']?.toString() ?? '',
                  size: f['size']?.toString() ?? '',
                  type: _parseFileType(f['type']?.toString()),
                  url: rawUrl,
                );
              }).toList();

              return _FolderWidget(
                title: folderName,
                fileCount: filesWidgets.length,
                isExpanded: i == 0,
                files: filesWidgets,
              );
            },
          );
        },
      ),
    );
  }
}

enum FileType { pdf, spreadsheet, audio, document, unknown }

class _FolderWidget extends StatelessWidget {
  const _FolderWidget({
    required this.title,
    required this.fileCount,
    required this.isExpanded,
    required this.files,
  });

  final String title;
  final int fileCount;
  final bool isExpanded;
  final List<_FileWidget> files;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          ListTile(
            leading:
                const Icon(Icons.folder, color: AppColors.primary, size: 32),
            title: Text(title,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            subtitle: Text('$fileCount archivos',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            trailing: Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: AppColors.textSecondary),
          ),
          if (isExpanded && files.isNotEmpty) ...[
            const Divider(color: AppColors.divider, height: 1),
            ...files,
          ],
        ],
      ),
    );
  }
}

class _FileWidget extends StatelessWidget {
  const _FileWidget({
    required this.name,
    required this.size,
    required this.type,
    this.url = '',
  });

  final String name;
  final String size;
  final FileType type;
  final String url;

  IconData get _icon {
    switch (type) {
      case FileType.pdf:
        return Icons.picture_as_pdf;
      case FileType.spreadsheet:
        return Icons.grid_on;
      case FileType.audio:
        return Icons.audiotrack;
      case FileType.document:
        return Icons.description;
      case FileType.unknown:
        return Icons.insert_drive_file;
    }
  }

  Color get _color {
    switch (type) {
      case FileType.pdf:
        return const Color(0xFFE53935);
      case FileType.spreadsheet:
        return const Color(0xFF43A047);
      case FileType.audio:
        return const Color(0xFF8E24AA);
      default:
        return const Color(0xFF03A9F4);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: _color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8)),
        child: Icon(_icon, color: _color, size: 20),
      ),
      title:
          Text(name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
      subtitle: Text(size,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      onTap: () async {
        final openUrl = url;
        if (openUrl.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('URL no disponible para $name')),
          );
          return;
        }
        await _openResourceUrl(context, name, openUrl);
      },
      trailing: IconButton(
        icon: const Icon(Icons.open_in_new_rounded, color: AppColors.textSecondary),
        onPressed: () async {
          await _openResourceUrl(context, name, url);
        },
      ),
    );
  }

  Future<void> _openResourceUrl(BuildContext context, String name, String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('URL no disponible para $name')),
      );
      return;
    }

    try {
      final finalUrl = _normalizeResourceUrl(url);
      debugPrint('[Resources] opening url: $finalUrl');

      final finalUri = Uri.tryParse(finalUrl);
      if (finalUri == null || !finalUri.hasAbsolutePath || finalUri.scheme.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('URL inválida: $finalUrl')),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResourceWebViewScreen(url: finalUrl, title: name),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error abriendo URL: $e')),
      );
    }
  }

  String _normalizeResourceUrl(String rawUrl) {
    var cleanUrl = rawUrl.trim();

    if (cleanUrl.isEmpty) {
      return cleanUrl;
    }

    if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      cleanUrl = AppConfig.resolveImageUrl(cleanUrl);
    }

    if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      cleanUrl = 'https://${cleanUrl.replaceFirst(RegExp(r'^/+'), '')}';
    }

    final lower = cleanUrl.toLowerCase();
    if (lower.endsWith('.pdf') ||
        lower.endsWith('.doc') ||
        lower.endsWith('.docx') ||
        lower.endsWith('.xls') ||
        lower.endsWith('.xlsx') ||
        lower.endsWith('.ppt') ||
        lower.endsWith('.pptx')) {
      final encodedUrl = Uri.encodeComponent(cleanUrl);
      return 'https://docs.google.com/gview?embedded=true&url=$encodedUrl';
    }

    return cleanUrl;
  }
}
