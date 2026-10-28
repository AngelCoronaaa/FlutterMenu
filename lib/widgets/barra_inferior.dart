import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'glass.dart';

/// Menú inferior de vidrio flotante (Personas, Chats, Llamadas).
///
/// Usa el widget [BottomNavigationBar] de Flutter sobre una superficie de
/// vidrio; detrás de la opción activa se desliza una "píldora" de vidrio.
class BarraInferior extends StatelessWidget {
  const BarraInferior({
    super.key,
    required this.indice,
    required this.onCambio,
    this.noLeidos = 0,
    this.perdidas = 0,
  });

  final int indice;
  final ValueChanged<int> onCambio;

  /// Insignia del tab Chats.
  final int noLeidos;

  /// Insignia del tab Llamadas.
  final int perdidas;

  static const _alto = 66.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final inferior = MediaQuery.paddingOf(context).bottom;

    Widget icono(IconData data, int cantidad) => Badge(
      isLabelVisible: cantidad > 0,
      label: Text('$cantidad'),
      backgroundColor: AppTheme.rojo,
      textColor: Colors.white,
      child: Icon(data),
    );

    return Align(
      heightFactor: 1,
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, inferior > 0 ? inferior : 14),
          child: GlassContainer(
            radius: 34,
            blur: 28,
            child: SizedBox(
              height: _alto,
              child: Stack(
                children: [
                  // Píldora que se desliza hasta la opción activa.
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: AnimatedAlign(
                      alignment: Alignment(indice - 1.0, 0),
                      duration: const Duration(milliseconds: 380),
                      curve: Curves.easeOutBack,
                      child: FractionallySizedBox(
                        widthFactor: 1 / 3,
                        heightFactor: 1,
                        child: GlassContainer(
                          radius: 28,
                          blur: 0,
                          shadow: false,
                          tint: AppTheme.azul.withValues(alpha: 0.22),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                  ),
                  // El BottomNavigationBar no pinta fondo ni sombra ni salpicado.
                  Theme(
                    data: Theme.of(context).copyWith(
                      splashFactory: NoSplash.splashFactory,
                      highlightColor: Colors.transparent,
                    ),
                    child: MediaQuery.removePadding(
                      context: context,
                      removeBottom: true,
                      child: BottomNavigationBar(
                        currentIndex: indice,
                        onTap: onCambio,
                        type: BottomNavigationBarType.fixed,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        selectedItemColor: AppTheme.azul,
                        unselectedItemColor: scheme.onSurface.withValues(
                          alpha: 0.55,
                        ),
                        selectedFontSize: 12,
                        unselectedFontSize: 12,
                        selectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                        items: [
                          BottomNavigationBarItem(
                            icon: icono(Icons.people_outline_rounded, 0),
                            activeIcon: icono(Icons.people_alt_rounded, 0),
                            label: 'Personas',
                            tooltip: 'Personas',
                          ),
                          BottomNavigationBarItem(
                            icon: icono(
                              Icons.chat_bubble_outline_rounded,
                              noLeidos,
                            ),
                            activeIcon: icono(
                              Icons.chat_bubble_rounded,
                              noLeidos,
                            ),
                            label: 'Chats',
                            tooltip: 'Chats',
                          ),
                          BottomNavigationBarItem(
                            icon: icono(Icons.call_outlined, perdidas),
                            activeIcon: icono(Icons.call_rounded, perdidas),
                            label: 'Llamadas',
                            tooltip: 'Llamadas',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
