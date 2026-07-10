import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/profile_provider.dart';
import 'package:jumpup_app/presentation/providers/course_provider.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'package:jumpup_app/widgets/neon_button.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final List<int> _selectedTeaching = [];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileNotifierProvider);
    final languagesAsync = ref.watch(adminLanguagesProvider);

    ref.listen(profileNotifierProvider, (prev, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${next.error}'), backgroundColor: Colors.redAccent));
      } else if (next is AsyncData && prev?.isLoading == true) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Perfil actualizado'), backgroundColor: Colors.greenAccent));
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      body: Stack(
        children: [
          // Background Blobs
          Positioned(top: -100, right: -100, child: _blob(const Color(0xFF6A11CB), 300)),
          Positioned(bottom: -50, left: -50, child: _blob(const Color(0xFF2575FC), 250)),
          
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text('Editar Perfil', 
                    style: AppTextStyles.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
                  centerTitle: true,
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF1A1D2E), Colors.transparent],
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    GlassContainer(
                      padding: const EdgeInsets.all(24),
                      borderRadius: BorderRadius.circular(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Información Básica',
                              style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          BrandedTextField(
                            controller: _firstNameCtrl,
                            label: 'Nombre',
                          ),
                          const SizedBox(height: 16),
                          BrandedTextField(
                            controller: _lastNameCtrl,
                            label: 'Apellido',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    GlassContainer(
                      padding: const EdgeInsets.all(24),
                      borderRadius: BorderRadius.circular(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Especialidades',
                              style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Idiomas que enseñas',
                              style: AppTextStyles.bodySmall.copyWith(color: Colors.white54)),
                          const SizedBox(height: 16),
                          languagesAsync.when(
                            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
                            error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.redAccent)),
                            data: (languages) {
                              return Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: languages.map((lang) {
                                  final isSelected = _selectedTeaching.contains(lang.id);
                                  return FilterChip(
                                    label: Text(lang.name),
                                    selected: isSelected,
                                    selectedColor: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
                                    checkmarkColor: Colors.white,
                                    labelStyle: TextStyle(
                                      color: isSelected ? Colors.white : Colors.white70,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(color: isSelected ? const Color(0xFF7C4DFF) : Colors.white10),
                                    ),
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    NeonButton(
                      text: 'Guardar Cambios',
                      onPressed: state.isLoading ? null : () {
                        ref.read(profileNotifierProvider.notifier).updateProfile(
                              firstName: _firstNameCtrl.text,
                              lastName: _lastNameCtrl.text,
                              languagesLearning: [], // Adjust if needed
                              languagesTeaching: _selectedTeaching,
                            );
                      },
                    ),
                    if (state.isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
                      ),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _blob(Color color, double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withValues(alpha: 0.1),
      boxShadow: [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 100)],
    ),
  );
}
