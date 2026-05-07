class ChallengeModel {
  final String id;
  final String nome;
  final double? pesoInicial;
  final double? pesoMeta;
  final int metaDiasTreinados;
  final DateTime dataInicio;
  final DateTime dataFim;
  final String status;
  final int diasTreinados;
  final int diasTotais;
  final double progressoPercentual;
  final double? pesoAtual;

  ChallengeModel({
    required this.id,
    required this.nome,
    this.pesoInicial,
    this.pesoMeta,
    required this.metaDiasTreinados,
    required this.dataInicio,
    required this.dataFim,
    required this.status,
    required this.diasTreinados,
    required this.diasTotais,
    required this.progressoPercentual,
    this.pesoAtual,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) => ChallengeModel(
        id: json['id'],
        nome: json['nome'],
        pesoInicial: json['pesoInicial']?.toDouble(),
        pesoMeta: json['pesoMeta']?.toDouble(),
        metaDiasTreinados: json['metaDiasTreinados'],
        dataInicio: DateTime.parse(json['dataInicio']),
        dataFim: DateTime.parse(json['dataFim']),
        status: json['status'],
        diasTreinados: json['diasTreinados'],
        diasTotais: json['diasTotais'],
        progressoPercentual: json['progressoPercentual'].toDouble(),
        pesoAtual: json['pesoAtual']?.toDouble(),
      );
}
