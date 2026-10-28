import 'persona.dart';

enum TipoLlamada { entrante, saliente, perdida }

class Llamada {
  Llamada({
    required this.id,
    required this.persona,
    required this.tipo,
    required this.fecha,
    this.video = false,
    this.duracion = Duration.zero,
    this.vista = true,
  });

  final int id;
  final Persona persona;
  final TipoLlamada tipo;
  final DateTime fecha;
  final bool video;
  final Duration duracion;

  /// Las llamadas perdidas nuevas cuentan en la insignia del menú.
  bool vista;

  bool get perdida => tipo == TipoLlamada.perdida;
}
