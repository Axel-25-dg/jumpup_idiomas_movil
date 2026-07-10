import 'package:flutter/material.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/domain/model/virtual_class_models.dart';
import 'package:jumpup_app/presentation/providers/virtual_class_providers.dart';

class CertificatesScreen extends ConsumerWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final certsAsync = ref.watch(certificatesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text('Mis Certificados', style: AppTextStyles.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: certsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (_, __) => Center(child: Text('Error al cargar certificados', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error))),
        data: (certs) {
          if (certs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.workspace_premium_outlined, color: AppColors.textHint, size: 80),
                  const SizedBox(height: 16),
                  Text('Aun no tienes certificados', style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Completa un curso para obtener tu primer certificado.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => context.go(AppRoutes.studentCourses),
                    child: const Text('Ir a Cursos'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: certs.length,
            itemBuilder: (_, i) => _CertificateCard(certificate: certs[i]),
          );
        },
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  const _CertificateCard({required this.certificate});
  final CertificateModel certificate;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary.withValues(alpha: 0.12), AppColors.primary.withValues(alpha: 0.04)],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Icon(Icons.workspace_premium, color: AppColors.primary, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CERTIFICADO DE FINALIZACION',
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, letterSpacing: 1, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(certificate.courseName,
                          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(label: 'Fecha de emision:', value: _formatDate(certificate.issueDate)),
                const SizedBox(height: 8),
                _InfoRow(label: 'Codigo de validacion:', value: certificate.code),
                if (certificate.score != null) ...[
                  const SizedBox(height: 8),
                  _InfoRow(label: 'Calificacion final:', value: '${certificate.score}%', valueColor: AppColors.success),
                ],
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomPaint(
                      size: const Size(90, 90),
                      painter: _QrCodePainter(),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text('Escanear para verificar', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Enlace copiado')));
                        },
                        icon: const Icon(Icons.link, size: 18),
                        label: const Text('Compartir'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Descargando certificado...')));
                        },
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text('Descargar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
        Text(value, style: AppTextStyles.bodySmall.copyWith(
          color: valueColor ?? AppColors.textPrimary, fontWeight: FontWeight.w600,
        )),
      ],
    );
  }
}

class _QrCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(8)), paint);
    paint.color = Colors.black;
    final double cellSize = size.width / 15;
    void drawFinderPattern(double x, double y) {
      canvas.drawRect(Rect.fromLTWH(x, y, cellSize * 7, cellSize * 7), paint);
      paint.color = Colors.white;
      canvas.drawRect(Rect.fromLTWH(x + cellSize, y + cellSize, cellSize * 5, cellSize * 5), paint);
      paint.color = Colors.black;
      canvas.drawRect(Rect.fromLTWH(x + cellSize * 2, y + cellSize * 2, cellSize * 3, cellSize * 3), paint);
    }
    drawFinderPattern(0, 0);
    drawFinderPattern(size.width - cellSize * 7, 0);
    drawFinderPattern(0, size.height - cellSize * 7);
    final random = [[8,0],[9,0],[11,0],[12,0],[13,0],[8,1],[10,1],[14,1],[8,2],[9,2],[10,2],[11,2],[13,2],[8,3],[12,3],[14,3],[8,4],[9,4],[11,4],[13,4],[8,5],[10,5],[12,5],[14,5],[8,6],[9,6],[11,6],[13,6],[14,6],[0,8],[1,8],[2,8],[3,8],[4,8],[5,8],[6,8],[7,8],[8,8],[9,8],[10,8],[11,8],[12,8],[13,8],[14,8],[0,9],[2,9],[3,9],[5,9],[6,9],[8,9],[10,9],[12,9],[14,9],[0,10],[1,10],[4,10],[7,10],[9,10],[11,10],[13,10],[0,11],[3,11],[5,11],[8,11],[10,11],[12,11],[14,11],[0,12],[2,12],[4,12],[6,12],[9,12],[11,12],[13,12],[0,13],[1,13],[3,13],[5,13],[7,13],[8,13],[10,13],[12,13],[14,13],[0,14],[2,14],[4,14],[6,14],[9,14],[11,14],[13,14]];
    for (final dot in random) {
      canvas.drawRect(Rect.fromLTWH(dot[0] * cellSize, dot[1] * cellSize, cellSize, cellSize), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
