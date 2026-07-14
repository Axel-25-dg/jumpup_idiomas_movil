// lib/presentation/screens/admin/certificates_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/certificate_model.dart';
import 'package:jumpup_app/domain/model/admin/admin_user_model.dart';
import 'package:jumpup_app/presentation/providers/certificate_provider.dart';
import 'package:jumpup_app/presentation/providers/user_provider.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/empty_state.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'package:jumpup_app/presentation/screens/admin/certificates_dialogs.dart';

class CertificatesAdminScreen extends ConsumerStatefulWidget {
  const CertificatesAdminScreen({super.key});

  @override
  ConsumerState<CertificatesAdminScreen> createState() => _CertificatesAdminScreenState();
}

class _CertificatesAdminScreenState extends ConsumerState<CertificatesAdminScreen> with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'TODOS';
  late AnimationController _blobController;

  @override
  void initState() {
    super.initState();
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(certificateNotifierProvider.notifier).fetchCertificates();
    });
  }

  @override
  void dispose() {
    _blobController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final certificatesAsync = ref.watch(certificateNotifierProvider);
    final notifier = ref.read(certificateNotifierProvider.notifier);
    final studentsAsync = ref.watch(studentsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(studentsAsync, notifier),
      body: Stack(
        children: [
          _buildBackground(),
          Column(
            children: [
              const SizedBox(height: kToolbarHeight + 40),
              _buildSearchAndFilter(),
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFF7C4DFF),
                  backgroundColor: const Color(0xFF1E1E2A),
                  onRefresh: () => notifier.refresh(),
                  child: certificatesAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
                    error: (error, stack) => _buildErrorView(error, notifier),
                    data: (certificates) => _buildCertificateList(certificates, notifier, studentsAsync),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── BUILDERS ──────────────────────────────────────────────────────────

  AppBar _buildAppBar(AsyncValue<List<User>> studentsAsync, CertificateNotifier notifier) {
    return AppBar(
      title: const Text(
        'Gestión de Certificados',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(color: Colors.transparent),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_rounded),
          onPressed: () {
            HapticFeedback.lightImpact();
            showCertificateDialog(ref, context, studentsAsync);
          },
          tooltip: 'Crear Certificado',
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: () {
            HapticFeedback.lightImpact();
            notifier.refresh();
          },
          tooltip: 'Refrescar',
        ),
      ],
    );
  }

  Widget _buildBackground() {
    return AnimatedBuilder(
      animation: _blobController,
      builder: (context, child) => Stack(
        children: [
          Positioned(
            top: -100 + (30 * _blobController.value),
            right: -50 + (20 * _blobController.value),
            child: _Blob(color: const Color(0xFF7C4DFF), size: 350, opacity: 0.12),
          ),
          Positioned(
            bottom: 100 - (30 * _blobController.value),
            left: -80 + (15 * _blobController.value),
            child: _Blob(color: const Color(0xFF00E5FF), size: 300, opacity: 0.08),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.all(14),
        blur: 20,
        opacity: 0.08,
        child: Column(
          children: [
            BrandedTextField(
              controller: _searchController,
              label: 'Buscar certificados',
              hint: 'Título, estudiante o código...',
              prefixIcon: Icons.search_rounded,
            ),
            const SizedBox(height: 10),
            // ✅ Usar SingleChildScrollView con physics para mejor scroll
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _FilterChip(
                    label: 'Todos',
                    selected: _statusFilter == 'TODOS',
                    onSelected: () => setState(() => _statusFilter = 'TODOS'),
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  _FilterChip(
                    label: 'Pendiente',
                    selected: _statusFilter == 'pending',
                    onSelected: () => setState(() => _statusFilter = 'pending'),
                    color: const Color(0xFFFFA726),
                  ),
                  const SizedBox(width: 6),
                  _FilterChip(
                    label: 'Emitido',
                    selected: _statusFilter == 'issued',
                    onSelected: () => setState(() => _statusFilter = 'issued'),
                    color: const Color(0xFF69F0AE),
                  ),
                  const SizedBox(width: 6),
                  _FilterChip(
                    label: 'Revocado',
                    selected: _statusFilter == 'revoked',
                    onSelected: () => setState(() => _statusFilter = 'revoked'),
                    color: const Color(0xFFFF5252),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificateList(
    List<Certificate> certificates,
    CertificateNotifier notifier,
    AsyncValue<List<User>> studentsAsync,
  ) {
    final filtered = certificates.where((c) {
      final matchSearch = _searchQuery.isEmpty ||
          c.title.toLowerCase().contains(_searchQuery) ||
          (c.studentEmail?.toLowerCase().contains(_searchQuery) ?? false) ||
          (c.certificateCode?.toLowerCase().contains(_searchQuery) ?? false);
      final matchStatus = _statusFilter == 'TODOS' || c.status == _statusFilter;
      return matchSearch && matchStatus;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: EmptyState(
          title: _searchQuery.isNotEmpty || _statusFilter != 'TODOS'
              ? 'No se encontraron certificados'
              : 'No hay certificados',
          subtitle: _searchQuery.isNotEmpty || _statusFilter != 'TODOS'
              ? 'Intenta ajustar los filtros o la búsqueda'
              : 'Crea tu primer certificado para comenzar',
          icon: Icons.verified_rounded,
          buttonText: _searchQuery.isEmpty && _statusFilter == 'TODOS' ? 'Crear Certificado' : 'Limpiar Filtros',
          onButtonPressed: _searchQuery.isEmpty && _statusFilter == 'TODOS'
              ? () => showCertificateDialog(ref, context, studentsAsync)
              : () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                    _statusFilter = 'TODOS';
                  });
                },
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final certificate = filtered[index];
        return CertificateCard(
          certificate: certificate,
          onIssue: certificate.status == 'pending'
              ? () => showIssueDialog(ref, context, certificate)
              : null,
          onRevoke: certificate.status == 'issued'
              ? () => showRevokeDialog(ref, context, certificate)
              : null,
          onEdit: () => showCertificateDialog(
            ref,
            context,
            studentsAsync,
            certificate: certificate,
          ),
          onDelete: () => showDeleteDialog(ref, context, certificate),
          onTap: () => showDetailDialog(context, certificate),
        );
      },
    );
  }

  Widget _buildErrorView(Object error, CertificateNotifier notifier) {
    return Center(
      child: GlassContainer(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        blur: 24,
        opacity: 0.1,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 56, color: Color(0xFFFF5252)),
            const SizedBox(height: 20),
            const Text(
              'Error de conexión',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              error.toString(),
              style: const TextStyle(color: Colors.white54, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'Reintentar',
                onPressed: () => notifier.refresh(),
                icon: Icons.refresh_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── WIDGETS PEQUEÑOS ──────────────────────────────────────────────────

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size, required this.opacity});
  final Color color;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: opacity + 0.05),
            blurRadius: 100,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(fontSize: 12), // ✅ Tamaño más pequeño
      ),
      selected: selected,
      onSelected: (_) {
        HapticFeedback.lightImpact();
        onSelected();
      },
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      selectedColor: chipColor.withValues(alpha: 0.2),
      checkmarkColor: chipColor,
      labelStyle: TextStyle(
        color: selected ? chipColor : Colors.white60,
        fontWeight: selected ? FontWeight.bold : FontWeight.w500,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // ✅ Padding reducido
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected ? chipColor.withValues(alpha: 0.5) : Colors.white10,
        ),
      ),
    );
  }
}

// ─── CARD WIDGET ────────────────────────────────────────────────────────

class CertificateCard extends StatelessWidget {
  const CertificateCard({
    super.key,
    required this.certificate,
    required this.onIssue,
    required this.onRevoke,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  final Certificate certificate;
  final VoidCallback? onIssue;
  final VoidCallback? onRevoke;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  Color get statusColor {
    switch (certificate.status) {
      case 'issued':
        return const Color(0xFF69F0AE);
      case 'pending':
        return const Color(0xFFFFA726);
      case 'revoked':
        return const Color(0xFFFF5252);
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (certificate.status) {
      case 'issued':
        return Icons.check_circle_rounded;
      case 'pending':
        return Icons.pending_rounded;
      case 'revoked':
        return Icons.cancel_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  String get statusText {
    switch (certificate.status) {
      case 'issued':
        return 'Emitido';
      case 'pending':
        return 'Pendiente';
      case 'revoked':
        return 'Revocado';
      default:
        return certificate.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        blur: 20,
        opacity: 0.06,
        borderRadius: BorderRadius.circular(20),
        padding: EdgeInsets.zero,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _StatusIcon(statusColor: statusColor, icon: statusIcon),
              const SizedBox(width: 12),
              Expanded(child: _CardContent(certificate: certificate, statusColor: statusColor, statusText: statusText)),
              _CardActions(
                onIssue: onIssue,
                onRevoke: onRevoke,
                onEdit: onEdit,
                onDelete: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.statusColor, required this.icon});
  final Color statusColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38, // ✅ Reducido
      height: 38, // ✅ Reducido
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withValues(alpha: 0.2), statusColor.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Icon(icon, color: statusColor, size: 18), // ✅ Reducido
    );
  }
}

class _CardContent extends StatelessWidget {
  const _CardContent({required this.certificate, required this.statusColor, required this.statusText});
  final Certificate certificate;
  final Color statusColor;
  final String statusText;

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          certificate.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), // ✅ Reducido
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          'Estudiante: ${certificate.studentEmail ?? 'N/A'}',
          style: const TextStyle(color: Colors.white38, fontSize: 10), // ✅ Reducido
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        // ✅ Wrap con elementos más compactos
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            _Tag(text: statusText, color: statusColor),
            _Tag(text: certificate.levelDisplay ?? certificate.level, color: const Color(0xFF7C4DFF)),
            _Tag(text: certificate.certificateCode?.substring(0, 8) ?? 'N/A', color: const Color(0xFF00E5FF)),
            if (certificate.issuedAt != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                child: Text(
                  _formatDate(certificate.issuedAt!),
                  style: const TextStyle(color: Colors.white38, fontSize: 7),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), // ✅ Reducido
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 7, // ✅ Reducido
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _CardActions extends StatelessWidget {
  const _CardActions({
    required this.onIssue,
    required this.onRevoke,
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback? onIssue;
  final VoidCallback? onRevoke;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onIssue != null)
          _ActionButton(
            icon: Icons.check_circle_outline_rounded,
            color: const Color(0xFF69F0AE),
            onPressed: onIssue,
            tooltip: 'Emitir',
          ),
        if (onRevoke != null)
          _ActionButton(
            icon: Icons.cancel_outlined,
            color: const Color(0xFFFF5252),
            onPressed: onRevoke,
            tooltip: 'Revocar',
          ),
        _ActionButton(
          icon: Icons.edit_outlined,
          color: const Color(0xFF7C4DFF),
          onPressed: onEdit,
          tooltip: 'Editar',
        ),
        _ActionButton(
          icon: Icons.delete_outline_rounded,
          color: const Color(0xFFFF5252),
          onPressed: onDelete,
          tooltip: 'Eliminar',
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: color, size: 18), // ✅ Reducido
      onPressed: onPressed,
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 24, minHeight: 24), // ✅ Reducido
    );
  }
}