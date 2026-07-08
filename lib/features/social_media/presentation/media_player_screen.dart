import 'package:flutter/material.dart';

class MediaPlayerScreen extends StatelessWidget {
  const MediaPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Reproductor multimedia avanzado',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text('Video lección · 1:24:10'),
          const SizedBox(height: 16),
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
                child: Icon(Icons.play_circle_fill,
                    size: 64, color: Colors.deepPurple)),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Chip(label: Text('Subtítulos')),
              SizedBox(width: 8),
              Chip(label: Text('1.0x')),
              SizedBox(width: 8),
              Chip(label: Text('Loop frase')),
            ],
          ),
        ],
      ),
    );
  }
}
