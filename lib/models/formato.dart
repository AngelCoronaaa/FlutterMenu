/// Formatos de fecha y duración (sin dependencias externas).
String dosDigitos(int n) => n.toString().padLeft(2, '0');

String formatoHora(DateTime f) =>
    '${dosDigitos(f.hour)}:${dosDigitos(f.minute)}';

const _dias = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];

/// "14:05" si es de hoy, "Ayer", el día de la semana o "12/10/2026".
String etiquetaFecha(DateTime f, {DateTime? ahora}) {
  ahora ??= DateTime.now();
  final hoy = DateTime(ahora.year, ahora.month, ahora.day);
  final dia = DateTime(f.year, f.month, f.day);
  final dif = hoy.difference(dia).inDays;
  if (dif <= 0) return formatoHora(f);
  if (dif == 1) return 'Ayer';
  if (dif < 7) return _dias[f.weekday - 1];
  return '${dosDigitos(f.day)}/${dosDigitos(f.month)}/${f.year}';
}

/// "Hoy, 14:05", "Ayer, 09:30"…
String fechaLlamada(DateTime f) {
  final e = etiquetaFecha(f);
  return e.contains(':') ? 'Hoy, $e' : '$e, ${formatoHora(f)}';
}

String formatoDuracion(Duration d) {
  final h = d.inHours;
  final m = dosDigitos(d.inMinutes.remainder(60));
  final s = dosDigitos(d.inSeconds.remainder(60));
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}

/// "5 min 12 s" para el historial.
String duracionLarga(Duration d) {
  if (d.inMinutes == 0) return '${d.inSeconds} s';
  return '${d.inMinutes} min ${d.inSeconds.remainder(60)} s';
}
