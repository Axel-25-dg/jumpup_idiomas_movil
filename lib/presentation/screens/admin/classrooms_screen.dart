// lib/presentation/screens/admin/classrooms_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/classroom_model.dart';
import 'package:jumpup_app/presentation/providers/classroom_provider.dart';
import 'package:jumpup_app/presentation/providers/enrollment_provider.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/empty_state.dart';
import 'package:jumpup_app/presentation/widgets/loading_overlay.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/theme/app_theme.dart';

import 'package:jumpup_app/widgets/glass_container.dart';


class ClassroomsScreen extends ConsumerStatefulWidget {
  const ClassroomsScreen({super.key});

  @override
  ConsumerState<ClassroomsScreen> createState() => _ClassroomsScreenState();
}

class _ClassroomsScreenState extends ConsumerState<ClassroomsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _courseIdController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _courseIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final classroomsAsync = ref.watch(classroomsListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      body: Stack(
        children: [
          // Background Decorative Blobs
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C4DFF).withValues(alpha: 0.15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                    blurRadius: 100,
                  )
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                    blurRadius: 80,
                  )
                ],
              ),
            ),
          ),

          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: const Text(
                    'Virtual Classrooms',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1E1E2A),
                          const Color(0xFF0F0E1A).withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add_rounded, color: Color(0xFF00E5FF)),
                    onPressed: () => _showAddEditDialog(context),
                    tooltip: 'Create Classroom',
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
                    onPressed: () => ref.invalidate(classroomsListProvider),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                sliver: classroomsAsync.when(
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
                  ),
                  error: (error, stack) => SliverFillRemaining(
                    child: _buildErrorView(error),
                  ),
                  data: (classrooms) {
                    if (classrooms.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyState(
                          title: 'No classrooms created',
                          subtitle: 'Start by creating your first virtual group',
                          icon: Icons.class_rounded,
                          buttonText: 'Create Classroom',
                          onButtonPressed: () => _showAddEditDialog(context),
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final classroom = classrooms[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ClassroomCard(
                              classroom: classroom,
                              onEdit: () => _showAddEditDialog(
                                  context,
                                  classroom: classroom,
                                ),
                              onDelete: () => _confirmDelete(
                                  context,
                                  classroom.id,
                                  ref.read(classroomNotifierProvider.notifier),
                                ),
                              onViewStudents: () => _showStudentsDialog(
                                context,
                                classroom.id,
                                classroom.name,
                              ),
                            ),
                          );
                        },
                        childCount: classrooms.length,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          const Text('Error loading classrooms',
              style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: const TextStyle(color: Colors.white54, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Retry',
            onPressed: () => ref.invalidate(classroomsListProvider),
            icon: Icons.refresh_rounded,
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {ClassroomModel? classroom}) {
    if (classroom != null) {
      _nameController.text = classroom.name;
      _descriptionController.text = classroom.description;
      _courseIdController.text = classroom.courseId.toString();
    } else {
      _nameController.clear();
      _descriptionController.clear();
      _courseIdController.clear();
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(classroom != null ? 'Edit Classroom' : 'Create Classroom',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 400,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BrandedTextField(
                    controller: _nameController,
                    label: 'Classroom Name',
                    prefixIcon: Icons.class_rounded,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  BrandedTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    prefixIcon: Icons.description_rounded,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  BrandedTextField(
                    controller: _courseIdController,
                    label: 'Course ID',
                    prefixIcon: Icons.menu_book_rounded,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Course ID is required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white38)),
          ),
          PrimaryButton(
            label: classroom != null ? 'Update' : 'Create',
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final notifier = ref.read(classroomNotifierProvider.notifier);

                if (classroom != null) {
                  await notifier.update(
                    classroom.id,
                    _nameController.text.trim(),
                    _descriptionController.text.trim(),
                    int.tryParse(_courseIdController.text.trim()) ?? 0,
                  );
                } else {
                  await notifier.create(
                    _nameController.text.trim(),
                    _descriptionController.text.trim(),
                    int.parse(_courseIdController.text.trim()),
                  );
                }
                ref.invalidate(classroomsListProvider);
                if (context.mounted) Navigator.pop(ctx);
              }
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id, ClassroomNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Classroom',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to delete this classroom?\n'
          'This action will remove all associated enrollments.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white38)),
          ),
          PrimaryButton(
            label: 'Delete',
            onPressed: () async {
              await notifier.delete(id);
              ref.invalidate(classroomsListProvider);
              if (context.mounted) Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  void _showStudentsDialog(
      BuildContext context, int classroomId, String className) {
    final enrollmentsAsync = ref.watch(enrollmentsProvider(classroomId));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Students in $className',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 400,
          height: 350,
          child: enrollmentsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
            error: (error, _) => Center(
              child: Text(
                'Error loading students: $error',
                style: const TextStyle(color: AppColors.error),
              ),
            ),
            data: (enrollments) {
              if (enrollments.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline_rounded,
                          size: 48, color: Colors.white10),
                      SizedBox(height: 12),
                      Text(
                        'No students enrolled',
                        style: TextStyle(color: Colors.white38),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: enrollments.length,
                itemBuilder: (context, index) {
                  final enrollment = enrollments[index];
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                      child: Text(
                        enrollment.studentUsername.isNotEmpty
                            ? enrollment.studentUsername[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7C4DFF),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Text(
                      enrollment.studentUsername,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      enrollment.studentEmail,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_rounded,
                          color: AppColors.error, size: 20),
                      onPressed: () {
                        final notifier =
                            ref.read(enrollmentNotifierProvider.notifier);
                        notifier.removeStudent(
                          classroomId: classroomId,
                          studentId: enrollment.studentId,
                        );
                        ref.invalidate(enrollmentsProvider(classroomId));
                        if (mounted) {
                          Navigator.pop(ctx);
                          _showStudentsDialog(context, classroomId, className);
                        }
                      },
                      tooltip: 'Remove student',
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Close', style: TextStyle(color: Colors.white38)),
          ),
        ],
      ),
    );
  }
}

class _ClassroomCard extends StatelessWidget {
  const _ClassroomCard({
    required this.classroom,
    required this.onEdit,
    required this.onDelete,
    required this.onViewStudents,
  });

  final ClassroomModel classroom;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewStudents;

  @override
  Widget build(BuildContext context) {
    final accentColor = const Color(0xFF7C4DFF);

    return GlassContainer(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.class_rounded,
            color: accentColor,
            size: 22,
          ),
        ),
        title: Text(
          classroom.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (classroom.description.isNotEmpty) ...[
              Text(
                classroom.description,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
            ],
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _buildBadge(
                  text: 'Course: ${classroom.courseId}',
                  color: AppColors.secondary,
                ),
                _buildBadge(
                  text: classroom.isActive ? 'Active' : 'Inactive',
                  color: classroom.isActive ? Colors.green : Colors.red,
                ),
                _buildBadge(
                  text: 'Code: ${classroom.accessCode}',
                  color: Colors.blue,
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.people_rounded, size: 18),
              onPressed: onViewStudents,
              color: Colors.blue,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'View Students',
            ),
            IconButton(
              icon: const Icon(Icons.edit_rounded, size: 18),
              onPressed: onEdit,
              color: Colors.white38,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              onPressed: onDelete,
              color: AppColors.error.withValues(alpha: 0.7),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge({required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}