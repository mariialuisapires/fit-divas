class UserModel {
  final String id;
  final String nome;
  final String email;
  final double? pesoAtual;
  final double? pesoMeta;
  final double? altura;
  final int metaAguaMl;

  UserModel({
    required this.id,
    required this.nome,
    required this.email,
    this.pesoAtual,
    this.pesoMeta,
    this.altura,
    this.metaAguaMl = 2000,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        nome: json['nome'],
        email: json['email'],
        pesoAtual: json['pesoAtual']?.toDouble(),
        pesoMeta: json['pesoMeta']?.toDouble(),
        altura: json['altura']?.toDouble(),
        metaAguaMl: json['metaAguaMl'] ?? 2000,
      );
}
