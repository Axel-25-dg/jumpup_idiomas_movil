import 'package:flutter/material.dart';

class MediaPlayerScreen extends StatelessWidget {
  const MediaPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Multimedia'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Featured media
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primaryContainer,
                        theme.colorScheme.secondaryContainer,
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16)),
                  ),
                  child: Center(
                    child: Icon(Icons.play_circle_fill,
                        size: 72,
                        color: theme.colorScheme.primary),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reproductor Multimedia',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Accede a tus lecciones en video y audio',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: 0.35,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('15:30',
                              style: theme.textTheme.bodySmall),
                          Text('42:10',
                              style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Controles',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ControlButton(
                  icon: Icons.skip_previous_rounded, label: 'Anterior'),
              _ControlButton(
                  icon: Icons.play_circle_fill_rounded,
                  label: 'Reproducir',
                  isPrimary: true),
              _ControlButton(
                  icon: Icons.skip_next_rounded, label: 'Siguiente'),
            ],
          ),
          const SizedBox(height: 24),
          Text('Opciones',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('Subtítulos'),
                onSelected: (_) {},
                selected: true,
              ),
              FilterChip(
                label: const Text('1.0x'),
                onSelected: (_) {},
                selected: false,
              ),
              FilterChip(
                label: const Text('Loop'),
                onSelected: (_) {},
                selected: false,
              ),
              FilterChip(
                label: const Text('Calidad HD'),
                onSelected: (_) {},
                selected: true,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Lista de Reproducción',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const _MediaItem(
            title: 'Introducción al curso',
            duration: '10:20',
            isActive: true,
          ),
          const _MediaItem(
            title: 'Vocabulario básico',
            duration: '15:45',
            isActive: false,
          ),
          const _MediaItem(
            title: 'Gramática esencial',
            duration: '12:30',
            isActive: false,
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    this.isPrimary = false,
  });

  final IconData icon;
  final String label;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isPrimary
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isPrimary
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            size: isPrimary ? 36 : 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}

class _MediaItem extends StatelessWidget {
  const _MediaItem({
    required this.title,
    required this.duration,
    required this.isActive,
  });

  final String title;
  final String duration;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      color: isActive
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
          : null,
      child: ListTile(
        leading: Icon(
          isActive ? Icons.play_circle_filled : Icons.play_circle_outline,
          color: isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
        ),
        title: Text(title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            )),
        trailing: Text(duration, style: theme.textTheme.bodySmall),
        onTap: () {},
      ),
    );
  }
}
