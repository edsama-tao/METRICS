import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'custom_drawer.dart';
import 'home.dart';
import 'avisos.dart';

class FormularioAbsenciaScreen extends StatefulWidget {
  const FormularioAbsenciaScreen({super.key});

  @override
  State<FormularioAbsenciaScreen> createState() => _FormularioAbsenciaScreenState();
}

class _FormularioAbsenciaScreenState extends State<FormularioAbsenciaScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _motiu;
  String? _comentarios;

  final List<String> motivos = [
    'BAIXA MÈDICA (MALALTIA O ACCIDENT COMÚ)',
    'MOTIUS MÈDICS',
    'PERSONALS',
    'PER FORÇA MAJOR',
    'RELACIONAT AMB ELS ESTUDIS',
    'VACANCES ESCOLARS',
    'MOTIVAT PER L\'EMPRESA',
    'FESTIU',
    'ALTRES',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF3C41),
      endDrawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF3C41),
        automaticallyImplyLeading: true,
        elevation: 0,
        title: const SizedBox(),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFFEDEDEE),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Tipus d\'Absència *',
                    filled: true,
                    fillColor: Colors.white70,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                  value: _motiu,
                  items: motivos.map((motiu) {
                    return DropdownMenuItem<String>(
                      value: motiu,
                      child: Text(motiu),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _motiu = value),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Selecciona un motiu' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Comentaris (opcional)',
                    filled: true,
                    fillColor: Colors.white70,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                  maxLines: 3,
                  onChanged: (value) => _comentarios = value,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD83535),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final url = Uri.parse('http://10.0.2.2/flutter_api/registrar_absencia.php');
                        final response = await http.post(
                          url,
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode({
                            'motiu': _motiu,
                            'comentarios': _comentarios ?? '',
                          }),
                        );

                        final result = jsonDecode(response.body);
                        if (result['status'] == 'success') {
                          // Mostrar diálogo y luego ir al Home
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirmació'),
                                content: const Text('L\'absència s\'ha registrat correctament.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );

                          // Navegar al Home después del diálogo
                          if (mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const HomeScreen()),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ${result['message']}')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error de connexió: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('GUARDAR', style: TextStyle(fontSize: 18)),
                ),
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
            IconButton(
              icon: const Icon(Icons.calendar_month, color: Colors.white),
              onPressed: () => Navigator.pop(context),
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
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AvisosScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
