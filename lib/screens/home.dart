import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'login.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const CustomDrawer(), // 🟢 Menú ahora se abre desde la derecha
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF3C41),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            );
          },
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(), // 🟢 Abre desde la derecha
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Buscar Usuario",
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _buildCalendar(),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFFF3C41),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Icon(Icons.calendar_month, color: Colors.white),
            Icon(Icons.home, color: Colors.white),
            Icon(Icons.mail, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      focusedDay: DateTime.now(),
      firstDay: DateTime.utc(2024, 1, 1),
      lastDay: DateTime.utc(2026, 12, 31),
      calendarFormat: CalendarFormat.month,
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.redAccent,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.blueAccent,
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.rectangle,
        ),
      ),
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        titleTextFormatter: (date, locale) => 'MARZO DE 2025',
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, _) {
          if (day.month == 3 && [24, 25, 26, 27, 28].contains(day.day)) {
            return _buildDayWithLabel(day, day.day <= 28 ? "Activ" : "Infor", day.day <= 28 ? Colors.green : Colors.blue);
          } else if (day.month == 3 && [10, 11, 12, 13, 14].contains(day.day)) {
            return _buildDayWithLabel(day, "Activ", Colors.green);
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDayWithLabel(DateTime day, String label, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('${day.day}'),
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ),
      ],
    );
  }
}

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFFF3C41),
      child: Column(
        children: [
          const SizedBox(height: 100),
          _buildDrawerButton("Perfil", Icons.person, () {
            // Aquí podrías navegar a la pantalla de perfil
          }, context),
          _buildDrawerButton("Importar/Exportar", Icons.import_export, () {
            // Función de importar/exportar
          }, context),
          _buildDrawerButton("Cerrar Sesión", Icons.logout, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }, context),
        ],
      ),
    );
  }

  Widget _buildDrawerButton(String text, IconData icon, VoidCallback onTap, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(
          text,
          style: const TextStyle(color: Colors.black),
        ),
        onTap: () {
          Navigator.of(context).pop(); // 🟢 Cierra el drawer antes de ejecutar
          onTap();
        },
      ),
    );
  }
}
