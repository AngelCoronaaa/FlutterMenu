import 'package:flutter/material.dart';

import '../models/persona.dart';
import '../theme/app_theme.dart';

/// Círculo con degradado, iniciales y un punto verde si está en línea.
class Avatar extends StatelessWidget {
  const Avatar(
    this.persona, {
    super.key,
    this.tamano = 52,
    this.indicador = true,
  });

  final Persona persona;
  final double tamano;
  final bool indicador;

  @override
  Widget build(BuildContext context) {
    final borde = Theme.of(context).colorScheme.surface;
    final punto = tamano * 0.27;

    return SizedBox.square(
      dimension: tamano,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(persona.color, Colors.white, 0.28)!,
                  persona.color,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: persona.color.withValues(alpha: 0.35),
                  blurRadius: tamano * 0.25,
                  offset: Offset(0, tamano * 0.08),
                ),
              ],
            ),
            child: Text(
              persona.iniciales,
              style: TextStyle(
                color: Colors.white,
                fontSize: tamano * 0.36,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (indicador && persona.enLinea)
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: punto,
                height: punto,
                decoration: BoxDecoration(
                  color: AppTheme.verde,
                  shape: BoxShape.circle,
                  border: Border.all(color: borde, width: tamano * 0.045),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
