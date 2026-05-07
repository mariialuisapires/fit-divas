class CalendarDay {
  final DateTime data;
  final bool treinado;
  final List<String> treinosRealizados;

  CalendarDay({
    required this.data,
    required this.treinado,
    required this.treinosRealizados,
  });

  factory CalendarDay.fromJson(Map<String, dynamic> json) => CalendarDay(
        data: DateTime.parse(json['data']),
        treinado: json['treinado'],
        treinosRealizados: List<String>.from(json['treinosRealizados']),
      );
}

class CalendarMonth {
  final int ano;
  final int mes;
  final int totalDiasTreinados;
  final List<CalendarDay> dias;

  CalendarMonth({
    required this.ano,
    required this.mes,
    required this.totalDiasTreinados,
    required this.dias,
  });

  factory CalendarMonth.fromJson(Map<String, dynamic> json) => CalendarMonth(
        ano: json['ano'],
        mes: json['mes'],
        totalDiasTreinados: json['totalDiasTreinados'],
        dias: (json['dias'] as List).map((d) => CalendarDay.fromJson(d)).toList(),
      );
}
