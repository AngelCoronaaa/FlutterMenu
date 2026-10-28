import 'package:flutter/material.dart';

import '../app/mensajeria_controller.dart';
import '../widgets/barra_inferior.dart';
import '../widgets/glass.dart';
import 'chats_screen.dart';
import 'llamadas_screen.dart';
import 'personas_screen.dart';

/// Contenedor principal: las tres pestañas y el menú inferior.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _pantallas = [PersonasScreen(), ChatsScreen(), LlamadasScreen()];

  int _indice = 0;

  void _cambiar(int i) {
    if (i == _indice) return;
    setState(() => _indice = i);
    if (i == 2) MensajeriaScope.read(context).marcarLlamadasVistas();
  }

  @override
  Widget build(BuildContext context) {
    final controller = MensajeriaScope.of(context);

    return LiquidBackground(
      child: Scaffold(
        // El contenido se extiende bajo el menú para que el vidrio lo desenfoque.
        extendBody: true,
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              // Todas las pestañas siguen vivas: conservan su scroll y búsqueda.
              child: IndexedStack(index: _indice, children: _pantallas),
            ),
          ),
        ),
        bottomNavigationBar: BarraInferior(
          indice: _indice,
          onCambio: _cambiar,
          noLeidos: controller.totalNoLeidos,
          perdidas: controller.perdidas,
        ),
      ),
    );
  }
}
