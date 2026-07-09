import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/course_providers.dart';

class ClassroomResourcesScreen extends ConsumerWidget {
  const ClassroomResourcesScreen({super.key});

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
        ref.watch(teacherResourcesProvider(1)); // Demo classroomId = 1

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1828),
        title: const Text('Recursos del Aula',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: resourcesAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
        error: (err, _) => Center(
            child: Text('Error: $err',
                style: const TextStyle(color: Colors.redAccent))),
        data: (folders) {
          if (folders.isEmpty) {
            return const Center(
                child: Text('No hay recursos disponibles',
                    style: TextStyle(color: Colors.white54)));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: folders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (_, i) {
              final folder = folders[i];
              final folderName = folder['folder']?.toString() ?? '';
              final filesList = folder['files'] as List<dynamic>? ?? [];

              final List<_FileWidget> filesWidgets = filesList.map((f) {
                return _FileWidget(
                  name: f['name']?.toString() ?? '',
                  size: f['size']?.toString() ?? '',
                  type: _parseFileType(f['type']?.toString()),
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
        color: const Color(0xFF1A1828),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          ListTile(
            leading:
                const Icon(Icons.folder, color: Color(0xFF7C4DFF), size: 32),
            title: Text(title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text('$fileCount archivos',
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
            trailing: Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: Colors.white54),
          ),
          if (isExpanded && files.isNotEmpty) ...[
            const Divider(color: Colors.white12, height: 1),
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
  });

  final String name;
  final String size;
  final FileType type;

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
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 14)),
      subtitle: Text(size,
          style: const TextStyle(color: Colors.white38, fontSize: 11)),
      trailing: IconButton(
        icon: const Icon(Icons.download, color: Colors.white54),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Descargando $name...')),
          );
        },
      ),
    );
  }
}
