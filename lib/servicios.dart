import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Usuarios',
      home: UsuariosPage(),
    );
  }
}

class UsuariosPage extends StatefulWidget {
  @override
  _UsuariosPageState createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  List<dynamic> usuarios = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    obtenerUsuarios();
  }

  // Función para obtener los usuarios desde el servidor PHP
  Future<void> obtenerUsuarios() async {
    final url = Uri.parse("http://10.100.0.51/flutter_api/get_usuarios.php");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      print("Respuesta: ${response.body}");
      try {
        setState(() {
          usuarios = jsonDecode(response.body);
          cargando = false;
        });
        print("Usuarios cargados: $usuarios");
      } catch (e) {
        print("Error al convertir la respuesta a JSON: $e");
        setState(() {
          cargando = false;
        });
      }
    } else {
      setState(() {
        cargando = false;
      });
      print("Error al obtener usuarios. Status code: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lista de Usuarios")),
      body: cargando
          ? Center(child: CircularProgressIndicator())
          : usuarios.isEmpty
              ? Center(child: Text("No hay usuarios"))
              : ListView.builder(
                  itemCount: usuarios.length,
                  itemBuilder: (context, index) {
                    final usuario = usuarios[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: ListTile(
                        leading: Icon(Icons.person),
                        title: Text(usuario['usuario'] ?? 'Sin nombre'),
                        subtitle: Text("Rol: ${usuario['rol'] ?? 'Sin rol'}"),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                    );
                  },
                ),
    );
  }
}
