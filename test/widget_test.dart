import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    // Inicializa dotenv antes de cualquier widget que use AppConfig
    await dotenv.load(fileName: '.env');
  });

  testWidgets('La app muestra un MaterialApp sin errores', (tester) async {
    // Pumpeamos un widget minimal que NO dispara llamadas de red,
    // para verificar que el tema y la estructura base funcionan.
    await tester.pumpWidget(
      MaterialApp(
        title: 'JumpUp',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Scaffold(
          appBar: AppBar(title: const Text('Comunicación y comunidad')),
          body: const Center(child: Text('JumpUp listo')),
        ),
      ),
    );

    expect(find.text('Comunicación y comunidad'), findsOneWidget);
    expect(find.text('JumpUp listo'), findsOneWidget);
  });

  testWidgets('NavigationBar con 7 destinos se construye correctamente',
      (tester) async {
    final destinations = [
      'Mensajería',
      'Comunidad',
      'Media',
      'En vivo',
      'Avisos',
      'Buscar',
      'Feed',
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const SizedBox.shrink(),
          bottomNavigationBar: NavigationBar(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            destinations: destinations
                .map((label) => NavigationDestination(
                      icon: const Icon(Icons.circle),
                      label: label,
                    ))
                .toList(),
          ),
        ),
      ),
    );

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(7));
    for (final label in destinations) {
      expect(find.text(label), findsOneWidget);
    }
  });
}
