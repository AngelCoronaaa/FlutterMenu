import 'package:flutter/material.dart';

class Persona {
  const Persona({
    required this.id,
    required this.nombre,
    required this.estado,
    required this.telefono,
    required this.color,
    this.enLinea = false,
    this.ultimaVez = '',
  });

  final int id;
  final String nombre;

  /// Frase de estado del perfil.
  final String estado;
  final String telefono;
  final Color color;
  final bool enLinea;

  /// Texto como "hoy a las 9:41" cuando no está en línea.
  final String ultimaVez;

  String get iniciales {
    final partes = nombre.trim().split(RegExp(r'\s+'));
    final primera = partes.first[0];
    return partes.length > 1 ? '$primera${partes.last[0]}' : primera;
  }

  String get conexion => enLinea ? 'En línea' : 'Últ. vez $ultimaVez';
}
