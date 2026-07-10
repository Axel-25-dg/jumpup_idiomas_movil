import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/virtual_class_models.dart';
import 'package:jumpup_app/presentation/providers/virtual_class_providers.dart';
import 'package:jumpup_app/presentation/screens/student/widgets/student_shared_widgets.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class VirtualClassListScreen extends ConsumerWidget {
  const VirtualClassListScreen({super.key});

  void _showJoinDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _JoinClassSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(virtualClassesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(virtualClassesProvider.future),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 120.0,
              floating: false,
              pinned: true,
              elevation: 0,
              stretch: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                titlePadding: const EdgeInsetsDirectional.only(start: 16, bottom: 16),
                title: Text(
                  'Clases Virtuales',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        top: -20,
                        child: Icon(
                          Icons.video_camera_front_rounded,
                          size: 140,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    onPressed: () => _showJoinDialog(context, ref),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.white),
                    ),
                    tooltip: 'Unirse a clase',
                  ),
                ),
              ],
            ),
            classesAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              ),
              error: (err, stack) => SliverFillRemaining(
                child: _ErrorState(onRetry: () => ref.refresh(virtualClassesProvider)),
              ),
              data: (classes) {
                if (classes.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(onJoin: () => _showJoinDialog(context, ref)),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final vClass = classes[index];
                        return FadeInUp(
                          duration: Duration(milliseconds: 400 + (index * 100)),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showJoinDialog(context, ref),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
        label: Text('Unirse con código', 
          style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onJoin;
  const _EmptyState({required this.onJoin});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school_rounded,
                size: 80,
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay clases activas',
              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              'Aquí verás las clases programadas y en vivo. Únete a una clase para comenzar a aprender.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onJoin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Unirse a mi primera clase'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text('¡Ups! Algo salió mal', style: AppTextStyles.titleMedium),
          TextButton(onPressed: onRetry, child: const Text('Reintentar')),
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

    return StudentCard(
      onTap: (isFull && !canJoin) ? null : () => _handleJoin(context, ref),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status and participants
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatusBadge(isOngoing: isOngoing, isScheduled: vClass.isScheduled),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.people_outline_rounded,
                          color: isFull ? AppColors.error : AppColors.textSecondary, 
                          size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${vClass.currentParticipants}/${vClass.maxParticipants}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isFull ? AppColors.error : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Class Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vClass.title,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  vClass.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.divider),
          
          // Footer with Instructor and Action
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(Icons.person_rounded, size: 16, color: AppColors.primary),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vClass.instructorName,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
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
    );
  }

  void _handleJoin(BuildContext context, WidgetRef ref) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    if (vClass.canJoin) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Redirigiendo a la sala...'),
          backgroundColor: AppColors.info,
          behavior: SnackBarBehavior.floating,
        ),
      );
      await ref.read(joinClassNotifierProvider.notifier).joinClass(vClass.id);
    } else {
      await ref.read(joinClassNotifierProvider.notifier).joinClass(vClass.id);
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Inscripción exitosa. Te notificaremos antes de empezar.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isOngoing;
  final bool isScheduled;

  const _StatusBadge({required this.isOngoing, required this.isScheduled});

  @override
  Widget build(BuildContext context) {
    final color = isOngoing ? AppColors.success : (isScheduled ? AppColors.primary : AppColors.textSecondary);
    final text = isOngoing ? 'EN VIVO' : (isScheduled ? 'PROGRAMADA' : 'FINALIZADA');

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
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ZoomIn(
                duration: const Duration(seconds: 1),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
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
  final bool canJoin;
  final bool isFull;
  final bool isLoading;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.canJoin,
    required this.isFull,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
      );
    }

    if (isFull && !canJoin) {
      return Text(
        'Llena',
        style: AppTextStyles.labelLarge.copyWith(color: AppColors.textHint, fontWeight: FontWeight.bold),
      );
    }

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: canJoin ? AppColors.success : AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: (canJoin ? AppColors.success : AppColors.primary).withValues(alpha: 0.1),
      ),
      child: Text(
        canJoin ? 'ENTRAR' : 'RESERVAR',
        style: AppTextStyles.labelLarge.copyWith(
          fontWeight: FontWeight.w800,
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

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  void _scanQR() async {
    Navigator.pop(context);
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const _QRScannerScreen()),
    );
    if (result != null && result.isNotEmpty) {
      _codeCtrl.text = result;
      _enroll();
    }
  }

  Future<void> _enroll() async {
    if (!_formKey.currentState!.validate()) return;
    final code = _codeCtrl.text.trim();
    final success = await ref
        .read(classroomEnrollNotifierProvider.notifier)
        .enrollByCode(code);
    if (mounted) {
      if (success) {
        ref.invalidate(virtualClassesProvider);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Inscrito al aula virtual con éxito!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        final err = ref.read(classroomEnrollNotifierProvider.notifier).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err ?? 'Inscripción fallida'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.divider.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Unirse a un Aula',
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'Ingresa el código de 6 caracteres proporcionado por tu profesor o escanea el código QR.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _codeCtrl,
              maxLength: 6,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              style: AppTextStyles.headlineMedium.copyWith(
                letterSpacing: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
              ),
              validator: (val) {
                if (val == null || val.trim().length != 6) {
                  return 'El código debe tener 6 caracteres';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: '000000',
                hintStyle: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.divider,
                  letterSpacing: 12,
                ),
                counterText: '',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 20),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _scanQR,
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                    label: const Text('ESCANEAR'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.primary, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _enroll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('UNIRSE'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QRScannerScreen extends StatefulWidget {
  const _QRScannerScreen();

  @override
  State<_QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<_QRScannerScreen> {
  MobileScannerController? _controller;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

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
        actions: [
          IconButton(
            icon: Icon(
              _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: Colors.white,
            ),
            onPressed: () async {
              await _controller?.toggleTorch();
              setState(() => _isTorchOn = !_isTorchOn);
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller!,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final code = barcodes.first.rawValue;
                if (code != null) {
                  Navigator.pop(context, code);
                }
              }
            },
          ),
          // Custom Scanner Overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.secondary, width: 4),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Text(
              'Encuadra el código QR del aula',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

