import 'package:flutter/material.dart';

import '../app/mensajeria_controller.dart';
import '../models/formato.dart';
import '../models/llamada.dart';
import '../theme/app_theme.dart';
import '../widgets/aparecer.dart';
import '../widgets/avatar.dart';
import '../widgets/componentes.dart';
import '../widgets/glass.dart';
import 'llamada_screen.dart';

/// Pestaña "Llamadas": historial con filtro de perdidas.
class LlamadasScreen extends StatefulWidget {
  const LlamadasScreen({super.key});

  @override
  State<LlamadasScreen> createState() => _LlamadasScreenState();
}

class _LlamadasScreenState extends State<LlamadasScreen> {
  bool _soloPerdidas = false;

  void _llamar(Llamada l) =>
      Navigator.of(context)
          .push(rutaSuave(LlamadaScreen(persona: l.persona, video: l.video)));

  Future<void> _borrarHistorial(MensajeriaController controller) async {
    final ok = await confirmar(
      context,
      icono: Icons.delete_sweep_rounded,
      titulo: '¿Borrar todo el historial?',
      accion: 'Borrar',
      color: AppTheme.rojo,
    );
    if (ok) controller.borrarHistorial();
  }

  @override
  Widget build(BuildContext context) {
    final controller = MensajeriaScope.of(context);
    final todas = controller.llamadas;
    final lista = _soloPerdidas
        ? todas.where((l) => l.perdida).toList()
        : todas;
    final inferior = MediaQuery.paddingOf(context).bottom;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: EncabezadoPantalla(
            titulo: 'Llamadas',
            subtitulo: '${todas.length} en el historial',
            acciones: [
              const BotonTema(),
              GlassButton(
                circular: true,
                tooltip: 'Borrar historial',
                onPressed: todas.isEmpty
                    ? null
                    : () => _borrarHistorial(controller),
                child: const Icon(Icons.delete_sweep_rounded),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GlassSegmented<bool>(
              alto: 44,
              opciones: const [(false, 'Todas'), (true, 'Perdidas')],
              valor: _soloPerdidas,
              onCambio: (v) => setState(() => _soloPerdidas = v),
            ),
          ),
        ),
        if (lista.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EstadoVacio(
              icono: _soloPerdidas
                  ? Icons.phone_callback_rounded
                  : Icons.phone_disabled_rounded,
              titulo: _soloPerdidas
                  ? 'Sin llamadas perdidas'
                  : 'Sin llamadas recientes',
              detalle: 'Llama a alguien desde la pestaña Personas.',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverToBoxAdapter(
              child: GlassContainer(
                radius: 26,
                blur: 0,
                child: Column(
                  children: [
                    for (var i = 0; i < lista.length; i++) ...[
                      if (i > 0) const SeparadorFila(),
                      Dismissible(
                        key: ValueKey('llamada-${lista[i].id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          color: AppTheme.rojo.withValues(alpha: 0.85),
                          child: const Icon(
                            Icons.delete_rounded,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (_) =>
                            controller.eliminarLlamada(lista[i]),
                        child: _FilaLlamada(
                          llamada: lista[i],
                          onLlamar: () => _llamar(lista[i]),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        SliverToBoxAdapter(child: SizedBox(height: inferior + 24)),
      ],
    );
  }
}

class _FilaLlamada extends StatelessWidget {
  const _FilaLlamada({required this.llamada, required this.onLlamar});

  final Llamada llamada;
  final VoidCallback onLlamar;

  @override
  Widget build(BuildContext context) {
    final l = llamada;
    final (icono, color) = switch (l.tipo) {
      TipoLlamada.entrante => (Icons.call_received_rounded, AppTheme.verde),
      TipoLlamada.saliente => (Icons.call_made_rounded, AppTheme.azul),
      TipoLlamada.perdida => (Icons.call_missed_rounded, AppTheme.rojo),
    };
    final detalle = switch (l.tipo) {
      TipoLlamada.perdida => 'Perdida',
      _ when l.duracion == Duration.zero => 'Sin respuesta',
      _ => duracionLarga(l.duracion),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 11, 8, 11),
      child: Row(
        children: [
          Avatar(l.persona, indicador: false),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.persona.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: l.perdida ? AppTheme.rojo : null,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(icono, size: 16, color: color),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${fechaLlamada(l.fecha)} · $detalle',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: atenuado(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l.video ? 'Videollamar' : 'Llamar',
            onPressed: onLlamar,
            icon: Icon(
              l.video ? Icons.videocam_rounded : Icons.call_rounded,
              color: AppTheme.azul,
            ),
          ),
        ],
      ),
    );
  }
}
