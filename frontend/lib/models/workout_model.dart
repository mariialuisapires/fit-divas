class ExerciseModel {
  final String id;
  final String nome;
  final int series;
  final int repeticoes;
  final double? carga;
  final String? observacoes;
  final int ordem;

  ExerciseModel({
    required this.id,
    required this.nome,
    required this.series,
    required this.repeticoes,
    this.carga,
    this.observacoes,
    required this.ordem,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) => ExerciseModel(
        id: json['id'],
        nome: json['nome'],
        series: json['series'],
        repeticoes: json['repeticoes'],
        carga: json['carga']?.toDouble(),
        observacoes: json['observacoes'],
        ordem: json['ordem'],
      );

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'series': series,
        'repeticoes': repeticoes,
        'carga': carga,
        'observacoes': observacoes,
        'ordem': ordem,
      };
}

class WorkoutModel {
  final String id;
  final String nome;
  final String? observacoes;
  final String? diaSemana;
  final DateTime criadoEm;
  final List<ExerciseModel> exercicios;

  WorkoutModel({
    required this.id,
    required this.nome,
    this.observacoes,
    this.diaSemana,
    required this.criadoEm,
    required this.exercicios,
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) => WorkoutModel(
        id: json['id'],
        nome: json['nome'],
        observacoes: json['observacoes'],
        diaSemana: json['diaSemana'],
        criadoEm: DateTime.parse(json['criadoEm']),
        exercicios: (json['exercicios'] as List)
            .map((e) => ExerciseModel.fromJson(e))
            .toList(),
      );
}
