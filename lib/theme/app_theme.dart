import 'package:flutter/material.dart';

/// Colores del efecto "liquid glass". Al ser una [ThemeExtension], Flutter los
/// interpola al cambiar de tema y el paso claro ↔ oscuro es continuo.
@immutable
class GlassPalette extends ThemeExtension<GlassPalette> {
  const GlassPalette({
    required this.fondo,
    required this.mancha1,
    required this.mancha2,
    required this.mancha3,
    required this.vidrio,
    required this.borde,
    required this.brilloA,
    required this.brilloB,
    required this.sombra,
    required this.control,
    required this.controlActivo,
  });

  final Color fondo;
  final Color mancha1;
  final Color mancha2;
  final Color mancha3;
  final Color vidrio;
  final Color borde;
  final Color brilloA;
  final Color brilloB;
  final Color sombra;

  /// Fondo de los controles segmentados y su indicador.
  final Color control;
  final Color controlActivo;

  static const oscuro = GlassPalette(
    fondo: Color(0xFF070A12),
    mancha1: Color(0x734C8DFF),
    mancha2: Color(0x668A4DFF),
    mancha3: Color(0x59FF5C9A),
    vidrio: Color(0x12FFFFFF),
    borde: Color(0x21FFFFFF),
    brilloA: Color(0x1FFFFFFF),
    brilloB: Color(0x0AFFFFFF),
    sombra: Color(0x59000000),
    control: Color(0x14FFFFFF),
    controlActivo: Color(0x24FFFFFF),
  );

  static const claro = GlassPalette(
    fondo: Color(0xFFEEF3FB),
    mancha1: Color(0x994C8DFF),
    mancha2: Color(0x8CB794F6),
    mancha3: Color(0x80FF8FB8),
    vidrio: Color(0x6BFFFFFF),
    borde: Color(0xCCFFFFFF),
    brilloA: Color(0x73FFFFFF),
    brilloB: Color(0x1FFFFFFF),
    sombra: Color(0x12000000),
    control: Color(0x0D000000),
    controlActivo: Color(0xE6FFFFFF),
  );

  static GlassPalette of(BuildContext context) =>
      Theme.of(context).extension<GlassPalette>()!;

  @override
  GlassPalette copyWith() => this;

  @override
  GlassPalette lerp(ThemeExtension<GlassPalette>? other, double t) {
    if (other is! GlassPalette) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return GlassPalette(
      fondo: c(fondo, other.fondo),
      mancha1: c(mancha1, other.mancha1),
      mancha2: c(mancha2, other.mancha2),
      mancha3: c(mancha3, other.mancha3),
      vidrio: c(vidrio, other.vidrio),
      borde: c(borde, other.borde),
      brilloA: c(brilloA, other.brilloA),
      brilloB: c(brilloB, other.brilloB),
      sombra: c(sombra, other.sombra),
      control: c(control, other.control),
      controlActivo: c(controlActivo, other.controlActivo),
    );
  }
}

class AppTheme {
  /// Azul principal de la app.
  static const azul = Color(0xFF4C8DFF);

  /// Verde de "en línea" y de las llamadas completadas.
  static const verde = Color(0xFF34C77B);

  /// Rojo de llamadas perdidas y de colgar.
  static const rojo = Color(0xFFFF4D5E);

  static ThemeData get claro => _base(Brightness.light);
  static ThemeData get oscuro => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final esOscuro = brightness == Brightness.dark;
    final paleta = esOscuro ? GlassPalette.oscuro : GlassPalette.claro;
    final scheme = ColorScheme.fromSeed(
      seedColor: azul,
      brightness: brightness,
      surface: paleta.fondo,
    );
    final texto = esOscuro ? Colors.white : const Color(0xFF10151C);

    OutlineInputBorder borde(Color color, [double ancho = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: color, width: ancho),
        );

    return ThemeData(
      colorScheme: scheme,
      brightness: brightness,
      scaffoldBackgroundColor: Colors.transparent,
      splashFactory: InkSparkle.splashFactory,
      extensions: [paleta],
      textTheme: Typography.material2021(platform: TargetPlatform.iOS).black
          .apply(bodyColor: texto, displayColor: texto),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: esOscuro
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.6),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: borde(Colors.transparent),
        enabledBorder: borde(paleta.borde),
        focusedBorder: borde(scheme.primary, 1.5),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: esOscuro
            ? const Color(0xFF2A2F3C)
            : const Color(0xFF10151C),
        contentTextStyle: const TextStyle(color: Colors.white),
        actionTextColor: azul,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: esOscuro ? const Color(0xFF2A2F3C) : const Color(0xFF10151C),
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 12.5),
      ),
    );
  }
}
