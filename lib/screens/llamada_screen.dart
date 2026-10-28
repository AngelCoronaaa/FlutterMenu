import 'dart:async';

import 'package:flutter/material.dart';

import '../app/mensajeria_controller.dart';
import '../models/formato.dart';
import '../models/llamada.dart';
import '../models/persona.dart';
import '../theme/app_theme.dart';
import '../widgets/avatar.dart';
import '../widgets/componentes.dart';
import '../widgets/glass.dart';

enum _Fase { llamando, conectada, sinRespuesta, finalizada }

/// Llamada simulada: timbra, "contesta" si la persona está en línea y
/// cuenta el tiempo. Al terminar queda registrada en el historial.
class LlamadaScreen extends StatefulWidget {
  const LlamadaScreen({super.key, required this.persona, this.video = false});

  final Persona persona;
  final bool video;

  @override
  State<LlamadaScreen> createState() => _LlamadaScreenState();
}

class _LlamadaScreenState extends State<LlamadaScreen>
    with SingleTickerProviderStateMixin {
  late final MensajeriaController _controller = MensajeriaScope.read(context);
  late final AnimationController _ondas = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  _Fase _fase = _Fase.llamando;
  Duration _duracion = Duration.zero;
  Timer? _espera;
  Timer? _reloj;
  bool _silencio = false;
  bool _altavoz = false;
  late bool _camara = widget.video;

  @override
  void initState() {
    super.initState();
    // Si la persona no está en línea, la llamada se queda sin respuesta.
    _espera = Timer(
      Duration(milliseconds: widget.persona.enLinea ? 2600 : 6000),
      widget.persona.enLinea ? _contestar : _noContesto,
    );
  }

  @override
  void dispose() {
    _espera?.cancel();
    _reloj?.cancel();
    _ondas.dispose();
    super.dispose();
  }

  void _contestar() {
    setState(() => _fase = _Fase.conectada);
    _ondas.stop();
    _reloj = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _duracion += const Duration(seconds: 1));
    });
  }

  void _noContesto() {
    setState(() => _fase = _Fase.sinRespuesta);
    _ondas.stop();
    _terminar(const Duration(milliseconds: 1500));
  }

  void _colgar() {
    if (_fase == _Fase.finalizada) return;
    _espera?.cancel();
    _reloj?.cancel();
    _ondas.stop();
    setState(() => _fase = _Fase.finalizada);
    _terminar(const Duration(milliseconds: 900));
  }

  bool _registrada = false;

  /// Guarda la llamada en el historial y cierra la pantalla.
  void _terminar(Duration espera) {
    if (!_registrada) {
      _registrada = true;
      _controller.registrarLlamada(
        widget.persona,
        TipoLlamada.saliente,
        video: widget.video,
        duracion: _duracion,
      );
    }
    Timer(espera, () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  String get _estado => switch (_fase) {
    _Fase.llamando => widget.video ? 'Videollamada…' : 'Llamando…',
    _Fase.conectada => formatoDuracion(_duracion),
    _Fase.sinRespuesta => 'Sin respuesta',
    _Fase.finalizada => 'Llamada finalizada',
  };

  @override
  Widget build(BuildContext context) {
    final persona = widget.persona;
    final conectada = _fase == _Fase.conectada;
    final activa = _fase == _Fase.llamando || conectada;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (pop, _) {
        if (!pop) _colgar();
      },
      child: LiquidBackground(
        child: Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    Text(
                      persona.nombre,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _estado,
                        key: ValueKey(
                          _estado.contains(':') ? 'reloj' : _estado,
                        ),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: conectada
                              ? AppTheme.verde
                              : _fase == _Fase.llamando
                              ? atenuado(context, 0.7)
                              : AppTheme.rojo,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: SizedBox.square(
                          dimension: 300,
                          child: AnimatedBuilder(
                            animation: _ondas,
                            builder: (context, _) => CustomPaint(
                              painter: _PintorOndas(
                                progreso: _ondas.value,
                                color: persona.color,
                                activo: _fase == _Fase.llamando,
                              ),
                              child: Center(
                                child: Avatar(
                                  persona,
                                  tamano: 132,
                                  indicador: false,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: GlassContainer(
                        radius: 34,
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _Control(
                              icono: _silencio
                                  ? Icons.mic_off_rounded
                                  : Icons.mic_rounded,
                              etiqueta: 'Silenciar',
                              activo: _silencio,
                              onTap: activa
                                  ? () => setState(() => _silencio = !_silencio)
                                  : null,
                            ),
                            _Control(
                              icono: _camara
                                  ? Icons.videocam_rounded
                                  : Icons.videocam_off_rounded,
                              etiqueta: 'Cámara',
                              activo: _camara,
                              onTap: activa
                                  ? () => setState(() => _camara = !_camara)
                                  : null,
                            ),
                            _Control(
                              icono: _altavoz
                                  ? Icons.volume_up_rounded
                                  : Icons.volume_down_rounded,
                              etiqueta: 'Altavoz',
                              activo: _altavoz,
                              onTap: activa
                                  ? () => setState(() => _altavoz = !_altavoz)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    GlassButton(
                      circular: true,
                      tint: AppTheme.rojo,
                      tooltip: 'Colgar',
                      padding: const EdgeInsets.all(22),
                      onPressed: activa ? _colgar : null,
                      child: const Icon(Icons.call_end_rounded, size: 30),
                    ),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Control extends StatelessWidget {
  const _Control({
    required this.icono,
    required this.etiqueta,
    required this.activo,
    required this.onTap,
  });

  final IconData icono;
  final String etiqueta;
  final bool activo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlassButton(
          circular: true,
          padding: const EdgeInsets.all(16),
          tint: activo ? AppTheme.azul.withValues(alpha: 0.9) : null,
          onPressed: onTap,
          child: Icon(icono, size: 26),
        ),
        const SizedBox(height: 8),
        Text(
          etiqueta,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: atenuado(context, 0.75),
          ),
        ),
      ],
    );
  }
}

/// Ondas concéntricas que se expanden mientras suena la llamada.
class _PintorOndas extends CustomPainter {
  _PintorOndas({
    required this.progreso,
    required this.color,
    required this.activo,
  });

  final double progreso;
  final Color color;
  final bool activo;

  @override
  void paint(Canvas canvas, Size size) {
    if (!activo) return;
    final centro = size.center(Offset.zero);
    const radioBase = 66.0;
    final radioMax = size.shortestSide / 2;

    for (var i = 0; i < 3; i++) {
      final t = (progreso + i / 3) % 1;
      final radio =
          radioBase + (radioMax - radioBase) * Curves.easeOut.transform(t);
      canvas.drawCircle(
        centro,
        radio,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = color.withValues(alpha: 0.5 * (1 - t)),
      );
      canvas.drawCircle(
        centro,
        radio,
        Paint()..color = color.withValues(alpha: 0.12 * (1 - t)),
      );
    }
  }

  @override
  bool shouldRepaint(_PintorOndas old) =>
      old.progreso != progreso || old.activo != activo || old.color != color;
}
