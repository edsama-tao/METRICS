import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'custom_drawer.dart';
import 'home.dart';
import 'avisos.dart';

class ActividadDiariaScreen extends StatefulWidget {
  final int userId;

  const ActividadDiariaScreen({super.key, required this.userId});

  @override
  State<ActividadDiariaScreen> createState() => _ActividadDiariaScreenState();
}

class _ActividadDiariaScreenState extends State<ActividadDiariaScreen> {
  final List<int?> horasSeleccionadas = List.filled(8, null);

  Map<String, dynamic>? contratoData;
  bool isLoading = true;

  int get totalHoras => horasSeleccionadas.whereType<int>().fold(0, (a, b) => a + b);

  @override
  void initState() {
    super.initState();
    cargarContrato();
  }

  Future<void> cargarContrato() async {
    final userId = widget.userId;
    final url = Uri.parse("http://10.100.2.169/flutter_api/get_contrato_usuario.php");

    try {
      print('🟨 ID que se va a enviar: ${widget.userId}');
      final response = await http.post(url, body: {'id_user': userId.toString()});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('🧾 Respuesta contrato: $data');
        if (data != null && data is Map<String, dynamic>) {
          setState(() {
            contratoData = data;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error al cargar contrato: \$e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String fechaActual = DateFormat('dd/MM/yyyy').format(DateTime.now());
    final String mesActual = DateFormat('MMMM dd/MM/yyyy', 'es_ES').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF3C41),
        automaticallyImplyLeading: false,
        title: Center(
          child: Transform.scale(
            scale: 1.4,
            child: Image.asset('assets/imagelogo.png', height: 40, fit: BoxFit.contain),
          ),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : contratoData == null
              ? const Center(child: Text("No se encontró el contrato."))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(mesActual.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('ACTIVIDAD DÍA $fechaActual'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...List.generate(8, (index) => buildTareaRow(index)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildBoton('ABSCENCIA', Colors.grey.shade400),
                          buildBoton('ALMACENAR', Colors.grey.shade400),
                        ],
                      ),
                      const SizedBox(height: 30),
                      buildDatosAlumno(
                        contratoData?['nombre'] ?? 'Sin nombre',
                        contratoData?['empresa'] ?? 'Sin empresa',
                        contratoData?['tutor'] ?? 'Sin tutor',
                        contratoData?['estudios'] ?? 'Sin estudios',
                        contratoData?['centroFormativo'] ?? 'Sin centro',
                        '${contratoData?['horasAcuerdo'] ?? 0} horas',
                        contratoData?['modalidad'] ?? 'Desconocida',
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFFF3C41),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.calendar_month, color: Colors.white),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ActividadDiariaScreen(userId: widget.userId)));
              },
            ),
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
              },
            ),
            IconButton(
              icon: const Icon(Icons.mail, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AvisosScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTareaRow(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'ESCRIBE DESCRIPCIÓN...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: DropdownButtonFormField<int?>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
              ),
              hint: const Text("Horas"),
              value: horasSeleccionadas[index],
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text("")),
                ...List.generate(4, (i) => i + 1)
                    .map((e) => DropdownMenuItem(value: e, child: Text('$e h')))
              ],
              onChanged: (value) {
                int anterior = horasSeleccionadas[index] ?? 0;
                int nuevo = value ?? 0;
                int nuevoTotal = totalHoras - anterior + nuevo;

                if (nuevoTotal <= 4) {
                  setState(() {
                    horasSeleccionadas[index] = value;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No puedes asignar más de 4 horas en total.')),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBoton(String texto, Color color) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Text(texto, style: const TextStyle(color: Colors.black)),
    );
  }

  Widget buildDatosAlumno(String nombre, String empresa, String tutor, String estudios, String centroFormativo, String horasAcuerdo, String modalidad) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('DATOS ALUMNO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        _buildInfoRow('Nombre:', nombre),
        _buildInfoRow('Empresa:', empresa),
        _buildInfoRow('Tutor:', tutor),
        _buildInfoRow('Estudios:', estudios),
        _buildInfoRow('Centro Formativo:', centroFormativo),
        _buildInfoRow('Horas Acuerdo:', horasAcuerdo),
        _buildInfoRow('Modalidad:', modalidad),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}