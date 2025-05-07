import 'package:flutter/material.dart';
import 'package:metrics/screens/global.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'custom_drawer.dart';
import 'avisos.dart';
import 'tareas.dart'; // ActividadDiariaScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, bool> completedDays = {};

  @override
  void initState() {
    super.initState();
    cargarDiasCompletados();
  }

  Future<void> cargarDiasCompletados() async {
    final response = await http.post(
      Uri.parse('http://10.100.0.9/flutter_api/get_dias_completados.php'),
      body: {'id_user': globalUserId.toString()},
    );

    if (response.statusCode == 200) {
      final List fechas = json.decode(response.body);

      print("🔄 Fechas recibidas del backend:");
      for (final fecha in fechas) {
        print("- $fecha");
      }

      setState(() {
        completedDays.clear();
        for (final fecha in fechas) {
          final date = DateTime.parse(fecha);
          final soloFecha = DateTime(date.year, date.month, date.day);
          print("✅ Marcando como completado: $soloFecha");
          completedDays[soloFecha] = true;
        }
      });
    } else {
      print(
        "❌ Error al cargar días completados. Código: ${response.statusCode}",
      );
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const CustomDrawer(),
      backgroundColor: const Color(0xFFF2F2F2),
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: TableCalendar(
              locale: 'es_ES',
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2026, 12, 31),
              calendarFormat: CalendarFormat.month,
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
              onDaySelected: (selectedDay, focusedDay) {
                final esHoy = _isSameDay(selectedDay, DateTime.now());

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ActividadDiariaScreen(
                          userId: globalUserId,
                          fechaSeleccionada: selectedDay,
                          soloLectura:
                              !esHoy, // 👈 Solo permite editar si es hoy
                        ),
                  ),
                ).then((value) {
                  if (esHoy && value == true) {
                    cargarDiasCompletados(); // 🔄 Refresca los días tras volver si era hoy
                  }
                });
              },
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
              ),

              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.redAccent, // ⬅️ Día actual en rojo como antes
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(color: Colors.transparent),
              ),

              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, _) {
                  final isWeekend =
                      day.weekday == DateTime.saturday ||
                      day.weekday == DateTime.sunday;
                  final isPastOrToday = !day.isAfter(DateTime.now());
                  final isToday = _isSameDay(day, DateTime.now());
                  final dayKey = DateTime(day.year, day.month, day.day);
                  final isCompleted = completedDays[dayKey] ?? false;

                  // Día actual se marca en rojo por defecto
                  if (isToday) return null;

                  Color? bgColor;

                  if (isCompleted) {
                    bgColor = Colors.green;
                  } else if (!isWeekend && isPastOrToday) {
                    bgColor = Colors.orange;
                  }

                  if (bgColor != null) {
                    return Container(
                      margin: const EdgeInsets.all(6),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }

                  return null;
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFFF3C41),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.calendar_month, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ActividadDiariaScreen(
                          userId: globalUserId,
                          fechaSeleccionada: DateTime.now(),
                        ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {},
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
}
