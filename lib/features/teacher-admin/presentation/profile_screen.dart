import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/features/auth/widgets/branded_text_field.dart';
import 'package:jumpup_app/features/auth/widgets/primary_button.dart';
import 'package:jumpup_app/features/teacher-admin/presentation/providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();

  // MANTENEMOS ESTOS IDs LISTOS
  // Cuando integres el provider de idiomas, estos se llenarán dinámicamente
  final List<int> _selectedLearning = []; 
  final List<int> _selectedTeaching = [];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileNotifierProvider);

    ref.listen(profileNotifierProvider, (prev, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${next.error}')));
      } else if (next is AsyncData && prev?.isLoading == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            BrandedTextField(controller: _firstNameCtrl, label: 'Nombre'),
            const SizedBox(height: 16),
            BrandedTextField(controller: _lastNameCtrl, label: 'Apellido'),
            const SizedBox(height: 24),
            
            // TODO: Integrar aquí el widget de selección de idiomas cuando el 
            // provider de idiomas (#27) esté listo.
            const ListTile(
              title: Text("Idiomas"),
              subtitle: Text("Configuración pendiente de sincronización"),
              leading: Icon(Icons.language),
            ),
            
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Guardar Cambios',
              loading: state.isLoading,
              onPressed: () {
                ref.read(profileNotifierProvider.notifier).updateProfile(
                  firstName: _firstNameCtrl.text,
                  lastName: _lastNameCtrl.text,
                  languagesLearning: _selectedLearning,
                  languagesTeaching: _selectedTeaching,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}