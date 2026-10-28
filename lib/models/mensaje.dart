import 'persona.dart';

class Mensaje {
  const Mensaje({required this.texto, required this.esMio, required this.hora});

  final String texto;
  final bool esMio;
  final DateTime hora;
}

class Conversacion {
  Conversacion({
    required this.persona,
    List<Mensaje>? mensajes,
    this.noLeidos = 0,
  }) : mensajes = mensajes ?? [];

  final Persona persona;
  final List<Mensaje> mensajes;
  int noLeidos;

  /// Indica que la otra persona está "escribiendo…".
  bool escribiendo = false;

  Mensaje? get ultimo => mensajes.isEmpty ? null : mensajes.last;
  DateTime get fecha => ultimo?.hora ?? DateTime.fromMillisecondsSinceEpoch(0);
}
