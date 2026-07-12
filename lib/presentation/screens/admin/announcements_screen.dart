// lib/presentation/screens/admin/announcements_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/announcement_model.dart';
import 'package:jumpup_app/presentation/providers/announcement_provider.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/empty_state.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/theme/app_theme.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class AnnouncementsScreen extends ConsumerStatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  ConsumerState<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends ConsumerState<AnnouncementsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isActive = true;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final announcementsAsync = ref.watch(announcementNotifierProvider);
    final notifier = ref.read(announcementNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      body: Stack(
        children: [
          // Background Blobs
          Positioned(
            top: -100,
            left: -100,
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
            right: -50,
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
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: const Text(
                    'Announcements',
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
                    tooltip: 'Create Announcement',
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
                    onPressed: () => notifier.refresh(),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
              
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                sliver: announcementsAsync.when(
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
                  ),
                  error: (error, stack) => SliverFillRemaining(
                    child: _buildErrorView(error, notifier),
                  ),
                  data: (announcements) {
                    if (announcements.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyState(
                          title: 'No announcements found',
                          subtitle: 'Create your first announcement to reach your students',
                          icon: Icons.campaign_rounded,
                          buttonText: 'Create Announcement',
                          onButtonPressed: () => _showAddEditDialog(context),
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final announcement = announcements[index];
                          return _AnnouncementCard(
                            announcement: announcement,
                            onEdit: () => _showAddEditDialog(
                              context,
                              announcement: announcement,
                            ),
                            onDelete: () => _confirmDelete(
                              context,
                              announcement.id,
                              notifier,
                            ),
                            onToggleStatus: () async {
                              try {
                                await notifier.updateAnnouncement(
                                  id: announcement.id,
                                  title: announcement.title,
                                  content: announcement.content,
                                  startDate: announcement.startDate,
                                  endDate: announcement.endDate,
                                  isActive: !announcement.isActive,
                                );
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: ${e.toString()}')),
                                  );
                                }
                              }
                            },
                          );
                        },
                        childCount: announcements.length,
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

  Widget _buildErrorView(Object error, AnnouncementNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          const Text('Error loading announcements',
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
            onPressed: () => notifier.refresh(),
            icon: Icons.refresh_rounded,
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {Announcement? announcement}) {
    if (announcement != null) {
      _titleController.text = announcement.title;
      _contentController.text = announcement.content;
      _startDate = announcement.startDate;
      _endDate = announcement.endDate;
      _isActive = announcement.isActive;
    } else {
      _titleController.clear();
      _contentController.clear();
      _startDate = null;
      _endDate = null;
      _isActive = true;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(announcement != null ? 'Edit Announcement' : 'Create Announcement',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 450,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BrandedTextField(
                    controller: _titleController,
                    label: 'Announcement Title',
                    prefixIcon: Icons.title_rounded,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Title is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  BrandedTextField(
                    controller: _contentController,
                    label: 'Content',
                    prefixIcon: Icons.description_rounded,
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Content is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text('Scheduling', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _DatePickerField(
                          label: 'Start Date',
                          date: _startDate,
                          onChanged: (date) =>
                              setState(() => _startDate = date),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DatePickerField(
                          label: 'End Date',
                          date: _endDate,
                          onChanged: (date) => setState(() => _endDate = date),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () => setState(() => _isActive = !_isActive),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _isActive,
                            activeColor: const Color(0xFF7C4DFF),
                            checkColor: Colors.white,
                            onChanged: (value) =>
                                setState(() => _isActive = value ?? true),
                          ),
                          const Text('Publish Immediately',
                              style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
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
            label: announcement != null ? 'Update' : 'Publish',
            onPressed: () async { // Hacer asíncrono
              if (_formKey.currentState!.validate() &&
                  _startDate != null &&
                  _endDate != null) {
                final notifier =
                    ref.read(announcementNotifierProvider.notifier);

                try {
                  if (announcement != null) {
                    await notifier.updateAnnouncement(
                      id: announcement.id,
                      title: _titleController.text.trim(),
                      content: _contentController.text.trim(),
                      startDate: _startDate!,
                      endDate: _endDate!,
                      isActive: _isActive,
                    );
                  } else {
                    await notifier.createAnnouncement(
                      title: _titleController.text.trim(),
                      content: _contentController.text.trim(),
                      startDate: _startDate!,
                      endDate: _endDate!,
                      isActive: _isActive,
                    );
                  }
                  
                  if (mounted) Navigator.pop(ctx);
                } catch (e) {
                  // Mostrar error si falla
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, int id, AnnouncementNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Announcement',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to delete this announcement?\n'
          'This action cannot be undone.',
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
            color: AppColors.error,
            onPressed: () async {
              try {
                await notifier.deleteAnnouncement(id);
                if (context.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onChanged,
  });

  final String label;
  final DateTime? date;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: Color(0xFF7C4DFF),
                      onPrimary: Colors.white,
                      surface: Color(0xFF1E1E2A),
                      onSurface: Colors.white,
                  ),
                  dialogTheme: const DialogThemeData(
                    backgroundColor: Color(0xFF1E1E2A),
                  ),
                ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              onChanged(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 16, color: Color(0xFF7C4DFF)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date != null
                        ? '${date!.day}/${date!.month}/${date!.year}'
                        : 'Select',
                    style: TextStyle(
                      fontSize: 13,
                      color: date != null ? Colors.white : Colors.white38,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({
    required this.announcement,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  final Announcement announcement;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  bool get _isCurrentlyActive {
    final now = DateTime.now();
    return announcement.isActive &&
        announcement.startDate.isBefore(now) &&
        announcement.endDate.isAfter(now);
  }

  @override
  Widget build(BuildContext context) {
    final currentlyActive = _isCurrentlyActive;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(20),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          leading: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: currentlyActive
                  ? const Color(0xFF7C4DFF).withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: currentlyActive 
                  ? const Color(0xFF7C4DFF).withValues(alpha: 0.2)
                  : Colors.white10
              ),
            ),
            child: Icon(
              Icons.campaign_rounded,
              color: currentlyActive ? const Color(0xFF7C4DFF) : Colors.white38,
              size: 24,
            ),
          ),
          title: Text(
            announcement.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 15,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Text(
                announcement.content,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: currentlyActive
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      currentlyActive ? 'ACTIVE' : 'INACTIVE',
                      style: TextStyle(
                        color: currentlyActive ? Colors.green : Colors.red,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.access_time_rounded, size: 12, color: Colors.white24),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatDate(announcement.startDate)} - ${_formatDate(announcement.endDate)}',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  announcement.isActive
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: announcement.isActive ? const Color(0xFF00E5FF) : Colors.white24,
                  size: 20,
                ),
                onPressed: onToggleStatus,
                tooltip: announcement.isActive ? 'Hide' : 'Show',
              ),
              IconButton(
                icon: const Icon(Icons.edit_rounded, size: 20),
                onPressed: onEdit,
                color: Colors.white38,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                onPressed: onDelete,
                color: AppColors.error.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
