import 'package:flutter/material.dart';

import '../app/mensajeria_controller.dart';
import '../theme/app_theme.dart';
import 'glass.dart';

/// Color de texto secundario.
Color atenuado(BuildContext context, [double alfa = 0.6]) =>
    Theme.of(context).colorScheme.onSurface.withValues(alpha: alfa);

/// Título grande de pantalla con acciones a la derecha.
class EncabezadoPantalla extends StatelessWidget {
  const EncabezadoPantalla({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.acciones = const [],
  });

  final String titulo;
  final String? subtitulo;
  final List<Widget> acciones;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitulo != null)
                  Text(
                    subtitulo!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: atenuado(context), fontSize: 15),
                  ),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),
          for (final a in acciones) ...[const SizedBox(width: 10), a],
        ],
      ),
    );
  }
}

/// Campo de búsqueda sobre vidrio.
class CampoBusqueda extends StatelessWidget {
  const CampoBusqueda({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassContainer(
        radius: 22,
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: hint,
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, valor, _) => valor.text.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      tooltip: 'Borrar búsqueda',
                      icon: Icon(Icons.close_rounded, color: atenuado(context)),
                      onPressed: () {
                        controller.clear();
                        onChanged('');
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón circular sol ↔ luna: alterna entre claro y oscuro.
class BotonTema extends StatelessWidget {
  const BotonTema({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MensajeriaScope.of(context);
    final oscuro = switch (controller.themeMode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system =>
        MediaQuery.platformBrightnessOf(context) == Brightness.dark,
    };

    return GlassButton(
      circular: true,
      tooltip: 'Cambiar aspecto',
      onPressed: () =>
          controller.setThemeMode(oscuro ? ThemeMode.light : ThemeMode.dark),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        switchInCurve: Curves.easeOutBack,
        transitionBuilder: (child, anim) => RotationTransition(
          turns: Tween(begin: 0.4, end: 1.0).animate(anim),
          child: ScaleTransition(scale: anim, child: child),
        ),
        child: Icon(
          oscuro ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          key: ValueKey(oscuro),
        ),
      ),
    );
  }
}

/// Mensaje centrado para listas vacías.
class EstadoVacio extends StatelessWidget {
  const EstadoVacio({
    super.key,
    required this.icono,
    required this.titulo,
    this.detalle,
  });

  final IconData icono;
  final String titulo;
  final String? detalle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, size: 56, color: atenuado(context)),
          const SizedBox(height: 14),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          if (detalle != null) ...[
            const SizedBox(height: 6),
            Text(
              detalle!,
              textAlign: TextAlign.center,
              style: TextStyle(color: atenuado(context)),
            ),
          ],
        ],
      ),
    );
  }
}

/// Fila con separador fino para listas dentro de una tarjeta de vidrio.
class SeparadorFila extends StatelessWidget {
  const SeparadorFila({super.key, this.izquierda = 78});

  final double izquierda;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(left: izquierda, right: 16),
    child: Divider(
      height: 1,
      thickness: 1,
      color: GlassPalette.of(context).borde.withValues(alpha: 0.5),
    ),
  );
}

/// Confirmación en una ventana de vidrio.
Future<bool> confirmar(
  BuildContext context, {
  required IconData icono,
  required String titulo,
  required String accion,
  Color? color,
}) async {
  final resultado = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.3),
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(icono, size: 40),
              const SizedBox(height: 14),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Center(child: Text('Cancelar')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassButton(
                      tint: (color ?? AppTheme.azul).withValues(alpha: 0.92),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Center(child: Text(accion)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
  return resultado == true;
}
