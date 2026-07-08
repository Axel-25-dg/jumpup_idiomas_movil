import 'package:flutter/material.dart';

class ClassroomResourcesScreen extends StatelessWidget {
  const ClassroomResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1828),
        title: const Text('Recursos del Aula', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _FolderWidget(
            title: 'Módulo 1: Conceptos Básicos',
            fileCount: 3,
            isExpanded: true,
            files: [
              _FileWidget(name: 'Guía de Gramática Básica.pdf', size: '2.4 MB', type: FileType.pdf),
              _FileWidget(name: 'Lista de Vocabulario.xlsx', size: '150 KB', type: FileType.spreadsheet),
              _FileWidget(name: 'Audio Pronunciación.mp3', size: '4.1 MB', type: FileType.audio),
            ],
          ),
          SizedBox(height: 16),
          _FolderWidget(
            title: 'Módulo 2: Conversación Práctica',
            fileCount: 2,
            isExpanded: false,
            files: [],
          ),
          SizedBox(height: 16),
          _FolderWidget(
            title: 'Material Extra (Lecturas)',
            fileCount: 5,
            isExpanded: false,
            files: [],
          ),
        ],
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
            leading: const Icon(Icons.folder, color: Color(0xFF7C4DFF), size: 32),
            title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text('$fileCount archivos', style: const TextStyle(color: Colors.white54, fontSize: 12)),
            trailing: Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.white54),
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
        decoration: BoxDecoration(color: _color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
        child: Icon(_icon, color: _color, size: 20),
      ),
      title: Text(name, style: const TextStyle(color: Colors.white, fontSize: 14)),
      subtitle: Text(size, style: const TextStyle(color: Colors.white38, fontSize: 11)),
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
