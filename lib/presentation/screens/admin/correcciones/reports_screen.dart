// lib/presentation/screens/admin/reports_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/report_model.dart';
import 'package:jumpup_app/presentation/providers/correcciones/report_provider.dart';
import 'package:jumpup_app/presentation/widgets/empty_state.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/theme/app_theme.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String _statusFilter = 'TODOS';

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(reportNotifierProvider);
    final notifier = ref.read(reportNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      body: Stack(
        children: [
          // Background Blobs
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
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: const Text(
                    'Content Reports',
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
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
                    onPressed: () => notifier.refresh(),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
              
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _StatusChip(
                          label: 'All',
                          selected: _statusFilter == 'TODOS',
                          onSelected: () => setState(() => _statusFilter = 'TODOS'),
                        ),
                        const SizedBox(width: 8),
                        _StatusChip(
                          label: 'Pending',
                          selected: _statusFilter == 'OPEN',
                          onSelected: () => setState(() => _statusFilter = 'OPEN'),
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        _StatusChip(
                          label: 'In Progress',
                          selected: _statusFilter == 'IN_PROGRESS',
                          onSelected: () => setState(() => _statusFilter = 'IN_PROGRESS'),
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        _StatusChip(
                          label: 'Resolved',
                          selected: _statusFilter == 'RESOLVED',
                          onSelected: () => setState(() => _statusFilter = 'RESOLVED'),
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        _StatusChip(
                          label: 'Rejected',
                          selected: _statusFilter == 'REJECTED',
                          onSelected: () => setState(() => _statusFilter = 'REJECTED'),
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                sliver: reportsAsync.when(
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
                  ),
                  error: (error, stack) => SliverFillRemaining(
                    child: _buildErrorView(error, notifier),
                  ),
                  data: (reports) {
                    final filtered = _filterReports(reports);
                    if (filtered.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyState(
                          title: 'No reports found',
                          subtitle: _statusFilter != 'TODOS'
                              ? 'No reports with the selected status'
                              : 'All reports have been processed',
                          icon: Icons.flag_rounded,
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final report = filtered[index];
                          return _ReportCard(
                            report: report,
                            onUpdateStatus: (status) {
                              notifier.updateReport(report.id, {'status': status});
                            },
                          );
                        },
                        childCount: filtered.length,
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

  List<Report> _filterReports(List<Report> reports) {
    if (_statusFilter == 'TODOS') return reports;
    return reports.where((r) => r.status == _statusFilter).toList();
  }

  Widget _buildErrorView(Object error, ReportNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          const Text('Error loading reports',
              style: TextStyle(color: Colors.white, fontSize: 18)),
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
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? const Color(0xFF7C4DFF);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        backgroundColor: Colors.white.withValues(alpha: 0.05),
        selectedColor: chipColor.withValues(alpha: 0.2),
        checkmarkColor: chipColor,
        labelStyle: TextStyle(
            color: selected ? chipColor : Colors.white60,
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? chipColor : Colors.white12,
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatefulWidget {
  const _ReportCard({
    required this.report,
    required this.onUpdateStatus,
  });

  final Report report;
  final Function(String) onUpdateStatus;

  @override
  State<_ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<_ReportCard> {
  bool _isExpanded = false;

  Color _getStatusColor(String status) {
    switch (status) {
      case 'OPEN':
        return Colors.orange;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'RESOLVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'OPEN':
        return 'Pending';
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'RESOLVED':
        return 'Resolved';
      case 'REJECTED':
        return 'Rejected';
      default:
        return status;
    }
  }

  List<String> _getAvailableStatuses(String currentStatus) {
    const all = ['OPEN', 'IN_PROGRESS', 'RESOLVED', 'REJECTED'];
    return all.where((s) => s != currentStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(widget.report.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(20),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                  ),
                  child: Icon(
                    Icons.flag_rounded,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                title: Text(
                  'Report #${widget.report.id}',
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
                      widget.report.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: _isExpanded ? null : 2,
                      overflow: _isExpanded ? null : TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getStatusLabel(widget.report.status).toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              color: statusColor,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.access_time_rounded, size: 12, color: Colors.white24),
                        const SizedBox(width: 4),
                        Text(
                          _formatRelativeDate(widget.report.createdAt),
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(
                    _isExpanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: Colors.white38,
                  ),
                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                ),
              ),
              if (_isExpanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(color: Colors.white10, height: 24),
                      const Text(
                        'Update Status',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white38,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _getAvailableStatuses(widget.report.status)
                              .map((status) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: SizedBox(
                                width: 120,
                                height: 36,
                                child: PrimaryButton(
                                  label: _getStatusLabel(status),
                                  fontSize: 11,
                                  onPressed: () => widget.onUpdateStatus(status),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}