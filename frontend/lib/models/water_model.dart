class WaterHistoryItem {
  final String id;
  final int quantidadeMl;
  final DateTime dataRegistro;

  WaterHistoryItem({
    required this.id,
    required this.quantidadeMl,
    required this.dataRegistro,
  });

  factory WaterHistoryItem.fromJson(Map<String, dynamic> json) => WaterHistoryItem(
        id: json['id'],
        quantidadeMl: json['quantidadeMl'],
        dataRegistro: DateTime.parse(json['dataRegistro']).toLocal(),
      );
}

class WaterSummary {
  final int totalMlHoje;
  final int metaDiariaMl;
  final double percentualAtingido;
  final bool metaAtingida;
  final List<WaterHistoryItem> registrosHoje;

  WaterSummary({
    required this.totalMlHoje,
    required this.metaDiariaMl,
    required this.percentualAtingido,
    required this.metaAtingida,
    required this.registrosHoje,
  });

  factory WaterSummary.fromJson(Map<String, dynamic> json) => WaterSummary(
        totalMlHoje: json['totalMlHoje'],
        metaDiariaMl: json['metaDiariaMl'],
        percentualAtingido: json['percentualAtingido'].toDouble(),
        metaAtingida: json['metaAtingida'],
        registrosHoje: (json['registrosHoje'] as List)
            .map((e) => WaterHistoryItem.fromJson(e))
            .toList(),
      );
}

class WaterMonthlyItem {
  final DateTime data;
  final int totalMl;
  final int metaMl;
  final bool metaAtingida;

  WaterMonthlyItem({
    required this.data,
    required this.totalMl,
    required this.metaMl,
    required this.metaAtingida,
  });

  factory WaterMonthlyItem.fromJson(Map<String, dynamic> json) => WaterMonthlyItem(
        data: DateTime.parse(json['data']).toLocal(),
        totalMl: json['totalMl'],
        metaMl: json['metaMl'],
        metaAtingida: json['metaAtingida'],
      );
}
