import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/resource_provider.dart';
import 'package:jumpup_app/presentation/screens/admin/upload_resource_screen.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class ResourceLibraryScreen extends ConsumerWidget {
  const ResourceLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync = ref.watch(resourcesListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Biblioteca de Recursos',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(resourcesListProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFAB47BC),
        child: const Icon(Icons.cloud_upload_rounded, color: Colors.white),
        onPressed: () async {
          await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const UploadResourceScreen()));
          ref.invalidate(resourcesListProvider);
        },
      ),
      body: Stack(
        children: [
          // Background Blobs
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFAB47BC).withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFAB47BC).withValues(alpha: 0.1),
                    blurRadius: 100,
                  )
                ],
              ),
            ),
          ),
          resourcesAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator(color: Color(0xFFAB47BC))),
            error: (e, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text('Error: $e',
                      style: const TextStyle(color: Colors.redAccent)),
                ],
              ),
            ),
            data: (resources) {
              if (resources.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.folder_open_rounded,
                          size: 64, color: Colors.white30),
                      SizedBox(height: 12),
                      Text('No has subido recursos',
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                      SizedBox(height: 8),
                      Text('Sube PDFs, Audios o Videos para tus alumnos.',
                          style: TextStyle(color: Colors.white54)),
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
                      padding: const EdgeInsets.all(16),
                      borderRadius: BorderRadius.circular(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFFAB47BC).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(Icons.insert_drive_file,
                                color: Color(0xFFAB47BC), size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(res.title,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(
                                    'Tipo: ${res.resourceType.toUpperCase()} | Curso ID: ${res.course}',
                                    style: const TextStyle(
                                        color: Colors.white38, fontSize: 12)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.download_rounded,
                                color: Colors.white24),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Descarga iniciada...')));
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
        ],
      ),
    );
  }
}
