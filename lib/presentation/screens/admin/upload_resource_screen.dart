import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/presentation/providers/resource_provider.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class UploadResourceScreen extends ConsumerStatefulWidget {
  const UploadResourceScreen({super.key});

  @override
  ConsumerState<UploadResourceScreen> createState() =>
      _UploadResourceScreenState();
}

class _UploadResourceScreenState extends ConsumerState<UploadResourceScreen> {
  late final TextEditingController titleCtrl;
  late final TextEditingController urlCtrl;
  late final TextEditingController courseCtrl;

  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController();
    urlCtrl = TextEditingController();
    courseCtrl = TextEditingController();
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    urlCtrl.dispose();
    courseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resourceUploadProvider);

    ref.listen(resourceUploadProvider, (prev, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: Colors.redAccent,
          ),
        );
      } else if (next.hasValue && prev?.isLoading == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recurso publicado correctamente'),
            backgroundColor: Colors.greenAccent,
          ),
        );
        Navigator.pop(context);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Subir Recurso',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
                color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                    blurRadius: 100,
                  )
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Detalles del Material",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BrandedTextField(
                        controller: titleCtrl,
                        label: 'Título del material',
                        hint: 'Ej: Guía de Gramática PDF',
                        prefixIcon: Icons.title,
                      ),
                      const SizedBox(height: 20),
                      BrandedTextField(
                        controller: courseCtrl,
                        label: 'ID del Curso vinculado',
                        keyboardType: TextInputType.number,
                        hint: 'Ej: 10',
                        prefixIcon: Icons.book_rounded,
                      ),
                      const SizedBox(height: 20),
                      BrandedTextField(
                        controller: urlCtrl,
                        label: 'URL del archivo (PDF, MP3, MP4)',
                        hint: 'https://ejemplo.com/archivo.pdf',
                        prefixIcon: Icons.link_rounded,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'Publicar Recurso',
                    loading: state.isLoading,
                    onPressed: () {
                      if (titleCtrl.text.isEmpty ||
                          courseCtrl.text.isEmpty ||
                          urlCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Por favor, completa todos los campos'),
                            backgroundColor: Colors.orangeAccent,
                          ),
                        );
                        return;
                      }
                      ref.read(resourceUploadProvider.notifier).create(
                            title: titleCtrl.text,
                            courseId: int.parse(courseCtrl.text),
                            fileUrl: urlCtrl.text,
                          );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
