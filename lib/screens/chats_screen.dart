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
import 'chat_screen.dart';

/// Pestaña "Chats": conversaciones, la más reciente primero.
class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final _busqueda = TextEditingController();
  String _consulta = '';

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  void _abrir(Persona persona) =>
      Navigator.of(context).push(rutaSuave(ChatScreen(persona: persona)));

  @override
  Widget build(BuildContext context) {
    final controller = MensajeriaScope.of(context);
    final q = _consulta.trim().toLowerCase();
    final lista = [
      for (final c in controller.conversaciones)
        if (q.isEmpty ||
            c.persona.nombre.toLowerCase().contains(q) ||
            (c.ultimo?.texto.toLowerCase().contains(q) ?? false))
          c,
    ];
    final noLeidos = controller.totalNoLeidos;
    final inferior = MediaQuery.paddingOf(context).bottom;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverToBoxAdapter(
          child: EncabezadoPantalla(
            titulo: 'Chats',
            subtitulo: noLeidos == 0
                ? 'Estás al día'
                : '$noLeidos ${noLeidos == 1 ? 'mensaje nuevo' : 'mensajes nuevos'}',
            acciones: [
              const BotonTema(),
              GlassButton(
                circular: true,
                tooltip: 'Nuevo chat',
                onPressed: () => _nuevoChat(context, controller),
                child: const Icon(Icons.edit_square),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: CampoBusqueda(
            controller: _busqueda,
            hint: 'Buscar en los chats…',
            onChanged: (v) => setState(() => _consulta = v),
          ),
        ),
        if (lista.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EstadoVacio(
              icono: q.isEmpty
                  ? Icons.chat_bubble_outline_rounded
                  : Icons.search_off_rounded,
              titulo: q.isEmpty ? 'No tienes chats' : 'Sin resultados',
              detalle: q.isEmpty
                  ? 'Toca el lápiz para iniciar una conversación.'
                  : 'Prueba con otra búsqueda.',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverList.separated(
              itemCount: lista.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final c = lista[i];
                return Dismissible(
                  key: ValueKey('chat-${c.persona.id}'),
                  direction: DismissDirection.endToStart,
                  background: const _FondoBorrar(),
                  onDismissed: (_) {
                    controller.eliminarConversacion(c);
                    ScaffoldMessenger.of(context)
                      ..clearSnackBars()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                            'Chat con ${c.persona.nombre} eliminado',
                          ),
                        ),
                      );
                  },
                  child: _TarjetaChat(
                    conversacion: c,
                    onTap: () => _abrir(c.persona),
                  ),
                );
              },
            ),
          ),
        SliverToBoxAdapter(child: SizedBox(height: inferior + 24)),
      ],
    );
  }

  /// Hoja de vidrio con todos los contactos para iniciar un chat.
  void _nuevoChat(BuildContext context, MensajeriaController controller) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.2),
      elevation: 0,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheet) => FractionallySizedBox(
        heightFactor: 0.75,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: GlassContainer(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 22, 24, 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Nuevo chat',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 12),
                    itemCount: controller.personas.length,
                    itemBuilder: (context, i) {
                      final p = controller.personas[i];
                      return ListTile(
                        leading: Avatar(p, tamano: 44),
                        title: Text(
                          p.nombre,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(p.conexion),
                        onTap: () {
                          Navigator.of(sheet).pop();
                          _abrir(p);
                        },
                      );
                    },
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

class _FondoBorrar extends StatelessWidget {
  const _FondoBorrar();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: AppTheme.rojo.withValues(alpha: 0.85),
      ),
      child: const Icon(Icons.delete_rounded, color: Colors.white),
    );
  }
}

class _TarjetaChat extends StatelessWidget {
  const _TarjetaChat({required this.conversacion, required this.onTap});

  final Conversacion conversacion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = conversacion;
    final ultimo = c.ultimo!;
    final sinLeer = c.noLeidos > 0;
    final vista = c.escribiendo
        ? 'escribiendo…'
        : '${ultimo.esMio ? 'Tú: ' : ''}${ultimo.texto}';

    return Presionable(
      onTap: onTap,
      semanticLabel: 'Abrir chat con ${c.persona.nombre}',
      child: GlassContainer(
        radius: 26,
        blur: 0,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Avatar(c.persona, tamano: 56),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            c.persona.nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          etiquetaFecha(ultimo.hora),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: sinLeer
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: sinLeer ? AppTheme.azul : atenuado(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            vista,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: sinLeer || c.escribiendo
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: c.escribiendo
                                  ? AppTheme.verde
                                  : atenuado(context, sinLeer ? 0.9 : 0.6),
                            ),
                          ),
                        ),
                        if (sinLeer) ...[
                          const SizedBox(width: 8),
                          Container(
                            constraints: const BoxConstraints(minWidth: 22),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: AppTheme.azul,
                            ),
                            child: Text(
                              '${c.noLeidos}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
