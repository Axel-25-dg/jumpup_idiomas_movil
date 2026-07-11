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

  static const Color background = Color(0xFF0F111A);
  static const Color surface = Color(0xFF1E1E2E);
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
      backgroundColor: _ClassTokens.background,
      body: Stack(
        children: [
          // Efectos visuales de fondo
          const Positioned(
            top: -100,
            right: -50,
            child: _BlurBlob(color: Colors.blueAccent, opacity: 0.1, size: 300),
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
            backgroundColor: _ClassTokens.surface,
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
                              child: _VirtualClassCard(vClass: vClass),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showJoinDialog(context),
        backgroundColor: _ClassTokens.primary,
        elevation: 4,
        icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
        label: Text(
          'Unirse con código',
          style: AppTextStyles.labelLarge
              .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _ClassesSliverAppBar extends StatelessWidget {
  const _ClassesSliverAppBar({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      elevation: 0,
      stretch: true,
      backgroundColor: _ClassTokens.background.withValues(alpha: 0.8),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsetsDirectional.only(start: 20, bottom: 16),
        title: Text(
          'Clases Virtuales',
          style: AppTextStyles.titleLarge.copyWith(
            color: Colors.white,
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
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            onPressed: onAdd,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: const Icon(Icons.add_rounded,
                  color: Colors.white, size: 20),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                shape: BoxShape.circle,
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Icon(
                Icons.school_rounded,
                size: 64,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No hay clases activas',
              style: AppTextStyles.titleLarge
                  .copyWith(color: Colors.white, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              'Aquí verás tus clases programadas. Únete a una nueva clase para empezar.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: Colors.white.withValues(alpha: 0.4)),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: onJoin,
              style: ElevatedButton.styleFrom(
                backgroundColor: _ClassTokens.primary.withValues(alpha: 0.1),
                foregroundColor: _ClassTokens.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: _ClassTokens.primary, width: 1),
                ),
              ),
              child: const Text(
                'Unirse a una clase',
                style: TextStyle(fontWeight: FontWeight.bold),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 64, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(
            '¡Ups! Algo salió mal',
            style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            child: const Text('Reintentar',
                style: TextStyle(color: _ClassTokens.primary)),
          ),
        ],
      ),
    );
  }
}

class _VirtualClassCard extends ConsumerWidget {
  const _VirtualClassCard({required this.vClass});
  final VirtualClassModel vClass;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final joinStatus = ref.watch(joinClassNotifierProvider);
    final isFull = vClass.isFull;
    final isOngoing = vClass.isOngoing;
    final canJoin = vClass.canJoin;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _ClassTokens.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: (isFull && !canJoin) ? null : () => _handleJoin(context, ref),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge de estado y contador de participantes
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatusBadge(
                      isOngoing: isOngoing,
                      isScheduled: vClass.isScheduled,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.people_outline_rounded,
                            color: isFull
                                ? Colors.redAccent
                                : Colors.white.withValues(alpha: 0.5),
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${vClass.currentParticipants}/${vClass.maxParticipants}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isFull
                                  ? Colors.redAccent
                                  : Colors.white.withValues(alpha: 0.5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Detalles de la clase
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vClass.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      vClass.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.5),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
              // Instructor y botón de acción
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor:
                          _ClassTokens.primary.withValues(alpha: 0.1),
                      child: const Icon(Icons.person_rounded,
                          size: 18, color: _ClassTokens.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        vClass.instructorName,
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
              ),
            ],
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
            const SnackBar(content: Text('No se pudo abrir el enlace de la clase')),
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
        final error = ref.read(joinClassNotifierProvider.notifier).errorMessage;
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
  const _StatusBadge({required this.isOngoing, required this.isScheduled});

  final bool isOngoing;
  final bool isScheduled;

  @override
  Widget build(BuildContext context) {
    final color = isOngoing
        ? Colors.greenAccent
        : (isScheduled
            ? _ClassTokens.primary
            : Colors.white.withValues(alpha: 0.3));
    final text = isOngoing
        ? 'EN VIVO'
        : (isScheduled ? 'PROGRAMADA' : 'FINALIZADA');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isOngoing)
            const Padding(
              padding: EdgeInsets.only(right: 6),
              child: ZoomIn(
                duration: Duration(seconds: 1),
                child: SizedBox(
                  width: 8,
                  height: 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
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
            strokeWidth: 2, color: _ClassTokens.primary),
      );
    }

    if (isFull && !canJoin) {
      return Text(
        'Llena',
        style: AppTextStyles.labelLarge.copyWith(
          color: Colors.white.withValues(alpha: 0.3),
          fontWeight: FontWeight.bold,
        ),
      );
    }

    final color = canJoin ? Colors.greenAccent : _ClassTokens.primary;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: color.withValues(alpha: 0.1),
      ),
      child: Text(
        canJoin ? 'ENTRAR' : 'RESERVAR',
        style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w800),
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
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) return;
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final code = _codeCtrl.text.trim();

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
  }

  @override
  Widget build(BuildContext context) {
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
            color: _ClassTokens.surface.withValues(alpha: 0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Unirse a un Aula',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Ingresa el código de 6 caracteres o escanea el código QR de tu profesor.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 40),
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
                        return 'Código inválido (6 caracteres)';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: '000000',
                      hintStyle: AppTextStyles.headlineMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.05),
                        letterSpacing: 12,
                      ),
                      counterText: '',
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                            color: _ClassTokens.primary, width: 2),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 24),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _scanQR,
                          icon: const Icon(Icons.qr_code_scanner_rounded,
                              size: 20),
                          label: const Text('ESCANEAR'),
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 18),
                            foregroundColor: Colors.white,
                            side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.1)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DecoratedBox(
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
                          child: ElevatedButton(
                            onPressed: _enroll,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: const Text('UNIRSE',
                                style:
                                    TextStyle(fontWeight: FontWeight.bold)),
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

/// QR Scanner — temporarily disabled while mobile_scanner migrates to Built-in Kotlin.
/// Shows a friendly "coming soon" message instead of crashing.
class _QRScannerScreen extends StatelessWidget {
  const _QRScannerScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.qr_code_scanner_rounded,
                  size: 80, color: Colors.white24),
              const SizedBox(height: 24),
              const Text(
                'Escáner QR\nPróximamente',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Ingresa el código manualmente por ahora.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
                child: const Text('Volver', style: TextStyle(color: Colors.white)),
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
