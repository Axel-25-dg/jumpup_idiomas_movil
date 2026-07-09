import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/virtual_class_models.dart';
import 'package:jumpup_app/presentation/providers/virtual_class_providers.dart';

class CertificatesScreen extends ConsumerWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final certsAsync = ref.watch(certificatesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1828),
        title: const Text('Mis Certificados 🎓',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: certsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
        error: (_, __) => const Center(
            child: Text('Error al cargar certificados',
                style: TextStyle(color: Colors.redAccent))),
        data: (certs) {
          if (certs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.workspace_premium_outlined,
                      color: Colors.white24, size: 80),
                  const SizedBox(height: 16),
                  const Text('Aún no tienes certificados',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                      'Completa un curso para obtener tu primer certificado.',
                      style: TextStyle(color: Colors.white54, fontSize: 14)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Navegar a los cursos
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C4DFF),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Ir a Cursos',
                        style: TextStyle(color: Colors.white)),
                  )
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
        color: const Color(0xFF1A1828),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Cabecera ──────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFD700).withValues(alpha: 0.2),
                  const Color(0xFFFFD700).withValues(alpha: 0.05),
                ],
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.workspace_premium,
                    color: Color(0xFFFFD700), size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CERTIFICADO DE FINALIZACIÓN',
                        style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        certificate.courseName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Cuerpo ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Fecha de emisión:',
                        style: TextStyle(color: Colors.white54, fontSize: 13)),
                    Text(_formatDate(certificate.issueDate),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Código de validación:',
                        style: TextStyle(color: Colors.white54, fontSize: 13)),
                    Text(certificate.code,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontFamily: 'monospace')),
                  ],
                ),
                if (certificate.score != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Calificación final:',
                          style:
                              TextStyle(color: Colors.white54, fontSize: 13)),
                      Text('${certificate.score}%',
                          style: const TextStyle(
                              color: Color(0xFF4CAF50),
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomPaint(
                      size: const Size(90, 90),
                      painter: _QrCodePainter(),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Center(
                  child: Text(
                    'Escanear para verificar autenticidad',
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Botones ─────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Copiar enlace
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Enlace copiado al portapapeles')));
                        },
                        icon: const Icon(Icons.link, color: Colors.white),
                        label: const Text('Compartir',
                            style: TextStyle(color: Colors.white)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Descargar PDF
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Descargando certificado PDF...')));
                        },
                        icon: const Icon(Icons.download, color: Colors.black),
                        label: const Text('Descargar',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
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

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}

class _QrCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Background white
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height),
            const Radius.circular(8)),
        paint);

    paint.color = Colors.black;
    final double cellSize = size.width / 15;

    void drawFinderPattern(double x, double y) {
      canvas.drawRect(Rect.fromLTWH(x, y, cellSize * 7, cellSize * 7), paint);
      paint.color = Colors.white;
      canvas.drawRect(
          Rect.fromLTWH(x + cellSize, y + cellSize, cellSize * 5, cellSize * 5),
          paint);
      paint.color = Colors.black;
      canvas.drawRect(
          Rect.fromLTWH(
              x + cellSize * 2, y + cellSize * 2, cellSize * 3, cellSize * 3),
          paint);
    }

    drawFinderPattern(0, 0);
    drawFinderPattern(size.width - cellSize * 7, 0);
    drawFinderPattern(0, size.height - cellSize * 7);

    final random = [
      [8, 0],
      [9, 0],
      [11, 0],
      [12, 0],
      [13, 0],
      [8, 1],
      [10, 1],
      [14, 1],
      [8, 2],
      [9, 2],
      [10, 2],
      [11, 2],
      [13, 2],
      [8, 3],
      [12, 3],
      [14, 3],
      [8, 4],
      [9, 4],
      [11, 4],
      [13, 4],
      [8, 5],
      [10, 5],
      [12, 5],
      [14, 5],
      [8, 6],
      [9, 6],
      [11, 6],
      [13, 6],
      [14, 6],
      [0, 8],
      [1, 8],
      [2, 8],
      [3, 8],
      [4, 8],
      [5, 8],
      [6, 8],
      [7, 8],
      [8, 8],
      [9, 8],
      [10, 8],
      [11, 8],
      [12, 8],
      [13, 8],
      [14, 8],
      [0, 9],
      [2, 9],
      [3, 9],
      [5, 9],
      [6, 9],
      [8, 9],
      [10, 9],
      [12, 9],
      [14, 9],
      [0, 10],
      [1, 10],
      [4, 10],
      [7, 10],
      [9, 10],
      [11, 10],
      [13, 10],
      [0, 11],
      [3, 11],
      [5, 11],
      [8, 11],
      [10, 11],
      [12, 11],
      [14, 11],
      [0, 12],
      [2, 12],
      [4, 12],
      [6, 12],
      [9, 12],
      [11, 12],
      [13, 12],
      [0, 13],
      [1, 13],
      [3, 13],
      [5, 13],
      [7, 13],
      [8, 13],
      [10, 13],
      [12, 13],
      [14, 13],
      [0, 14],
      [2, 14],
      [4, 14],
      [6, 14],
      [9, 14],
      [11, 14],
      [13, 14]
    ];

    for (final dot in random) {
      canvas.drawRect(
          Rect.fromLTWH(
              dot[0] * cellSize, dot[1] * cellSize, cellSize, cellSize),
          paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
