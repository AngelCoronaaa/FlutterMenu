import 'package:flutter/material.dart';

import 'app/mensajeria_controller.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(FlutterMenuApp(controller: MensajeriaController()));
}

class FlutterMenuApp extends StatelessWidget {
  const FlutterMenuApp({super.key, required this.controller});

  final MensajeriaController controller;

  @override
  Widget build(BuildContext context) {
    return MensajeriaScope(
      controller: controller,
      child: Builder(
        // Reconstruye el MaterialApp al cambiar el aspecto.
        builder: (context) => MaterialApp(
          title: 'Flutter Menu',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.claro,
          darkTheme: AppTheme.oscuro,
          themeMode: MensajeriaScope.of(context).themeMode,
          // Los colores del vidrio y del fondo se interpolan en este tiempo.
          themeAnimationDuration: const Duration(milliseconds: 600),
          themeAnimationCurve: Curves.easeInOutCubic,
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
