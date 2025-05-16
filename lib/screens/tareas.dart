import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'custom_drawer.dart';
import 'home.dart';
import 'avisos.dart';
import 'formularioabsenciascreen.dart';

class ActividadDiariaScreen extends StatefulWidget {
  final int userId;
  final DateTime fechaSeleccionada;
  final bool soloLectura;

  const ActividadDiariaScreen({
    super.key,
    required this.userId,
    required this.fechaSeleccionada,
    this.soloLectura = false,
  });

  @override
  State<ActividadDiariaScreen> createState() => _ActividadDiariaScreenState();
}

class _ActividadDiariaScreenState extends State<ActividadDiariaScreen> {
  final List<int?> horasSeleccionadas = List.filled(50, null);
  final List<String> actividades = [
    "1.1. Treball sobre diferents sistemes informàtics...",
    "1.2. Gestió de la informació en diferents sistemes...",
    "1.3. Participació en la gestió de recursos en xarxa...",
    "1.4. Utilització d'aplicacions informàtiques...",
    "1.5. Utilització d'entorns de desenvolupament...",
    "1.6. Gestió d'entorns de desenvolupament...",
    "2.1. Interpretació del disseny lògic de bases de dades...",
    "2.2. Participació en la materialització del disseny lògic...",
    "2.3. Utilització de bases de dades...",
    "2.4. Execució de consultes directes...",
    "2.5. Establiment de connexions amb bases de dades...",
    "2.6. Desenvolupament de formularis i informes...",
    "2.8. Elaboració de la documentació associada...",
    "4.1. Participació en el desenvolupament de la interfície...",
    "4.3. Creació de tutorials i manuals d'usuari...",
    "4.4. Creació de paquets d'aplicacions...",
    "4.6. Participació en protocols d'assistència a l'usuari...",
    "5.1. Reconeixement de la funcionalitat dels sistemes ERP-CRM...",
    "5.2. Participació en la instal·lació de sistemes ERP-CRM...",
    "5.3. Valoració del procés d'adaptació ERP-CRM...",
    "5.4. Intervenció en la gestió d'informació ERP-CRM...",
    "5.5. Col·laboració en desenvolupament per ERP-CRM...",
  ];

  Map<String, dynamic>? contratoData;
  bool isLoading = true;

  int get totalHoras => horasSeleccionadas.whereType<int>().fold(0, (a, b) => a + b);

  @override
  void initState() {
    super.initState();
    cargarContrato().then((_) => cargarTareasGuardadas());
  }

  Future<void> cargarContrato() async {
    final url = Uri.parse("http://10.100.0.9/flutter_api/get_contrato_usuario.php");
    try {
      final response = await http.post(url, body: {'id_user': widget.userId.toString()});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          setState(() {
            contratoData = data;
            isLoading = false;
          });
        }
      }
    } catch (_) {}
    setState(() => isLoading = false);
  }

  Future<void> cargarTareasGuardadas() async {
    try {
      final response = await http.post(
        Uri.parse("http://10.100.0.9/flutter_api/get_tareas_fecha.php"),
        body: {
          'id_user': widget.userId.toString(),
          'fecha': widget.fechaSeleccionada.toIso8601String().split('T')[0],
        },
      );

      if (response.statusCode == 200) {
        final datos = json.decode(response.body);
        if (datos is List) {
          for (final tarea in datos) {
            final index = int.parse(tarea['id_tarea'].toString()) - 1;
            final minutos = int.parse(tarea['minutos'].toString());
            if (index >= 0 && index < horasSeleccionadas.length && minutos <= 240) {
              horasSeleccionadas[index] = minutos;
            }
          }
        }
        setState(() {});
      }
    } catch (_) {}
  }

  Future<void> enviarActividades() async {
    final url = Uri.parse("http://10.100.0.9/flutter_api/insertar_tareas.php");
    bool seEnvioAlgo = false;

    try {
      for (int i = 0; i < actividades.length; i++) {
        final minutos = horasSeleccionadas[i];
        if (minutos != null && minutos > 0) {
          seEnvioAlgo = true;
          final response = await http.post(
            url,
            body: {
              'id_user': widget.userId.toString(),
              'id_tarea': (i + 1).toString(),
              'minutos': minutos.toString(),
              'fecha': widget.fechaSeleccionada.toIso8601String().split('T')[0],
            },
          );
          final data = json.decode(response.body);
          if (data["status"] != "success") {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data["message"] ?? "Error desconocido")),
            );
            return;
          }
        }
      }

      if (!seEnvioAlgo) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No has asignado duración a ninguna actividad.")),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Actividades guardadas correctamente")),
      );

      setState(() => horasSeleccionadas.fillRange(0, horasSeleccionadas.length, null));
      Navigator.pop(context, true);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al enviar actividades")),
      );
    }
  }

  Widget buildTareaRow(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(actividades[index])),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: DropdownButtonFormField<int?>(
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              hint: const Text("Duración"),
              value: horasSeleccionadas[index],
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text("")),
                ...List.generate(16, (i) => (i + 1) * 15).map((minutos) {
                  final h = minutos ~/ 60;
                  final m = minutos % 60;
                  final texto = h > 0 ? '${h}h ${m > 0 ? '$m min' : ''}' : '$m min';
                  return DropdownMenuItem(value: minutos, child: Text(texto));
                }),
              ],
              onChanged: widget.soloLectura
                  ? null
                  : (value) {
                      int anterior = horasSeleccionadas[index] ?? 0;
                      int nuevo = value ?? 0;
                      int nuevoTotal = totalHoras - anterior + nuevo;
                      if (nuevoTotal <= 240) {
                        setState(() => horasSeleccionadas[index] = value);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No puedes asignar más de 4 horas.')),
                        );
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }

 Widget buildInfoCard(String title, String content, IconData icon) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
      ],
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.red),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(content),
            ],
          ),
        ),
      ],
    ),
  );
}


  Widget buildDatosAlumno() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text("DATOS DEL ALUMNO", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        buildInfoCard("Nombre", contratoData?['nombre'] ?? '', Icons.person),
        buildInfoCard("Empresa", contratoData?['empresa'] ?? '', Icons.business),
        buildInfoCard("Tutor", contratoData?['tutor'] ?? '', Icons.school),
        buildInfoCard("Estudios", contratoData?['estudios'] ?? '', Icons.menu_book),
        buildInfoCard("Centro Formativo", contratoData?['centroFormativo'] ?? '', Icons.location_city),
        buildInfoCard("Horas Acuerdo", '${contratoData?['horasAcuerdo'] ?? 0} horas', Icons.access_time),
        buildInfoCard("Modalidad", contratoData?['modalidad'] ?? '', Icons.style),
      ],
    );
  }

  Widget buildBoton(String texto, Color color) {
    final bool desactivado = texto == 'ALMACENAR' && totalHoras > 240;
    return ElevatedButton(
      onPressed: desactivado
          ? null
          : () {
              if (texto == 'ALMACENAR') {
                enviarActividades();
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FormularioAbsenciaScreen()),
                );
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      ),
      child: Text(
        texto,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fechaStr = DateFormat('dd/MM/yyyy').format(widget.fechaSeleccionada);
    final mesStr = DateFormat('MMMM dd/MM/yyyy', 'es_ES').format(widget.fechaSeleccionada);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF3C41),
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        centerTitle: true,
        title: SizedBox(
          height: 85,
          child: Image.asset(
            'assets/imagelogo.png',
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : contratoData == null
              ? const Center(child: Text("No se encontró el contrato."))
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  mesStr.toUpperCase(),
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "ACTIVIDAD DÍA $fechaStr",
                                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          ...List.generate(actividades.length, buildTareaRow),
                          const SizedBox(height: 20),
                          if (!widget.soloLectura)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                buildBoton("ABSCENCIA", Colors.red),
                                buildBoton("ALMACENAR", Colors.green),
                              ],
                            ),
                          const SizedBox(height: 30),
                          buildDatosAlumno(),
                        ],
                      ),
                    ),
                  ),
                ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFFF3C41),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: const Icon(Icons.calendar_month, color: Colors.white), onPressed: () => Navigator.pop(context)),
            IconButton(icon: const Icon(Icons.home, color: Colors.white), onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
            }),
            IconButton(icon: const Icon(Icons.mail, color: Colors.white), onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AvisosScreen()));
            }),
          ],
        ),
      ),
    );
  }
}
