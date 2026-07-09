import 'package:flutter/material.dart';

class LearningPathScreen extends StatelessWidget {
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nodes = [
      _PathNode(
          id: 1,
          title: 'Conceptos Básicos',
          status: NodeStatus.completed,
          icon: Icons.star),
      _PathNode(
          id: 2,
          title: 'Saludos',
          status: NodeStatus.completed,
          icon: Icons.waving_hand),
      _PathNode(
          id: 3,
          title: 'Presentaciones',
          status: NodeStatus.unlocked,
          icon: Icons.person),
      _PathNode(
          id: 4,
          title: 'Comida',
          status: NodeStatus.locked,
          icon: Icons.restaurant),
      _PathNode(
          id: 5,
          title: 'Viajes',
          status: NodeStatus.locked,
          icon: Icons.flight),
      _PathNode(
          id: 6, title: 'Trabajo', status: NodeStatus.locked, icon: Icons.work),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1828),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network('https://flagcdn.com/w40/gb.png',
                width: 28, height: 20),
            const SizedBox(width: 12),
            const Text('Inglés',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 40),
        itemCount: nodes.length,
        itemBuilder: (context, index) {
          final node = nodes[index];
          final isEven = index % 2 == 0;
          final offset = isEven ? -40.0 : 40.0;
          final isLast = index == nodes.length - 1;

          return Column(
            children: [
              Transform.translate(
                offset: Offset(offset, 0),
                child: _NodeWidget(node: node),
              ),
              if (!isLast)
                _PathLine(
                  isEven: isEven,
                  isCompleted: nodes[index + 1].status != NodeStatus.locked,
                ),
            ],
          );
        },
      ),
    );
  }
}

enum NodeStatus { locked, unlocked, completed }

class _PathNode {
  _PathNode(
      {required this.id,
      required this.title,
      required this.status,
      required this.icon});
  final int id;
  final String title;
  final NodeStatus status;
  final IconData icon;
}

class _NodeWidget extends StatelessWidget {
  const _NodeWidget({required this.node});
  final _PathNode node;

  @override
  Widget build(BuildContext context) {
    Color getBgColor() {
      switch (node.status) {
        case NodeStatus.completed:
          return const Color(0xFFFFD700);
        case NodeStatus.unlocked:
          return const Color(0xFF7C4DFF);
        case NodeStatus.locked:
          return const Color(0xFF1A1828);
      }
    }

    Color getShadowColor() {
      switch (node.status) {
        case NodeStatus.completed:
          return const Color(0xFFB8860B);
        case NodeStatus.unlocked:
          return const Color(0xFF512DA8);
        case NodeStatus.locked:
          return Colors.white12;
      }
    }

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (node.status != NodeStatus.locked) {}
          },
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: getBgColor(),
              shape: BoxShape.circle,
              border: node.status == NodeStatus.locked
                  ? Border.all(color: Colors.white24, width: 3)
                  : Border.all(
                      color: Colors.white.withValues(alpha: 0.5), width: 3),
              boxShadow: [
                BoxShadow(color: getShadowColor(), offset: const Offset(0, 6)),
              ],
            ),
            child: Center(
              child: Icon(
                node.status == NodeStatus.locked ? Icons.lock : node.icon,
                color: node.status == NodeStatus.locked
                    ? Colors.white38
                    : Colors.white,
                size: 36,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          node.title,
          style: TextStyle(
            color: node.status == NodeStatus.locked
                ? Colors.white38
                : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _PathLine extends StatelessWidget {
  const _PathLine({required this.isEven, required this.isCompleted});
  final bool isEven;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 40,
      margin: EdgeInsets.only(
        left: isEven ? 40 : 0,
        right: isEven ? 0 : 40,
      ),
      child: CustomPaint(
        painter: _LinePainter(
          isEven: isEven,
          color: isCompleted ? const Color(0xFFFFD700) : Colors.white24,
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({required this.isEven, required this.color});
  final bool isEven;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (isEven) {
      path.moveTo(size.width * 0.2, 0);
      path.quadraticBezierTo(
          size.width * 0.8, size.height * 0.5, size.width * 0.2, size.height);
    } else {
      path.moveTo(size.width * 0.8, 0);
      path.quadraticBezierTo(
          size.width * 0.2, size.height * 0.5, size.width * 0.8, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
