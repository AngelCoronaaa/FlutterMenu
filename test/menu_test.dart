import 'package:flutter/material.dart';
import 'package:flutter_menu/app/mensajeria_controller.dart';
import 'package:flutter_menu/main.dart';
import 'package:flutter_menu/screens/chat_screen.dart';
import 'package:flutter_menu/screens/chats_screen.dart';
import 'package:flutter_menu/screens/llamadas_screen.dart';
import 'package:flutter_menu/screens/personas_screen.dart';
import 'package:flutter_test/flutter_test.dart';

/// Texto dentro de una pantalla concreta (las pestañas siguen montadas).
Finder _en(Type pantalla, String texto) =>
    find.descendant(of: find.byType(pantalla), matching: find.text(texto));

/// Opción del menú inferior.
Finder _tab(String etiqueta) => find.descendant(
  of: find.byType(BottomNavigationBar),
  matching: find.text(etiqueta),
);

/// Avanza una animación de ruta: el primer frame solo la inicia.
Future<void> _avanzar(WidgetTester tester, [int ms = 700]) async {
  await tester.pump();
  await tester.pump(Duration(milliseconds: ms));
}

Future<void> _abrir(WidgetTester tester) async {
  tester.view.physicalSize = const Size(900, 1800);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(FlutterMenuApp(controller: MensajeriaController()));
  await _avanzar(tester);
}

void main() {
  testWidgets('el menú inferior cambia entre Personas, Chats y Llamadas', (
    tester,
  ) async {
    await _abrir(tester);

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(_en(PersonasScreen, 'Ana García'), findsOneWidget);

    await tester.tap(_tab('Chats'));
    await _avanzar(tester);
    expect(_en(ChatsScreen, 'Ana García'), findsOneWidget);
    expect(_en(ChatsScreen, 'Tengo algo que enseñarte 👀'), findsOneWidget);

    await tester.tap(_tab('Llamadas'));
    await _avanzar(tester);
    expect(
      find.descendant(
        of: find.byType(LlamadasScreen),
        matching: find.textContaining('Perdida'),
      ),
      findsWidgets,
    );
  });

  testWidgets('enviar un mensaje recibe una respuesta simulada', (
    tester,
  ) async {
    await _abrir(tester);

    await tester.tap(_tab('Chats'));
    await _avanzar(tester);
    await tester.tap(_en(ChatsScreen, 'Beatriz Soto'));
    await _avanzar(tester);

    await tester.enterText(find.byType(TextField).last, 'Hola desde el test');
    await tester.tap(find.byTooltip('Enviar'));
    await tester.pump();
    expect(find.text('Hola desde el test'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1500));
    expect(_en(ChatScreen, 'escribiendo…'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    expect(_en(ChatScreen, 'escribiendo…'), findsNothing);
  });

  testWidgets('una llamada se contesta y queda en el historial', (
    tester,
  ) async {
    await _abrir(tester);

    await tester.tap(_en(PersonasScreen, 'Ana García'));
    await _avanzar(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byTooltip('Llamar'),
      ),
    );
    await _avanzar(tester);
    expect(find.text('Llamando…'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('00:03'), findsOneWidget);

    await tester.tap(find.byTooltip('Colgar'));
    await tester.pump(const Duration(seconds: 2));
    await _avanzar(tester);
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // La llamada quedó registrada como la más reciente del historial.
    await tester.tap(_tab('Llamadas'));
    await _avanzar(tester);
    expect(_en(LlamadasScreen, 'Ana García'), findsNWidgets(2));
  });
}
