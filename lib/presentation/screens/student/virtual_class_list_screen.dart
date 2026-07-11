import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/virtual_class_models.dart';
import 'package:jumpup_app/presentation/providers/virtual_class_providers.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

/// Tokens de diseño centralizados para el módulo de clases virtuales.
class _ClassTokens {
  const _ClassTokens._();

  static Color background(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E1E2E)
          : Colors.white;

  static const Color primary = Colors.blueAccent;

  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
  );

  static const Color brandGlow = Color(0xFF2575FC);
}

class VirtualClassListScreen extends ConsumerWidget {
  const VirtualClassListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _VirtualClassListBody();
  }
}

class _VirtualClassListBody extends ConsumerWidget {
  const _VirtualClassListBody();

  void _showJoinDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _JoinClassSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(virtualClassesProvider);

    return Scaffold(
      backgroundColor: _ClassTokens.background(context),
      body: Stack(
        children: [
          // Efectos visuales de fondo
          const Positioned(
            top: -100,
            right: -50,
            child: _BlurBlob(
              color: Colors.blueAccent,
              opacity: 0.1,
              size: 300,
            ),
          ),
          const Positioned(
            bottom: -50,
            left: -50,
            child: _BlurBlob(
              color: Colors.purpleAccent,
              opacity: 0.05,
              size: 250,
            ),
          ),
          RefreshIndicator(
            onRefresh: () => ref.refresh(virtualClassesProvider.future),
            backgroundColor: _ClassTokens.surface(context),
            color: _ClassTokens.primary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                _ClassesSliverAppBar(
                  onAdd: () => _showJoinDialog(context),
                ),
                classesAsync.when(
                  loading: () => const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: _ClassTokens.primary,
                      ),
                    ),
                  ),
                  error: (err, stack) => SliverFillRemaining(
                    child: _ErrorState(
                      onRetry: () => ref.invalidate(virtualClassesProvider),
                    ),
                  ),
                  data: (classes) {
                    if (classes.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyState(
                          onJoin: () => _showJoinDialog(context),
                        ),
                      );
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final vClass = classes[index];
                            return FadeInUp(
                              duration:
                                  Duration(milliseconds: 400 + (index * 100)),
                              child: _VirtualClassCard(
                                vClass: vClass,
                                onJoinPressed: () => _showJoinDialog(context),
                              ),
                            );
                          },
                          childCount: classes.length,
                        ),
                      ),
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

class _ClassesSliverAppBar extends StatelessWidget {
  const _ClassesSliverAppBar({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : Colors.black87;

    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      elevation: 0,
      stretch: true,
      backgroundColor: _ClassTokens.background(context).withValues(alpha: 0.9),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsetsDirectional.only(start: 20, bottom: 16),
        title: Text(
          'Clases Virtuales',
          style: AppTextStyles.titleLarge.copyWith(
            color: titleColor,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        background: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                Icons.video_camera_front_rounded,
                size: 120,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ],
        ),
      ),
      // Solo botón de añadir en el AppBar - ELIMINADO el FAB redundante
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            onPressed: onAdd,
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: isDark ? null : _ClassTokens.brandGradient,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : null,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.transparent,
                ),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: _ClassTokens.brandGlow.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Icon(
                Icons.add_rounded,
                color: isDark ? Colors.white : Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onJoin});
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor =
        isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black54;
    final circleColor = isDark
        ? Colors.white.withValues(alpha: 0.03)
        : Colors.black.withValues(alpha: 0.03);
    final iconColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black26;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ilustración mejorada
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.08),
                ),
              ),
              child: Icon(
                Icons.video_library_rounded,
                size: 72,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'No hay clases activas',
              style: AppTextStyles.titleLarge.copyWith(
                color: textColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Únete a una clase virtual para comenzar tu aprendizaje',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: subColor),
            ),
            const SizedBox(height: 40),
            // Botón de unirse mejorado
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: _ClassTokens.brandGradient,
                boxShadow: [
                  BoxShadow(
                    color: _ClassTokens.brandGlow.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: onJoin,
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: const Text(
                  'Unirse a una clase',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.redAccent.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '¡Ups! Algo salió mal',
              style: AppTextStyles.titleMedium.copyWith(color: textColor),
            ),
            const SizedBox(height: 12),
            Text(
              'No pudimos cargar tus clases',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _ClassTokens.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VirtualClassCard extends ConsumerWidget {
  const _VirtualClassCard({
    required this.vClass,
    this.onJoinPressed,
  });

  final VirtualClassModel vClass;
  final VoidCallback? onJoinPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final joinStatus = ref.watch(joinClassNotifierProvider);
    final isFull = vClass.isFull;
    final isOngoing = vClass.isOngoing;
    final canJoin = vClass.canJoin;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _ClassTokens.surface(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _handleJoin(context, ref),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con badge y participantes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatusBadge(
                      isOngoing: isOngoing,
                      isScheduled: vClass.isScheduled,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.3)
                            : Colors.black.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people_outline_rounded,
                            color: isFull
                                ? Colors.redAccent
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.5)
                                    : Colors.black45),
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${vClass.currentParticipants}/${vClass.maxParticipants}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isFull
                                  ? Colors.redAccent
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.5)
                                      : Colors.black45),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Título y descripción
                Text(
                  vClass.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  vClass.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : Colors.black54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Divider(
                  height: 1,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.08),
                ),
                const SizedBox(height: 16),
                // Instructor y acción
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          _ClassTokens.primary.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 20,
                        color: _ClassTokens.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        vClass.instructorName,
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    _ActionButton(
                      canJoin: canJoin,
                      isFull: isFull,
                      isLoading: joinStatus == JoinClassStatus.loading,
                      onPressed: () => _handleJoin(context, ref),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleJoin(BuildContext context, WidgetRef ref) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (vClass.canJoin) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Redirigiendo a la sala...'),
          backgroundColor: _ClassTokens.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      final result =
          await ref.read(joinClassNotifierProvider.notifier).joinClass(vClass.id);
      if (result != null && result.virtualClass.meetingUrl != null) {
        final uri = Uri.tryParse(result.virtualClass.meetingUrl!);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('No se pudo abrir el enlace de la clase'),
            ),
          );
        }
      }
    } else {
      final result =
          await ref.read(joinClassNotifierProvider.notifier).joinClass(vClass.id);
      if (result != null) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Inscripción exitosa. Te notificaremos.'),
            backgroundColor: Colors.greenAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        final error =
            ref.read(joinClassNotifierProvider.notifier).errorMessage;
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(error ?? 'No se pudo reservar la clase'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.isOngoing,
    required this.isScheduled,
  });

  final bool isOngoing;
  final bool isScheduled;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isOngoing
        ? Colors.greenAccent
        : (isScheduled
            ? _ClassTokens.primary
            : (isDark ? Colors.white38 : Colors.black38));
    final text = isOngoing
        ? 'EN VIVO'
        : (isScheduled ? 'PROGRAMADA' : 'FINALIZADA');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isOngoing) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ZoomIn(
                duration: const Duration(seconds: 1),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
          Text(
            text,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.canJoin,
    required this.isFull,
    required this.isLoading,
    required this.onPressed,
  });

  final bool canJoin;
  final bool isFull;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _ClassTokens.primary,
        ),
      );
    }

    if (isFull && !canJoin) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Completa',
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      );
    }

    final color = canJoin ? Colors.greenAccent.shade700 : _ClassTokens.primary;
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  canJoin ? 'ENTRAR' : 'RESERVAR',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  canJoin
                      ? Icons.arrow_forward_rounded
                      : Icons.bookmark_add_rounded,
                  size: 18,
                  color: color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _JoinClassSheet extends ConsumerStatefulWidget {
  const _JoinClassSheet();

  @override
  ConsumerState<_JoinClassSheet> createState() => _JoinClassSheetState();
}

class _JoinClassSheetState extends ConsumerState<_JoinClassSheet> {
  final _codeCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _scanQR() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const _QRScannerScreen()),
    );

    if (!mounted) return;

    if (result != null && result.isNotEmpty) {
      setState(() {
        _codeCtrl.text = result;
      });
      await _enroll();
    }
  }

  Future<void> _enroll() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isProcessing = true);

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final code = _codeCtrl.text.trim();

    try {
      final notifier = ref.read(classroomEnrollNotifierProvider.notifier);
      final success = await notifier.enrollByCode(code);

      if (!mounted) return;

      if (success) {
        ref.invalidate(virtualClassesProvider);
        navigator.pop();
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('¡Inscrito al aula virtual con éxito!'),
            backgroundColor: Colors.greenAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(notifier.errorMessage ?? 'Inscripción fallida'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            28,
            16,
            28,
            MediaQuery.of(context).viewInsets.bottom + 40,
          ),
          decoration: BoxDecoration(
            color: _ClassTokens.surface(context).withValues(alpha: 0.95),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black)
                  .withValues(alpha: 0.08),
            ),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Título
                  Text(
                    'Unirse a un Aula Virtual',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtítulo
                  Text(
                    'Ingresa el código de 6 caracteres proporcionado por tu profesor',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.5)
                          : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Campo de código
                  TextFormField(
                    controller: _codeCtrl,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    textCapitalization: TextCapitalization.characters,
                    style: AppTextStyles.headlineMedium.copyWith(
                      letterSpacing: 12,
                      fontWeight: FontWeight.w900,
                      color: _ClassTokens.primary,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().length != 6) {
                        return 'El código debe tener 6 caracteres';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'ABC123',
                      hintStyle: AppTextStyles.headlineMedium.copyWith(
                        color: (isDark ? Colors.white : Colors.black)
                            .withValues(alpha: 0.08),
                        letterSpacing: 12,
                      ),
                      counterText: '',
                      filled: true,
                      fillColor: (isDark ? Colors.white : Colors.black)
                          .withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: (isDark ? Colors.white : Colors.black)
                              .withValues(alpha: 0.08),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: _ClassTokens.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 24),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botones de acción
                  Row(
                    children: [
                      // Escanear QR
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isProcessing ? null : _scanQR,
                          icon: const Icon(
                            Icons.qr_code_scanner_rounded,
                            size: 20,
                          ),
                          label: const Text('Escanear'),
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 18),
                            foregroundColor:
                                isDark ? Colors.white : Colors.black87,
                            side: BorderSide(
                              color: (isDark ? Colors.white : Colors.black)
                                  .withValues(alpha: 0.15),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Unirse
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: _ClassTokens.brandGradient,
                            boxShadow: [
                              BoxShadow(
                                color: _ClassTokens.brandGlow
                                    .withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _isProcessing ? null : _enroll,
                            icon: _isProcessing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.login_rounded,
                                    color: Colors.white,
                                  ),
                            label: Text(
                              _isProcessing
                                  ? 'Uniendo...'
                                  : 'Unirse ahora',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                vertical: 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// QR Scanner — temporalmente deshabilitado mientras mobile_scanner migra a Kotlin.
class _QRScannerScreen extends StatelessWidget {
  const _QRScannerScreen();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.05),
                ),
                child: Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 80,
                  color: isDark ? Colors.white24 : Colors.black26,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Escáner QR',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Próximamente disponible',
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : Colors.black54,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Por ahora, ingresa el código manualmente',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.black38,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Volver'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _ClassTokens.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlurBlob extends StatelessWidget {
  const _BlurBlob({
    required this.color,
    required this.size,
    this.opacity = 1.0,
  });

  final Color color;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final base = color.withValues(alpha: opacity);
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: base,
          boxShadow: [
            BoxShadow(
              color: base.withValues(alpha: 0.5),
              blurRadius: 100,
              spreadRadius: 50,
            ),
          ],
        ),
      ),
    );
  }
}