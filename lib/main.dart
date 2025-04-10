import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/login.dart';  // Asegúrate de tener la ruta correcta

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null); // Inicializa localización para intl
  runApp(const MyApp());  // Usa MyApp como widget principal
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Metrics Login',
      debugShowCheckedModeBanner: false,
      locale: const Locale('es', 'ES'), // Configuración del idioma español
      supportedLocales: const [Locale('es', 'ES')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,  // Localización de Material
        GlobalWidgetsLocalizations.delegate,   // Localización de Widgets
        GlobalCupertinoLocalizations.delegate // Localización de Cupertino (si usas elementos iOS)
      ],
      home: const LoginScreen(), // Pantalla de inicio de sesión
    );
  }
}
