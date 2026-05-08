import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/weight_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _pink = Color(0xFFE91E8C);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeightProvider>().loadActiveGoal();
    });
  }

  Future<void> _showDeleteAccountDialog() async {
    final senhaCtrl = TextEditingController();
    bool obscure = true;
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Excluir conta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Esta ação é permanente e irá apagar todos os seus dados.',
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: senhaCtrl,
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: 'Digite sua senha para confirmar',
                  suffixIcon: IconButton(
                    icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setS(() => obscure = !obscure),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else
              FilledButton(
                onPressed: () async {
                  final senha = senhaCtrl.text;
                  if (senha.isEmpty) return;
                  setS(() => isLoading = true);
                  final error =
                      await context.read<AuthProvider>().deleteAccount(senha);
                  if (!ctx.mounted) return;
                  if (error != null) {
                    setS(() => isLoading = false);
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                          content: Text(error),
                          backgroundColor: Colors.red),
                    );
                  } else {
                    Navigator.pop(ctx);
                  }
                },
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Excluir'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja sair da sua conta?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sair')),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<AuthProvider>().logout();
    }
  }

  void _showEditDialog() {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    final nomeCtrl = TextEditingController(text: user?.nome ?? '');
    String? genero = user?.genero;
    String? objetivo = user?.objetivo;
    int idade = user?.idade ?? 25;
    int alturaCm = user?.altura != null ? (user!.altura! * 100).round() : 165;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Editar Perfil'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nomeCtrl,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                const SizedBox(height: 16),
                const Text('Gênero',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: ['feminino', 'masculino', 'outro'].map((g) {
                    final label = g[0].toUpperCase() + g.substring(1);
                    return ChoiceChip(
                      label: Text(label),
                      selected: genero == g,
                      selectedColor: _pink.withAlpha(40),
                      onSelected: (_) => setS(() => genero = g),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                const Text('Objetivo',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: [
                    ('perda', 'Perda de Peso'),
                    ('ganho', 'Ganho de Peso'),
                  ].map((o) {
                    return ChoiceChip(
                      label: Text(o.$2),
                      selected: objetivo == o.$1,
                      selectedColor: _pink.withAlpha(40),
                      onSelected: (_) => setS(() => objetivo = o.$1),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Idade',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                          Slider(
                            value: idade.toDouble(),
                            min: 13,
                            max: 80,
                            divisions: 67,
                            label: '$idade anos',
                            activeColor: _pink,
                            onChanged: (v) => setS(() => idade = v.round()),
                          ),
                          Center(
                              child: Text('$idade anos',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Altura (cm)',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                          Slider(
                            value: alturaCm.toDouble(),
                            min: 140,
                            max: 220,
                            divisions: 80,
                            label: '$alturaCm cm',
                            activeColor: _pink,
                            onChanged: (v) =>
                                setS(() => alturaCm = v.round()),
                          ),
                          Center(
                              child: Text('$alturaCm cm',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              FilledButton(
                onPressed: () async {
                  setS(() => isLoading = true);
                  await auth.updateProfile(
                    nome: nomeCtrl.text.trim().isNotEmpty
                        ? nomeCtrl.text.trim()
                        : null,
                    genero: genero,
                    objetivo: objetivo,
                    idade: idade,
                    altura: alturaCm / 100.0,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Salvar'),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final weight = context.watch<WeightProvider>();
    final goal = weight.activeGoal;
    final ultimoPeso = goal?.ultimoPeso?.toDouble() ?? user?.pesoAtual;
    final alturaM = user?.altura;
    final alturaCm = alturaM != null ? (alturaM * 100).round() : null;

    double? imc;
    String? imcLabel;
    if (ultimoPeso != null && alturaM != null && alturaM > 0) {
      imc = ultimoPeso / (alturaM * alturaM);
      imcLabel = imc < 18.5
          ? 'Abaixo do peso'
          : imc < 25
              ? 'Peso normal'
              : imc < 30
                  ? 'Sobrepeso'
                  : 'Obesidade';
    }

    String generoLabel(String? g) {
      if (g == 'feminino') return 'Feminino';
      if (g == 'masculino') return 'Masculino';
      if (g == 'outro') return 'Outro';
      return 'Não informado';
    }

    String objetivoLabel(String? o) {
      if (o == 'perda') return 'Perda de Peso';
      if (o == 'ganho') return 'Ganho de Peso';
      return 'Não informado';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        actions: [
          IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: _showEditDialog,
              tooltip: 'Editar perfil'),
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Sair'),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: _pink,
                  child: Text(
                    (user?.nome.isNotEmpty == true)
                        ? user!.nome[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user?.nome ?? '',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(user?.email ?? '',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle('Informações pessoais'),
          Card(
            child: Column(
              children: [
                _InfoTile(
                    icon: Icons.wc,
                    label: 'Gênero',
                    value: generoLabel(user?.genero)),
                const Divider(height: 1, indent: 56),
                _InfoTile(
                    icon: Icons.flag_outlined,
                    label: 'Objetivo',
                    value: objetivoLabel(user?.objetivo)),
                const Divider(height: 1, indent: 56),
                _InfoTile(
                    icon: Icons.cake_outlined,
                    label: 'Idade',
                    value: user?.idade != null
                        ? '${user!.idade} anos'
                        : 'Não informado'),
                const Divider(height: 1, indent: 56),
                _InfoTile(
                    icon: Icons.height,
                    label: 'Altura',
                    value: alturaCm != null
                        ? '$alturaCm cm'
                        : 'Não informado'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionTitle('Peso e saúde'),
          Card(
            child: Column(
              children: [
                _InfoTile(
                    icon: Icons.monitor_weight_outlined,
                    label: 'Peso atual',
                    value: ultimoPeso != null
                        ? '${ultimoPeso.toStringAsFixed(1)} kg'
                        : 'Não registrado'),
                if (goal != null) ...[
                  const Divider(height: 1, indent: 56),
                  _InfoTile(
                      icon: Icons.track_changes,
                      label: 'Meta',
                      value: '${goal.pesoMeta.toStringAsFixed(1)} kg'),
                  const Divider(height: 1, indent: 56),
                  _InfoTile(
                      icon: goal.isPerda
                          ? Icons.trending_down
                          : Icons.trending_up,
                      label: 'Falta',
                      value: ultimoPeso != null
                          ? '${(ultimoPeso - goal.pesoMeta).abs().toStringAsFixed(1)} kg'
                          : '—',
                      valueColor: _pink),
                ],
                if (imc != null && imcLabel != null) ...[
                  const Divider(height: 1, indent: 56),
                  _InfoTile(
                      icon: Icons.calculate_outlined,
                      label: 'IMC',
                      value: '${imc.toStringAsFixed(1)} · $imcLabel'),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Sair da conta'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _showDeleteAccountDialog,
            icon: const Icon(Icons.delete_forever_outlined, size: 18),
            label: const Text('Excluir minha conta'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red.shade400,
              textStyle: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey)),
      );
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoTile(
      {required this.icon,
      required this.label,
      required this.value,
      this.valueColor});

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon, color: const Color(0xFFE91E8C), size: 22),
        title: Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: valueColor)),
        dense: true,
      );
}
