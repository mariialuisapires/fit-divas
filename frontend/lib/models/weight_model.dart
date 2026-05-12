class WeightProgressItem {
  final String id;
  final double peso;
  final DateTime dataRegistro;

  WeightProgressItem({
    required this.id,
    required this.peso,
    required this.dataRegistro,
  });

  factory WeightProgressItem.fromJson(Map<String, dynamic> json) => WeightProgressItem(
        id: json['id'],
        peso: json['peso'].toDouble(),
        dataRegistro: DateTime.parse(json['dataRegistro']).toLocal(),
      );
}

class WeightSummary {
  final double? pesoInicial;
  final double? pesoAtual;
  final double? pesoMeta;
  final double? diferenca;
  final List<WeightProgressItem> historico;

  WeightSummary({
    this.pesoInicial,
    this.pesoAtual,
    this.pesoMeta,
    this.diferenca,
    required this.historico,
  });

  factory WeightSummary.fromJson(Map<String, dynamic> json) => WeightSummary(
        pesoInicial: json['pesoInicial']?.toDouble(),
        pesoAtual: json['pesoAtual']?.toDouble(),
        pesoMeta: json['pesoMeta']?.toDouble(),
        diferenca: json['diferenca']?.toDouble(),
        historico: (json['historico'] as List)
            .map((e) => WeightProgressItem.fromJson(e))
            .toList(),
      );
}
