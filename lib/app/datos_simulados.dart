import 'package:flutter/material.dart';

import '../models/llamada.dart';
import '../models/mensaje.dart';
import '../models/persona.dart';

/// Datos de ejemplo: contactos, conversaciones y llamadas ficticias.
const _personasBase = [
  (1, 'Ana García', 'Disponible', '+52 55 1234 0001', 0xFF4C8DFF, true, ''),
  (
    2,
    'Andrés Molina',
    'En el trabajo',
    '+52 55 1234 0002',
    0xFF8A4DFF,
    false,
    'hoy a las 9:41',
  ),
  (
    3,
    'Beatriz Soto',
    '☕ Café primero',
    '+52 55 1234 0003',
    0xFFFF5C9A,
    true,
    '',
  ),
  (
    4,
    'Carlos Ruiz',
    'Solo emergencias',
    '+52 55 1234 0004',
    0xFF34C77B,
    false,
    'ayer a las 22:10',
  ),
  (5, 'Carmen Vega', 'De viaje ✈️', '+52 55 1234 0005', 0xFFFF9F43, true, ''),
  (
    6,
    'Daniel Torres',
    'Ocupado',
    '+52 55 1234 0006',
    0xFF2BB5C9,
    false,
    'hoy a las 8:05',
  ),
  (7, 'Elena Navarro', 'Leyendo 📚', '+52 55 1234 0007', 0xFFE0559B, true, ''),
  (
    8,
    'Fernando Díaz',
    'Hey there! Uso la app',
    '+52 55 1234 0008',
    0xFF5B6CFF,
    false,
    'ayer a las 18:30',
  ),
  (
    9,
    'Gabriela Luna',
    'Música todo el día 🎧',
    '+52 55 1234 0009',
    0xFFB86BFF,
    true,
    '',
  ),
  (
    10,
    'Héctor Ramos',
    'En el gimnasio',
    '+52 55 1234 0010',
    0xFFFF6B5E,
    false,
    'hoy a las 7:15',
  ),
  (11, 'Isabel Cruz', 'Disponible', '+52 55 1234 0011', 0xFF3FB68B, true, ''),
  (
    12,
    'Javier Ortega',
    'No molestar',
    '+52 55 1234 0012',
    0xFF4C8DFF,
    false,
    'lun a las 20:44',
  ),
  (
    13,
    'Laura Méndez',
    '🌱 Un día a la vez',
    '+52 55 1234 0013',
    0xFFFF8FB8,
    true,
    '',
  ),
  (
    14,
    'Miguel Herrera',
    'En reunión',
    '+52 55 1234 0014',
    0xFF8A4DFF,
    false,
    'hoy a las 10:02',
  ),
  (
    15,
    'Natalia Paredes',
    'Disponible',
    '+52 55 1234 0015',
    0xFF2BB5C9,
    false,
    'ayer a las 12:20',
  ),
  (
    16,
    'Óscar Fuentes',
    'Dormido 😴',
    '+52 55 1234 0016',
    0xFFFF9F43,
    false,
    'hoy a las 1:12',
  ),
  (
    17,
    'Paula Rivas',
    'Hablemos por aquí',
    '+52 55 1234 0017',
    0xFFE0559B,
    true,
    '',
  ),
  (
    18,
    'Ricardo Salas',
    'Trabajando desde casa',
    '+52 55 1234 0018',
    0xFF34C77B,
    false,
    'mar a las 16:00',
  ),
];

List<Persona> personasSimuladas() => [
  for (final (id, nombre, estado, tel, color, linea, vez) in _personasBase)
    Persona(
      id: id,
      nombre: nombre,
      estado: estado,
      telefono: tel,
      color: Color(color),
      enLinea: linea,
      ultimaVez: vez,
    ),
];

List<Conversacion> conversacionesSimuladas(List<Persona> p, DateTime ahora) {
  Mensaje m(String t, bool mio, Duration atras) =>
      Mensaje(texto: t, esMio: mio, hora: ahora.subtract(atras));

  return [
    Conversacion(
      persona: p[0],
      noLeidos: 2,
      mensajes: [
        m(
          'Hola Ana, ¿cómo vas con el proyecto?',
          true,
          const Duration(hours: 3),
        ),
        m(
          '¡Muy bien! Ya casi termino la maqueta',
          false,
          const Duration(hours: 2, minutes: 50),
        ),
        m('¿Nos vemos para revisarla hoy?', false, const Duration(minutes: 12)),
        m('Tengo algo que enseñarte 👀', false, const Duration(minutes: 11)),
      ],
    ),
    Conversacion(
      persona: p[2],
      mensajes: [
        m('¿Vamos por un café?', false, const Duration(hours: 5)),
        m(
          'Claro, a las 5 en el lugar de siempre',
          true,
          const Duration(hours: 4, minutes: 40),
        ),
        m('Perfecto ☕', false, const Duration(hours: 4, minutes: 38)),
      ],
    ),
    Conversacion(
      persona: p[6],
      noLeidos: 1,
      mensajes: [
        m('Te recomiendo mucho ese libro', false, const Duration(hours: 22)),
        m('Lo anoto, gracias Elena', true, const Duration(hours: 21)),
        m(
          'Ya van 100 páginas, ¡no puedo parar!',
          false,
          const Duration(hours: 1, minutes: 30),
        ),
      ],
    ),
    Conversacion(
      persona: p[3],
      mensajes: [
        m(
          'Carlos, ¿ya enviaste el reporte?',
          true,
          const Duration(days: 1, hours: 3),
        ),
        m('Sí, está en tu correo', false, const Duration(days: 1, hours: 2)),
        m('Recibido, gracias 🙌', true, const Duration(days: 1, hours: 2)),
      ],
    ),
    Conversacion(
      persona: p[8],
      mensajes: [
        m('Te paso la lista de canciones', false, const Duration(days: 2)),
        m('¡Genial! La escucho en el camino', true, const Duration(days: 2)),
      ],
    ),
    Conversacion(
      persona: p[13],
      mensajes: [
        m('La reunión se movió a las 4', false, const Duration(days: 4)),
        m('Ok, ahí estaré', true, const Duration(days: 4)),
      ],
    ),
    Conversacion(
      persona: p[16],
      noLeidos: 3,
      mensajes: [
        m('Hola 👋', false, const Duration(days: 9)),
        m('¿Sigues por ahí?', false, const Duration(days: 9)),
        m('Avísame cuando puedas hablar', false, const Duration(days: 9)),
      ],
    ),
  ];
}

List<Llamada> llamadasSimuladas(List<Persona> p, DateTime ahora) {
  Llamada l(
    int id,
    int idx,
    TipoLlamada t,
    Duration atras, {
    bool video = false,
    int segundos = 0,
  }) => Llamada(
    id: id,
    persona: p[idx],
    tipo: t,
    fecha: ahora.subtract(atras),
    video: video,
    duracion: Duration(seconds: segundos),
    vista: t != TipoLlamada.perdida || atras > const Duration(hours: 12),
  );

  return [
    l(1, 0, TipoLlamada.perdida, const Duration(minutes: 25)),
    l(2, 2, TipoLlamada.saliente, const Duration(hours: 2), segundos: 312),
    l(
      3,
      6,
      TipoLlamada.entrante,
      const Duration(hours: 5),
      video: true,
      segundos: 1260,
    ),
    l(4, 3, TipoLlamada.perdida, const Duration(hours: 20)),
    l(
      5,
      8,
      TipoLlamada.entrante,
      const Duration(days: 1, hours: 2),
      segundos: 95,
    ),
    l(
      6,
      13,
      TipoLlamada.saliente,
      const Duration(days: 1, hours: 6),
      video: true,
      segundos: 640,
    ),
    l(7, 10, TipoLlamada.saliente, const Duration(days: 2), segundos: 48),
    l(8, 4, TipoLlamada.perdida, const Duration(days: 3), video: true),
    l(9, 16, TipoLlamada.entrante, const Duration(days: 5), segundos: 2210),
    l(10, 1, TipoLlamada.saliente, const Duration(days: 8), segundos: 20),
  ];
}

/// Respuestas que usa el contacto simulado al recibir un mensaje.
const respuestasSimuladas = [
  '¡Claro! 😊',
  'Déjame ver y te confirmo',
  'Jajaja, me parece genial',
  'Perfecto, quedamos así',
  'Ahora mismo estoy ocupado, te escribo en un rato',
  '¿En serio? Cuéntame más',
  'Gracias por avisar 🙌',
  'Me encanta la idea',
  'Buen plan, cuenta conmigo 👍',
  'Ok, hablamos luego',
];
