import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'custom_drawer.dart';
import 'home.dart';
import 'avisos.dart';

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
    "1.1. Treball sobre diferents sistemes informàtics, identificant en cada cas el seu maquinari, sistemes operatius i aplicacions instal·lades i les restriccions o condicions específiques d'ús.",
    "1.2. Gestió de la informació en diferents sistemes, aplicant mesures que assegurin la integritat i disponibilitat de les dades.",
    "1.3. Participació en la gestió de recursos en xarxa identificant les restriccions de seguretat existents.",
    "1.4. Utilització d'aplicacions informàtiques per elaborar, distribuir i mantenir documentació tècnica i d'assistència a usuaris.",
    "1.5. Utilització d'entorns de desenvolupament per a editar, depurar, provar i documentar codi, a més de generar executables.",
    "1.6. Gestió d'entorns de desenvolupament, afegint i emprant complements específics en les diferents fases de projectes de desenvolupament.",
    "2.1. Interpretació del disseny lògic de bases de dades que asseguren l'accessibilitat a les dades.",
    "2.2. Participació en la materialització del disseny lògic sobre algun sistema gestor de bases de dades.",
    "2.3. Utilització de bases de dades aplicant tècniques per mantenir la persistència de la informació.",
    "2.4. Execució de consultes directes i procediments capaços de gestionar i emmagatzemar objectes i dades de la base de dades.",
    "2.5. Establiment de connexions amb bases de dades per executar consultes i recuperar els resultats en objectes d'accés a dades.",
    "2.6. Desenvolupament de formularis i informes com a part d'aplicacions que gestionen de forma integral la informació emmagatzemada en una base de dades.",
    "2.8. Elaboració de la documentació associada a la gestió de les bases de dades emprades i les aplicacions desenvolupades.",
    "4.1. Participació en el desenvolupament de la interfície per a aplicacions multiplataforma emprant components visuals estàndard o definint components personalitzats.",
    "4.3. Creació de tutorials i manuals d'usuari, d'instal·lació i de configuració de les aplicacions desenvolupades.",
    "4.4. Creació de paquets d'aplicacions per a la seva distribució amb processos d'autoinstal·lació i amb tots els elements d'ajuda i assistència incorporats.",
    "4.6. Participació en la definició i l'elaboració de la documentació i de la resta de components utilitzats en els protocols d'assistència a l'usuari de l'aplicació.",
    "5.1. Reconeixement de la funcionalitat dels sistemes ERP-CRM en un supòsit empresarial real, avaluant la utilitat de cada un dels seus mòduls.",
    "5.2. Participació en la instal·lació i configuració de sistemes ERP-CRM.",
    "5.3. Valoració i anàlisi del procés d'adaptació d'un sistema ERP-CRM als requeriments d'un supòsit empresarial real.",
    "5.4. Intervenció en la gestió de la informació emmagatzemada en sistemes ERP-CRM, garantint-ne la integritat.",
    "5.5. Col·laboració en el desenvolupament de components personalitzats per a un sistema ERP-CRM, utilitzant el llenguatge de programació proporcionat pel sistema.",
  ];

  Map<String, dynamic>? contratoData;
  bool isLoading = true;

  int get totalHoras =>
      horasSeleccionadas.whereType<int>().fold(0, (a, b) => a + b);

  @override
  void initState() {
    super.initState();
    cargarContrato().then((_) {
      cargarTareasGuardadas();
    });
  }

  Future<void> cargarContrato() async {
    final userId = widget.userId;
    final url = Uri.parse(
      "http://localhost/flutter_api/get_contrato_usuario.php",
    );

    try {
      final response = await http.post(
        url,
        body: {'id_user': userId.toString()},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data is Map<String, dynamic>) {
          setState(() {
            contratoData = data;
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
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

      print("📥 Respuesta tareas: ${response.body}");

      if (response.statusCode == 200) {
        final datos = json.decode(response.body);
        if (datos is List) {
          for (final tarea in datos) {
            final index = int.parse(tarea['id_tarea'].toString()) - 1;
            final minutos = int.parse(tarea['minutos'].toString());

            // Validar que los minutos estén entre los permitidos (de 15 en 15 hasta 240)
            if (index >= 0 &&
                index < horasSeleccionadas.length &&
                [
                  15,
                  30,
                  45,
                  60,
                  75,
                  90,
                  105,
                  120,
                  135,
                  150,
                  165,
                  180,
                  195,
                  210,
                  225,
                  240,
                ].contains(minutos)) {
              horasSeleccionadas[index] = minutos;
            } else {
              print(
                "⚠️ Valor inválido para minutos o índice fuera de rango: tarea ${index + 1}, minutos: $minutos",
              );
            }
          }
        } else {
          print("⚠️ El backend no devolvió una lista: $datos");
        }

        setState(() {}); // Solo si todo va bien
      } else {
        print("❌ Error HTTP al cargar tareas (${response.statusCode})");
      }
    } catch (e) {
      print("❌ Excepción en cargarTareasGuardadas: $e");
    }
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

          print("📤 Enviando tarea ${(i + 1)}: $minutos min");
          print("📥 Respuesta: ${response.body}");

          final data = json.decode(response.body);
          final String mensaje =
              data["message"]?.toString() ?? "Error desconocido";

          if (data["status"] != "success") {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(mensaje)));
            return;
          }
        }
      }

      if (!seEnvioAlgo) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No has asignado duración a ninguna actividad."),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Actividades guardadas correctamente")),
      );

      setState(() {
        for (int i = 0; i < horasSeleccionadas.length; i++) {
          horasSeleccionadas[i] = null;
        }
      });

      Navigator.pop(context, true);
    } catch (e) {
      print("❌ Error inesperado en enviarActividades: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al enviar actividades")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String fechaStr = DateFormat(
      'dd/MM/yyyy',
    ).format(widget.fechaSeleccionada);
    final String mesActual = DateFormat(
      'MMMM dd/MM/yyyy',
      'es_ES',
    ).format(widget.fechaSeleccionada);

    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF3C41),
        automaticallyImplyLeading: false,
        title: Center(
          child: Transform.scale(
            scale: 1.4,
            child: Image.asset(
              'assets/imagelogo.png',
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
        ),
        actions: [
          Builder(
            builder:
                (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
          ),
        ],
      ),
      body:
          isLoading
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
                          Text(
                            mesActual.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text('ACTIVIDAD DÍA $fechaStr'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...List.generate(
                      actividades.length,
                      (index) => buildTareaRow(index),
                    ),
                    const SizedBox(height: 10),
                    if (!widget.soloLectura)
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
                Navigator.pop(context); // volver al calendario
              },
            ),
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.mail, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AvisosScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTareaRow(int index) {
    return SizedBox(
      height: 55,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  actividades.length > index
                      ? actividades[index]
                      : "Actividad no definida",
                  style: const TextStyle(fontSize: 14),
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
                hint: const Text("Duración"),
                value: horasSeleccionadas[index],
                items: [
                  const DropdownMenuItem<int?>(value: null, child: Text("")),
                  ...List.generate(16, (i) => (i + 1) * 15).map((minutos) {
                    final horas = minutos ~/ 60;
                    final mins = minutos % 60;
                    String texto;
                    if (horas > 0 && mins > 0) {
                      texto = '${horas}h ${mins}min';
                    } else if (horas > 0) {
                      texto = '${horas}h';
                    } else {
                      texto = '${mins}min';
                    }
                    return DropdownMenuItem(value: minutos, child: Text(texto));
                  }).toList(),
                ],
                onChanged:
                    widget.soloLectura
                        ? null
                        : (value) {
                          int anterior = horasSeleccionadas[index] ?? 0;
                          int nuevo = value ?? 0;
                          int nuevoTotal = totalHoras - anterior + nuevo;

                          if (nuevoTotal <= 240) {
                            setState(() {
                              horasSeleccionadas[index] = value;
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'No puedes asignar más de 4 horas en total.',
                                ),
                              ),
                            );
                          }
                        },
              ),
            ),
          ],
        ),
      ),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Funcionalidad no implementada"),
                ),
              );
            }
          },
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
    child: Text(
      texto,
      style: TextStyle(
        color: desactivado ? Colors.black45 : Colors.black,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

  Widget buildDatosAlumno(
    String nombre,
    String empresa,
    String tutor,
    String estudios,
    String centroFormativo,
    String horasAcuerdo,
    String modalidad,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DATOS ALUMNO',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
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
