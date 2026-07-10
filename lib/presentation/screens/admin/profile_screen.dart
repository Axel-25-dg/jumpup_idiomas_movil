import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/presentation/providers/profile_provider.dart';
import 'package:jumpup_app/presentation/providers/course_provider.dart';

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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${next.error}')));
      } else if (next is AsyncData && prev?.isLoading == true) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
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

            const Text('Idiomas que enseñas (Teaching)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ref.watch(adminLanguagesProvider).when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
              data: (languages) {
                return Wrap(
                  spacing: 8,
                  children: languages.map((lang) {
                    final isSelected = _selectedTeaching.contains(lang.id);
                    return FilterChip(
                      label: Text(lang.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTeaching.add(lang.id);
                          } else {
                            _selectedTeaching.remove(lang.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                );
              },
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
