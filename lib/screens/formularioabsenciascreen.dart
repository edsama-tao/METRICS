import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'custom_drawer.dart';
import 'home.dart';
import 'avisos.dart';
import 'package:metrics/screens/global.dart';

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
      drawer: const CustomDrawer(),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
          child: Image.asset('assets/imagelogo.png', fit: BoxFit.contain),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      'REGISTRE D\'ABSÈNCIA',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                    ),
                    const SizedBox(height: 30),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'TIPUS D\'ABSÈNCIA *',
                        prefixIcon: const Icon(Icons.list),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 255, 255, 255),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      value: _motiu,
                      items: motivos.map((motiu) {
                        return DropdownMenuItem<String>(
                          value: motiu,
                          child: Text(motiu, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _motiu = value),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Selecciona un motiu' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'COMENTARIS (OPCIONAL)',
                        prefixIcon: const Icon(Icons.comment),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 255, 255, 255),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      maxLines: 3,
                      onChanged: (value) => _comentarios = value,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD83535),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              final url = Uri.parse('http://10.100.101.46/flutter_api/registrar_absencia.php');
                              final response = await http.post(
                                url,
                                headers: {'Content-Type': 'application/json'},
                                body: jsonEncode({
                                  'id_user': globalUserId,
                                  'motiu': _motiu,
                                  'comentarios': _comentarios ?? '',
                                }),
                              );

                              final result = jsonDecode(response.body);
                              if (result['status'] == 'success') {
                                await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Confirmació'),
                                      content: const Text('L\'absència s\'ha registrat correctament.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );

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
                        label: const Text('GUARDAR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color:Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
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
