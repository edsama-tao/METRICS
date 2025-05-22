import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/login.dart';
import 'screens/registro.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Metrics Login',
      debugShowCheckedModeBanner: false,
      locale: const Locale('es', 'ES'),
      supportedLocales: const [Locale('es', 'ES')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,  // Localización para Material
        GlobalWidgetsLocalizations.delegate,   // Localización para Widgets
        GlobalCupertinoLocalizations.delegate, 
      ],
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(), //navegación al registro
      },
    );
  }
}
