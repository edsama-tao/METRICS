import 'package:flutter/material.dart';

class FormularioAbsenciaScreen extends StatefulWidget {
  const FormularioAbsenciaScreen({super.key});

  @override
  State<FormularioAbsenciaScreen> createState() => _FormularioAbsenciaScreenState();
}

class _FormularioAbsenciaScreenState extends State<FormularioAbsenciaScreen> {
  final _formKey = GlobalKey<FormState>();
  String _tipo = 'Alta';
  String? _motiu;
  DateTime? _fecha;
  String? _comentarios;

  final List<String> tipos = ['Alta', 'Baixa'];
  final List<String> motivos = ['Mèdica', 'Personal', 'Altres'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Absencia'),
        backgroundColor: const Color(0xFFD83535),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Tipo
              DropdownButtonFormField<String>(
                value: _tipo,
                decoration: const InputDecoration(labelText: 'Tipus'),
                items: tipos.map((tipo) {
                  return DropdownMenuItem(value: tipo, child: Text(tipo));
                }).toList(),
                onChanged: (value) => setState(() => _tipo = value!),
              ),
              const SizedBox(height: 16),
              // Motiu
              TextFormField(
                decoration: const InputDecoration(labelText: 'Motiu *'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Escriu el motiu' : null,
                onChanged: (value) => _motiu = value,
              ),
              const SizedBox(height: 16),
              // Fecha
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_fecha == null
                    ? 'Selecciona la data'
                    : 'Data: ${_fecha!.toLocal()}'.split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final selected = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (selected != null) {
                    setState(() => _fecha = selected);
                  }
                },
              ),
              const SizedBox(height: 16),
              // Comentarios
              TextFormField(
                decoration: const InputDecoration(labelText: 'Comentaris (opcional)'),
                maxLines: 3,
                onChanged: (value) => _comentarios = value,
              ),
              const SizedBox(height: 24),
              // Botón Guardar
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD83535),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Aquí haces lo que necesites con los datos
                    print('TIPO: $_tipo');
                    print('MOTIU: $_motiu');
                    print('FECHA: $_fecha');
                    print('COMENTARIS: $_comentarios');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Absencia registrada!')),
                    );
                    Navigator.pop(context); // Vuelve atrás
                  }
                },
                child: const Text('GUARDAR', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
