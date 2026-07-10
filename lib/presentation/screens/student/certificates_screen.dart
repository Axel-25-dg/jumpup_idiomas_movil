import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/domain/model/virtual_class_models.dart';
import 'package:jumpup_app/presentation/providers/virtual_class_providers.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class CertificatesScreen extends ConsumerWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final certsAsync = ref.watch(certificatesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mis Certificados',
          style: AppTextStyles.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: certsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
        error: (_, __) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 64),
              const SizedBox(height: 16),
              Text('Error al cargar certificados', style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
              TextButton(onPressed: () => ref.refresh(certificatesProvider), child: const Text('Reintentar')),
            ],
          ),
        ),
        data: (certs) {
          if (certs.isEmpty) {
            return Center(
              child: FadeIn(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.workspace_premium_outlined, color: Colors.blueAccent.withOpacity(0.5), size: 100),
                    ),
                    const SizedBox(height: 24),
                    Text('Aún no tienes certificados', style: AppTextStyles.headlineSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Completa un curso para obtener tu primer certificado oficial y compartirlo con el mundo.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => context.go(AppRoutes.studentCourses),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('EXPLORAR CURSOS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: certs.length,
            itemBuilder: (_, i) => FadeInUp(
              delay: Duration(milliseconds: i * 100),
              child: _CertificateCard(certificate: certs[i]),
            ),
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
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(24),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent.withOpacity(0.2), Colors.purpleAccent.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CERTIFICADO OFICIAL',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.blueAccent,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        certificate.courseName,
                        style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(label: 'Fecha de emisión', value: _formatDate(certificate.issueDate)),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Colors.white10),
                ),
                _InfoRow(label: 'Código de validación', value: certificate.code),
                if (certificate.score != null) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Colors.white10),
                  ),
                  _InfoRow(label: 'Calificación final', value: '${certificate.score}%', valueColor: Colors.greenAccent),
                ],
                const SizedBox(height: 32),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: -5,
                        )
                      ],
                    ),
                    child: CustomPaint(
                      size: const Size(120, 120),
                      painter: _QrCodePainter(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Escanear para verificar autenticidad',
                    style: AppTextStyles.labelSmall.copyWith(color: Colors.white38),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Enlace copiado al portapapeles')),
                          );
                        },
                        icon: const Icon(Icons.share_rounded, size: 18),
                        label: const Text('COMPARTIR'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Generando PDF del certificado...')),
                            );
                          },
                          icon: const Icon(Icons.file_download_rounded, size: 18),
                          label: const Text('DESCARGAR'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
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

  String _formatDate(DateTime date) => '${date.day} de ${_getMonthName(date.month)}, ${date.year}';

  String _getMonthName(int month) {
    const months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    return months[month - 1];
  }
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
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: Colors.white54)),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            color: valueColor ?? Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
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
