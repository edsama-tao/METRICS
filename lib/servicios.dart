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
      theme: ThemeData(primarySwatch: Colors.blue),
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

  //obtener los usuarios desde el servidor PHP
  Future<void> obtenerUsuarios() async {
    final url = Uri.parse("http://10.100.2.169/flutter_api/get_usuarios.php");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      try {
        final decoded = jsonDecode(response.body);
        setState(() {
          usuarios = decoded;
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
      print("Error al obtener usuarios. Status code: ${response.statusCode}");
      setState(() {
        cargando = false;
      });
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
                        title: Text('${usuario['nombre'] ?? 'Sin nombre'} ${usuario['apellidos'] ?? ''}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Usuario: ${usuario['nombreUsuario'] ?? 'N/A'}"),
                            Text("Correo: ${usuario['correo'] ?? 'N/A'}"),
                            Text("Teléfono: ${usuario['telefono'] ?? 'N/A'}"),
                            Text("Nacimiento: ${usuario['fechaNacimiento'] ?? 'N/A'}"),
                            Text("Rol: ${usuario['tipoUser'] ?? 'N/A'}"),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                    );
                  },
                ),
    );
  }
}