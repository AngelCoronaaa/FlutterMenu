import 'package:flutter/material.dart';

import '../app/mensajeria_controller.dart';
import '../models/persona.dart';
import '../theme/app_theme.dart';
import '../widgets/aparecer.dart';
import '../widgets/avatar.dart';
import '../widgets/componentes.dart';
import '../widgets/glass.dart';
import 'chat_screen.dart';
import 'llamada_screen.dart';

/// Pestaña "Personas": contactos ordenados alfabéticamente.
class PersonasScreen extends StatefulWidget {
  const PersonasScreen({super.key});

  @override
  State<PersonasScreen> createState() => _PersonasScreenState();
}

class _PersonasScreenState extends State<PersonasScreen> {
  final _busqueda = TextEditingController();
  String _consulta = '';
  bool _soloEnLinea = false;

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  List<Persona> _filtradas(List<Persona> todas) {
    final q = _consulta.trim().toLowerCase();
    return [
      for (final p in todas)
        if ((!_soloEnLinea || p.enLinea) &&
            (q.isEmpty ||
                p.nombre.toLowerCase().contains(q) ||
                p.telefono.contains(q)))
          p,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final controller = MensajeriaScope.of(context);
    final lista = _filtradas(controller.personas);
    final enLinea = controller.personas.where((p) => p.enLinea).length;
    final inferior = MediaQuery.paddingOf(context).bottom;

    // Agrupa por inicial: "A", "B", …
    final grupos = <String, List<Persona>>{};
    for (final p in lista) {
      grupos.putIfAbsent(p.nombre[0].toUpperCase(), () => []).add(p);
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverToBoxAdapter(
          child: EncabezadoPantalla(
            titulo: 'Personas',
            subtitulo:
                '${controller.personas.length} contactos · $enLinea en línea',
            acciones: const [BotonTema()],
          ),
        ),
        SliverToBoxAdapter(
          child: CampoBusqueda(
            controller: _busqueda,
            hint: 'Buscar personas…',
            onChanged: (v) => setState(() => _consulta = v),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
            child: GlassSegmented<bool>(
              alto: 44,
              opciones: const [(false, 'Todos'), (true, 'En línea')],
              valor: _soloEnLinea,
              onCambio: (v) => setState(() => _soloEnLinea = v),
            ),
          ),
        ),
        if (lista.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: EstadoVacio(
              icono: Icons.person_search_rounded,
              titulo: 'Sin resultados',
              detalle: 'Prueba con otro nombre o número.',
            ),
          )
        else
          for (final MapEntry(key: letra, value: personas) in grupos.entries)
            SliverMainAxisGroup(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 18, 20, 8),
                    child: Text(
                      letra,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.azul,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: GlassContainer(
                      radius: 26,
                      blur: 0,
                      child: Column(
                        children: [
                          for (var i = 0; i < personas.length; i++) ...[
                            if (i > 0) const SeparadorFila(),
                            _FilaPersona(
                              persona: personas[i],
                              onTap: () => _mostrarPerfil(context, personas[i]),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
        SliverToBoxAdapter(child: SizedBox(height: inferior + 24)),
      ],
    );
  }
}

class _FilaPersona extends StatelessWidget {
  const _FilaPersona({required this.persona, required this.onTap});

  final Persona persona;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Presionable(
      onTap: onTap,
      semanticLabel: 'Ver perfil de ${persona.nombre}',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          children: [
            Avatar(persona),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    persona.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    persona.estado,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13.5, color: atenuado(context)),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: atenuado(context, 0.4)),
          ],
        ),
      ),
    );
  }
}

/// Perfil de la persona en una hoja de vidrio, con acciones rápidas.
void _mostrarPerfil(BuildContext context, Persona persona) {
  final navegador = Navigator.of(context);

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.2),
    elevation: 0,
    useSafeArea: true,
    builder: (sheet) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: GlassContainer(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Avatar(persona, tamano: 96),
            const SizedBox(height: 16),
            Text(
              persona.nombre,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              persona.conexion,
              style: TextStyle(
                color: persona.enLinea ? AppTheme.verde : atenuado(sheet),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '“${persona.estado}”',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: atenuado(sheet, 0.75)),
            ),
            const SizedBox(height: 4),
            Text(
              persona.telefono,
              style: TextStyle(fontSize: 14, color: atenuado(sheet)),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GlassButton(
                    tint: AppTheme.azul.withValues(alpha: 0.92),
                    onPressed: () {
                      Navigator.of(sheet).pop();
                      navegador.push(rutaSuave(ChatScreen(persona: persona)));
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_rounded, size: 20),
                        SizedBox(width: 8),
                        Text('Mensaje'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GlassButton(
                  circular: true,
                  tooltip: 'Llamar',
                  onPressed: () {
                    Navigator.of(sheet).pop();
                    navegador.push(rutaSuave(LlamadaScreen(persona: persona)));
                  },
                  child: const Icon(Icons.call_rounded),
                ),
                const SizedBox(width: 12),
                GlassButton(
                  circular: true,
                  tooltip: 'Videollamada',
                  onPressed: () {
                    Navigator.of(sheet).pop();
                    navegador.push(
                      rutaSuave(LlamadaScreen(persona: persona, video: true)),
                    );
                  },
                  child: const Icon(Icons.videocam_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
