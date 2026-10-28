import 'package:flutter/material.dart';

import '../app/mensajeria_controller.dart';
import '../models/formato.dart';
import '../models/mensaje.dart';
import '../models/persona.dart';
import '../theme/app_theme.dart';
import '../widgets/aparecer.dart';
import '../widgets/avatar.dart';
import '../widgets/componentes.dart';
import '../widgets/glass.dart';
import 'llamada_screen.dart';

/// Conversación con una persona. Las respuestas son simuladas.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.persona});

  final Persona persona;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final MensajeriaController _controller = MensajeriaScope.read(context);
  late final Conversacion _conversacion = _controller.conversacionCon(
    widget.persona,
  );
  final _texto = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // Se notifica tras el primer frame: no se puede durante la construcción.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _controller.abrirConversacion(_conversacion),
    );
  }

  @override
  void dispose() {
    _controller.cerrarConversacion();
    _texto.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _enviar() {
    final t = _texto.text;
    if (t.trim().isEmpty) return;
    _texto.clear();
    _controller.enviar(_conversacion, t);
    if (_scroll.hasClients) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _llamar(bool video) => Navigator.of(context)
      .push(rutaSuave(LlamadaScreen(persona: widget.persona, video: video)));

  @override
  Widget build(BuildContext context) {
    // Escucha el controlador para refrescar mensajes y "escribiendo…".
    MensajeriaScope.of(context);
    final c = _conversacion;
    final mensajes = c.mensajes.reversed.toList();
    final extra = c.escribiendo ? 1 : 0;

    return LiquidBackground(
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                children: [
                  _Cabecera(
                    persona: widget.persona,
                    escribiendo: c.escribiendo,
                    onLlamar: () => _llamar(false),
                    onVideo: () => _llamar(true),
                  ),
                  Expanded(
                    child: mensajes.isEmpty && !c.escribiendo
                        ? EstadoVacio(
                            icono: Icons.waving_hand_rounded,
                            titulo: 'Saluda a ${widget.persona.nombre}',
                            detalle: 'Escribe tu primer mensaje.',
                          )
                        : ListView.builder(
                            controller: _scroll,
                            reverse: true,
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                            itemCount: mensajes.length + extra,
                            itemBuilder: (context, i) {
                              if (c.escribiendo && i == 0) {
                                return const _BurbujaEscribiendo();
                              }
                              return _Burbuja(mensajes[i - extra]);
                            },
                          ),
                  ),
                  _BarraEscritura(controller: _texto, onEnviar: _enviar),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Cabecera extends StatelessWidget {
  const _Cabecera({
    required this.persona,
    required this.escribiendo,
    required this.onLlamar,
    required this.onVideo,
  });

  final Persona persona;
  final bool escribiendo;
  final VoidCallback onLlamar;
  final VoidCallback onVideo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          GlassButton(
            circular: true,
            tooltip: 'Atrás',
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GlassContainer(
              radius: 26,
              padding: const EdgeInsets.fromLTRB(8, 6, 16, 6),
              child: Row(
                children: [
                  Avatar(persona, tamano: 40),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          persona.nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          escribiendo ? 'escribiendo…' : persona.conexion,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: escribiendo || persona.enLinea
                                ? AppTheme.verde
                                : atenuado(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GlassButton(
            circular: true,
            tooltip: 'Llamar',
            onPressed: onLlamar,
            child: const Icon(Icons.call_rounded),
          ),
          const SizedBox(width: 8),
          GlassButton(
            circular: true,
            tooltip: 'Videollamada',
            onPressed: onVideo,
            child: const Icon(Icons.videocam_rounded),
          ),
        ],
      ),
    );
  }
}

class _Burbuja extends StatelessWidget {
  const _Burbuja(this.mensaje);

  final Mensaje mensaje;

  @override
  Widget build(BuildContext context) {
    final mio = mensaje.esMio;
    final ancho = MediaQuery.sizeOf(context).width;
    final colorTexto = mio ? Colors.white : null;

    final contenido = Padding(
      padding: const EdgeInsets.fromLTRB(14, 9, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            mensaje.texto,
            style: TextStyle(fontSize: 16, height: 1.25, color: colorTexto),
          ),
          const SizedBox(height: 3),
          Text(
            formatoHora(mensaje.hora),
            style: TextStyle(
              fontSize: 11,
              color: mio ? Colors.white70 : atenuado(context, 0.5),
            ),
          ),
        ],
      ),
    );

    return Align(
      alignment: mio ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: ancho * 0.78),
          child: GlassContainer(
            radius: 22,
            blur: 0,
            shadow: false,
            tint: mio ? AppTheme.azul.withValues(alpha: 0.88) : null,
            child: contenido,
          ),
        ),
      ),
    );
  }
}

/// Burbuja con tres puntos que laten mientras la otra persona "escribe".
class _BurbujaEscribiendo extends StatefulWidget {
  const _BurbujaEscribiendo();

  @override
  State<_BurbujaEscribiendo> createState() => _BurbujaEscribiendoState();
}

class _BurbujaEscribiendoState extends State<_BurbujaEscribiendo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = atenuado(context, 0.7);

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: GlassContainer(
          radius: 22,
          blur: 0,
          shadow: false,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: AnimatedBuilder(
            animation: _anim,
            builder: (context, _) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 3; i++)
                  Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.only(left: i == 0 ? 0 : 5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(
                        alpha:
                            0.35 +
                            0.65 *
                                (1 -
                                        ((_anim.value * 3 - i) % 3 - 0.5)
                                            .abs()
                                            .clamp(0, 1))
                                    .clamp(0.0, 1.0),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BarraEscritura extends StatelessWidget {
  const _BarraEscritura({required this.controller, required this.onEnviar});

  final TextEditingController controller;
  final VoidCallback onEnviar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: GlassContainer(
              radius: 26,
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onEnviar(),
                decoration: const InputDecoration(
                  hintText: 'Escribe un mensaje…',
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GlassButton(
            circular: true,
            tint: AppTheme.azul.withValues(alpha: 0.92),
            tooltip: 'Enviar',
            onPressed: onEnviar,
            child: const Icon(Icons.send_rounded),
          ),
        ],
      ),
    );
  }
}
