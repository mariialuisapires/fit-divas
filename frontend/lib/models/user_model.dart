class UserModel {
  final String id;
  final String nome;
  final String email;
  final double? pesoAtual;
  final double? pesoMeta;
  final double? altura;
  final String? genero;
  final String? objetivo;
  final int? idade;
  final int metaAguaMl;

  UserModel({
    required this.id,
    required this.nome,
    required this.email,
    this.pesoAtual,
    this.pesoMeta,
    this.altura,
    this.genero,
    this.objetivo,
    this.idade,
    this.metaAguaMl = 2000,
  });

  bool get needsOnboarding => genero == null;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        nome: json['nome'],
        email: json['email'],
        pesoAtual: json['pesoAtual']?.toDouble(),
        pesoMeta: json['pesoMeta']?.toDouble(),
        altura: json['altura']?.toDouble(),
        genero: json['genero'],
        objetivo: json['objetivo'],
        idade: json['idade'],
        metaAguaMl: json['metaAguaMl'] ?? 2000,
      );
}
