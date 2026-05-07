import 'weight_model.dart';

class WeightGoalModel {
  final String id;
  final double pesoInicial;
  final double pesoMeta;
  final String tipo; // "perda" | "ganho"
  final DateTime dataInicio;
  final DateTime dataFim;
  final String status;
  final double? ultimoPeso;
  final double? diferencaAtual;
  final List<WeightProgressItem> progressos;

  WeightGoalModel({
    required this.id,
    required this.pesoInicial,
    required this.pesoMeta,
    required this.tipo,
    required this.dataInicio,
    required this.dataFim,
    required this.status,
    this.ultimoPeso,
    this.diferencaAtual,
    required this.progressos,
  });

  factory WeightGoalModel.fromJson(Map<String, dynamic> json) => WeightGoalModel(
        id: json['id'],
        pesoInicial: (json['pesoInicial'] as num).toDouble(),
        pesoMeta: (json['pesoMeta'] as num).toDouble(),
        tipo: json['tipo'],
        dataInicio: DateTime.parse(json['dataInicio']),
        dataFim: DateTime.parse(json['dataFim']),
        status: json['status'],
        ultimoPeso: json['ultimoPeso'] != null ? (json['ultimoPeso'] as num).toDouble() : null,
        diferencaAtual: json['diferencaAtual'] != null ? (json['diferencaAtual'] as num).toDouble() : null,
        progressos: (json['progressos'] as List).map((p) => WeightProgressItem.fromJson(p)).toList(),
      );

  bool get isPerda => tipo == 'perda';
  String get tipoLabel => isPerda ? 'Meta de Perda de Peso' : 'Meta de Ganho de Peso';

  // Peso que deveria estar registrado hoje, interpolando linearmente de pesoInicial → pesoMeta
  double get pesoEsperadoHoje {
    final totalDays = dataFim.difference(dataInicio).inDays;
    if (totalDays <= 0) return pesoMeta;
    final daysSinceStart =
        DateTime.now().toUtc().difference(dataInicio).inDays.clamp(0, totalDays);
    final totalDiff = pesoMeta - pesoInicial;
    return pesoInicial + (totalDiff * daysSinceStart / totalDays);
  }

  // Diferença entre peso atual e peso esperado (positivo = adiantado, negativo = atrasado)
  double? get diferencaVsPrevisao {
    if (ultimoPeso == null) return null;
    final esperado = pesoEsperadoHoje;
    return isPerda ? esperado - ultimoPeso! : ultimoPeso! - esperado;
  }

  // 'adiantado' | 'no_prazo' | 'atrasado' | 'sem_dados'
  String get statusProgresso {
    final diff = diferencaVsPrevisao;
    if (diff == null) return 'sem_dados';
    if (diff > 0.5) return 'adiantado';
    if (diff < -0.5) return 'atrasado';
    return 'no_prazo';
  }

  double get progresso {
    final peso = ultimoPeso ?? pesoInicial;
    if (isPerda) {
      final total = pesoInicial - pesoMeta;
      if (total <= 0) return 0;
      return ((pesoInicial - peso) / total).clamp(0.0, 1.0);
    } else {
      final total = pesoMeta - pesoInicial;
      if (total <= 0) return 0;
      return ((peso - pesoInicial) / total).clamp(0.0, 1.0);
    }
  }
}

class WeightGoalHistoryItem {
  final String id;
  final double pesoInicial;
  final double pesoMeta;
  final String tipo;
  final DateTime dataInicio;
  final DateTime dataFim;
  final double? pesoFinal;
  final String resultado; // "atingida" | "nao_atingida"

  WeightGoalHistoryItem({
    required this.id,
    required this.pesoInicial,
    required this.pesoMeta,
    required this.tipo,
    required this.dataInicio,
    required this.dataFim,
    this.pesoFinal,
    required this.resultado,
  });

  factory WeightGoalHistoryItem.fromJson(Map<String, dynamic> json) => WeightGoalHistoryItem(
        id: json['id'],
        pesoInicial: (json['pesoInicial'] as num).toDouble(),
        pesoMeta: (json['pesoMeta'] as num).toDouble(),
        tipo: json['tipo'],
        dataInicio: DateTime.parse(json['dataInicio']),
        dataFim: DateTime.parse(json['dataFim']),
        pesoFinal: json['pesoFinal'] != null ? (json['pesoFinal'] as num).toDouble() : null,
        resultado: json['resultado'],
      );

  bool get atingida => resultado == 'atingida';
  String get tipoLabel => tipo == 'perda' ? 'Perda de peso' : 'Ganho de peso';
  String get mesAno {
    const meses = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    return '${meses[dataInicio.month - 1]}/${dataInicio.year}';
  }
}
