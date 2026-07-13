import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/resource_model.dart';
import 'package:jumpup_app/presentation/providers/resource_provider.dart';

class ResourceEditorScreen extends ConsumerStatefulWidget {
  const ResourceEditorScreen({super.key, required this.resource});

  final TeacherResource resource;

  @override
  ConsumerState<ResourceEditorScreen> createState() => _ResourceEditorScreenState();
}

class _ResourceEditorScreenState extends ConsumerState<ResourceEditorScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _urlCtrl;
  late final TextEditingController _descriptionCtrl;
  late String _type;
  late bool _isPublic;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.resource.title);
    _urlCtrl = TextEditingController(text: widget.resource.fileUrl ?? '');
    _descriptionCtrl = TextEditingController(text: widget.resource.description);
    _type = widget.resource.resourceType;
    _isPublic = widget.resource.isPublic;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _urlCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty || _urlCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa título y URL del recurso')),
      );
      return;
    }

    final success = await ref.read(resourceManagerProvider.notifier).updateResource(
      resourceId: widget.resource.id,
      title: _titleCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      fileUrl: _urlCtrl.text.trim(),
      resourceType: _type,
      isPublic: _isPublic,
    );

    if (!mounted) return;
    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo actualizar el recurso')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar recurso'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Guardar')),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionCtrl,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Tipo'),
              items: const [
                DropdownMenuItem(value: 'pdf', child: Text('PDF')),
                DropdownMenuItem(value: 'video', child: Text('Video')),
                DropdownMenuItem(value: 'audio', child: Text('Audio')),
                DropdownMenuItem(value: 'document', child: Text('Documento')),
              ],
              onChanged: (value) => setState(() => _type = value ?? 'document'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _urlCtrl,
              decoration: const InputDecoration(labelText: 'URL o enlace'),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Visible para estudiantes'),
              value: _isPublic,
              onChanged: (value) => setState(() => _isPublic = value),
            ),
          ],
        ),
      ),
    );
  }
}
