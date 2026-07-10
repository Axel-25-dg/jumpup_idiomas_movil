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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next.error.toString()), backgroundColor: Colors.redAccent));
      } else if (next.hasValue && prev?.isLoading == true) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Recurso publicado correctamente'), backgroundColor: Colors.greenAccent));
        Navigator.pop(context);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Subir Recurso', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFAB47BC).withOpacity(0.05),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                GlassContainer(
                  opacity: 0.05,
                  padding: const EdgeInsets.all(20),
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.cloud_upload_rounded, color: Color(0xFFAB47BC), size: 20),
                          SizedBox(width: 8),
                          Text('Detalles del Recurso', 
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      BrandedTextField(
                        controller: titleCtrl, 
                        label: 'Título del material',
                        hint: 'Ej: Guía de Gramática PDF',
                      ),
                      const SizedBox(height: 20),
                      BrandedTextField(
                        controller: courseCtrl,
                        label: 'ID del Curso vinculado',
                        keyboardType: TextInputType.number,
                        hint: 'Ej: 10',
                      ),
                      const SizedBox(height: 20),
                      BrandedTextField(
                        controller: urlCtrl, 
                        label: 'URL del archivo (PDF, MP3, MP4)',
                        hint: 'https://ejemplo.com/archivo.pdf',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                PrimaryButton(
                  label: 'Publicar Recurso Premium',
                  loading: state.isLoading,
                  onPressed: () {
                    if (titleCtrl.text.isEmpty || courseCtrl.text.isEmpty || urlCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, completa todos los campos'), backgroundColor: Colors.orangeAccent)
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
