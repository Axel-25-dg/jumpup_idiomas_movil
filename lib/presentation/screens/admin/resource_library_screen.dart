import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/core/config/app_config.dart';
import 'package:jumpup_app/presentation/providers/resource_provider.dart';
import 'package:jumpup_app/presentation/screens/admin/upload_resource_screen.dart';
import 'package:jumpup_app/presentation/screens/student/resource_webview_screen.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class ResourceLibraryScreen extends ConsumerWidget {
  const ResourceLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync = ref.watch(resourcesListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1828),
        elevation: 0,
        title: const Text('Biblioteca de Recursos', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(resourcesListProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF8A65),
        child: const Icon(Icons.upload_file, color: Colors.white),
        onPressed: () async {
          await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const UploadResourceScreen()));
          ref.invalidate(resourcesListProvider);
        },
      ),
      body: resourcesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFFF8A65))),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text('Error: $e', style: const TextStyle(color: Colors.redAccent)),
            ],
          ),
        ),
        data: (resources) {
          if (resources.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.folder_open_rounded, size: 64, color: Colors.white30),
                  SizedBox(height: 12),
                  Text('No has subido recursos', style: TextStyle(color: Colors.white, fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Sube PDFs, Audios o Videos para tus alumnos.', style: TextStyle(color: Colors.white54)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: resources.length,
            itemBuilder: (context, index) {
              final res = resources[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassContainer(
                  opacity: 0.1,
                  blur: 10,
                  padding: const EdgeInsets.all(16),
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8A65).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.insert_drive_file, color: Color(0xFFFF8A65), size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(res.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Tipo: ${res.resourceType.toUpperCase()} | Curso ID: ${res.course}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.open_in_new_rounded, color: Colors.white54),
                        onPressed: () {
                          var fileUrl = res.fileUrl?.trim() ?? '';
                          if (fileUrl.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('URL del recurso no disponible')),
                            );
                            return;
                          }
                          if (!fileUrl.startsWith('http://') && !fileUrl.startsWith('https://')) {
                            fileUrl = AppConfig.resolveImageUrl(fileUrl);
                          }
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ResourceWebViewScreen(url: fileUrl, title: res.title),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }


}
