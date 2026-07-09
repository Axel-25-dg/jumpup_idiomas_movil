import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/neon_button.dart';
import 'ai_tutor_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grisClaro,
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '¡Hola de nuevo!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textoOscuro),
            ),
            const SizedBox(height: 20),
            
            // Stats Row using Glassmorphism
            Row(
              children: [
                Expanded(
                  child: GlassContainer(
                    child: Column(
                      children: const [
                        Icon(Icons.star, color: Colors.orange, size: 30),
                        SizedBox(height: 8),
                        Text('XP', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textoOscuro)),
                        Text('1250', style: TextStyle(fontSize: 20, color: AppTheme.celeste)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: GlassContainer(
                    child: Column(
                      children: const [
                        Icon(Icons.local_fire_department, color: Colors.redAccent, size: 30),
                        SizedBox(height: 8),
                        Text('Racha', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textoOscuro)),
                        Text('7 Días', style: TextStyle(fontSize: 20, color: AppTheme.celeste)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Current Course Card
            GlassContainer(
              blur: 15,
              opacity: 0.5,
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.celeste.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.language, color: AppTheme.celeste, size: 35),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Inglés Avanzado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textoOscuro)),
                        SizedBox(height: 5),
                        Text('Unidad 4: Tiempos verbales', style: TextStyle(color: AppTheme.textoClaro)),
                      ],
                    ),
                  ),
                  const Icon(Icons.play_circle_fill, color: AppTheme.celeste, size: 40),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // AI Tutor Quick Access
            NeonButton(
              text: 'Hablar con Tutor IA',
              onPressed: () {
                // Thread ID should ideally come from backend/auth state
                final threadId = 'default_thread_123';
                Navigator.push(context, MaterialPageRoute(builder: (_) => AITutorScreen(threadId: threadId)));
              },
            ),
          ],
        ),
      ),
    );
  }
}
