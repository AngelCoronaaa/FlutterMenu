import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/llamada.dart';
import '../models/mensaje.dart';
import '../models/persona.dart';
import 'datos_simulados.dart';

/// Estado de la app: contactos, conversaciones, llamadas y aspecto.
/// Todo es simulado y vive en memoria.
class MensajeriaController extends ChangeNotifier {
  MensajeriaController() {
    final ahora = DateTime.now();
    final base = personasSimuladas();
    _conversaciones = conversacionesSimuladas(base, ahora);
    _llamadas = llamadasSimuladas(base, ahora);
    personas = base..sort((a, b) => a.nombre.compareTo(b.nombre));
  }

  final _azar = Random();
  final _timers = <Timer>{};

  late List<Persona> personas;
  late List<Conversacion> _conversaciones;
  late List<Llamada> _llamadas;
  ThemeMode themeMode = ThemeMode.system;

  /// Conversación que el usuario tiene abierta (no acumula "no leídos").
  Persona? _abierta;
  int _siguienteLlamada = 100;

  /// Conversaciones con mensajes, la más reciente primero.
  List<Conversacion> get conversaciones =>
      _conversaciones.where((c) => c.mensajes.isNotEmpty).toList()
        ..sort((a, b) => b.fecha.compareTo(a.fecha));

  List<Llamada> get llamadas =>
      List.of(_llamadas)..sort((a, b) => b.fecha.compareTo(a.fecha));

  int get totalNoLeidos => _conversaciones.fold(0, (s, c) => s + c.noLeidos);
  int get perdidas => _llamadas.where((l) => l.perdida && !l.vista).length;

  void marcarLlamadasVistas() {
    if (perdidas == 0) return;
    for (final l in _llamadas) {
      l.vista = true;
    }
    notifyListeners();
  }

  void setThemeMode(ThemeMode modo) {
    if (modo == themeMode) return;
    themeMode = modo;
    notifyListeners();
  }

  // --- Chats ---------------------------------------------------------------

  /// Devuelve la conversación con [persona]; la crea si no existe.
  Conversacion conversacionCon(Persona persona) {
    for (final c in _conversaciones) {
      if (c.persona.id == persona.id) return c;
    }
    final nueva = Conversacion(persona: persona);
    _conversaciones.add(nueva);
    return nueva;
  }

  /// Marca la conversación como abierta y leída.
  void abrirConversacion(Conversacion c) {
    _abierta = c.persona;
    if (c.noLeidos != 0) {
      c.noLeidos = 0;
      notifyListeners();
    }
  }

  void cerrarConversacion() => _abierta = null;

  void eliminarConversacion(Conversacion c) {
    c.mensajes.clear();
    c.noLeidos = 0;
    c.escribiendo = false;
    notifyListeners();
  }

  /// Envía un mensaje y simula la respuesta: primero "escribiendo…" y
  /// después el mensaje de la otra persona.
  void enviar(Conversacion c, String texto) {
    final limpio = texto.trim();
    if (limpio.isEmpty) return;

    c.mensajes.add(Mensaje(texto: limpio, esMio: true, hora: DateTime.now()));
    notifyListeners();

    _programar(Duration(milliseconds: 700 + _azar.nextInt(500)), () {
      c.escribiendo = true;
      notifyListeners();
      _programar(Duration(milliseconds: 1400 + _azar.nextInt(1400)), () {
        c.escribiendo = false;
        c.mensajes.add(
          Mensaje(
            texto:
                respuestasSimuladas[_azar.nextInt(respuestasSimuladas.length)],
            esMio: false,
            hora: DateTime.now(),
          ),
        );
        if (_abierta?.id != c.persona.id) c.noLeidos++;
        notifyListeners();
      });
    });
  }

  // --- Llamadas ------------------------------------------------------------

  void registrarLlamada(
    Persona persona,
    TipoLlamada tipo, {
    bool video = false,
    Duration duracion = Duration.zero,
  }) {
    _llamadas.add(
      Llamada(
        id: _siguienteLlamada++,
        persona: persona,
        tipo: tipo,
        fecha: DateTime.now(),
        video: video,
        duracion: duracion,
      ),
    );
    notifyListeners();
  }

  void eliminarLlamada(Llamada l) {
    _llamadas.removeWhere((x) => x.id == l.id);
    notifyListeners();
  }

  void borrarHistorial() {
    _llamadas.clear();
    notifyListeners();
  }

  void _programar(Duration espera, VoidCallback accion) {
    late final Timer timer;
    timer = Timer(espera, () {
      _timers.remove(timer);
      accion();
    });
    _timers.add(timer);
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }
}

/// Da acceso al [MensajeriaController] desde cualquier pantalla.
class MensajeriaScope extends InheritedNotifier<MensajeriaController> {
  const MensajeriaScope({
    super.key,
    required MensajeriaController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Se reconstruye cuando cambia cualquier dato.
  static MensajeriaController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MensajeriaScope>()!.notifier!;

  /// Lectura sin suscribirse (initState y callbacks).
  static MensajeriaController read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<MensajeriaScope>()!.notifier!;
}
