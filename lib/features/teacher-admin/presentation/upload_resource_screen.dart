import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/features/auth/widgets/branded_text_field.dart';
import 'package:jumpup_app/features/auth/widgets/primary_button.dart';
import 'package:jumpup_app/features/teacher-admin/presentation/providers/resource_provider.dart';

class UploadResourceScreen extends ConsumerStatefulWidget {
  const UploadResourceScreen({super.key});

  @override
  ConsumerState<UploadResourceScreen> createState() => _UploadResourceScreenState();
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.error.toString())));
      } else if (next.hasValue && prev?.isLoading == true) {
        Navigator.pop(context); // Cerramos si fue exitoso
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Recurso')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            BrandedTextField(controller: titleCtrl, label: 'Título del material'),
            const SizedBox(height: 10),
            BrandedTextField(controller: courseCtrl, label: 'ID del Curso', keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            BrandedTextField(controller: urlCtrl, label: 'URL del archivo'),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Publicar',
              loading: state.isLoading,
              onPressed: () {
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
    );
  }
}