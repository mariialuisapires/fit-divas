import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/calendar_provider.dart';
import '../../models/calendar_model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CalendarProvider>().loadMonth();
    });
  }

  Set<DateTime> _getTrainedDays(List<CalendarDay> days) =>
      days.where((d) => d.treinado).map((d) => DateTime(d.data.year, d.data.month, d.data.day)).toSet();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalendarProvider>();
    final month = provider.currentMonth;
    final trainedDays = month != null ? _getTrainedDays(month.dias) : <DateTime>{};

    return Scaffold(
      appBar: AppBar(title: const Text('Calendário de Treinos')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                if (month != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.fitness_center, color: Color(0xFFE91E8C)),
                            const SizedBox(width: 8),
                            Text(
                              '${month.totalDiasTreinados} dias treinados este mês',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                TableCalendar(
                  firstDay: DateTime.now().subtract(const Duration(days: 365)),
                  lastDay: DateTime.now(),
                  focusedDay: _focusedDay,
                  calendarFormat: CalendarFormat.month,
                  headerStyle: const HeaderStyle(formatButtonVisible: false),
                  onPageChanged: (day) {
                    setState(() => _focusedDay = day);
                    context.read<CalendarProvider>().loadMonth(year: day.year, month: day.month);
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      final normalized = DateTime(day.year, day.month, day.day);
                      if (trainedDays.contains(normalized)) {
                        return Container(
                          margin: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Color(0xFFE91E8C), shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: Text('${day.day}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        );
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
