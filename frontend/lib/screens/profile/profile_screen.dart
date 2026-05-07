import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_client.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeCtrl;
  late TextEditingController _pesoCtrl;
  late TextEditingController _pesoMetaCtrl;
  late TextEditingController _alturaCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nomeCtrl = TextEditingController(text: user?.nome ?? '');
    _pesoCtrl = TextEditingController(text: user?.pesoAtual?.toStringAsFixed(1) ?? '');
    _pesoMetaCtrl = TextEditingController(text: user?.pesoMeta?.toStringAsFixed(1) ?? '');
    _alturaCtrl = TextEditingController(text: user?.altura?.toStringAsFixed(2) ?? '');
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _pesoCtrl.dispose();
    _pesoMetaCtrl.dispose();
    _alturaCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    try {
      final api = ApiClient();
      await api.put(ApiConstants.profile, {
        'nome': _nomeCtrl.text.trim(),
        'pesoAtual': double.tryParse(_pesoCtrl.text.replaceAll(',', '.')),
        'pesoMeta': double.tryParse(_pesoMetaCtrl.text.replaceAll(',', '.')),
        'altura': double.tryParse(_alturaCtrl.text.replaceAll(',', '.')),
      });
      await auth.loadProfile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja sair da sua conta?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sair')),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<AuthProvider>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout, tooltip: 'Sair'),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: const Color(0xFFE91E8C),
              child: Text(
                (user?.nome.isNotEmpty == true) ? user!.nome[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(user?.email ?? '', style: const TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nomeCtrl,
                  decoration: const InputDecoration(labelText: 'Nome', prefixIcon: Icon(Icons.person)),
                  validator: (v) => v!.isEmpty ? 'Informe seu nome' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pesoCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Peso atual (kg)',
                    prefixIcon: Icon(Icons.monitor_weight),
                    suffixText: 'kg',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pesoMetaCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Peso meta (kg)',
                    prefixIcon: Icon(Icons.flag),
                    suffixText: 'kg',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _alturaCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Altura (m)',
                    prefixIcon: Icon(Icons.height),
                    suffixText: 'm',
                    hintText: 'ex: 1.65',
                  ),
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : FilledButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.save),
                        label: const Text('Salvar alterações'),
                      ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Sair da conta'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ),
          if (user != null) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Resumo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _SummaryTile(
              icon: Icons.monitor_weight,
              label: 'Peso atual',
              value: user.pesoAtual != null ? '${user.pesoAtual!.toStringAsFixed(1)} kg' : 'Não informado',
            ),
            _SummaryTile(
              icon: Icons.flag,
              label: 'Meta',
              value: user.pesoMeta != null ? '${user.pesoMeta!.toStringAsFixed(1)} kg' : 'Não informada',
            ),
            if (user.pesoAtual != null && user.pesoMeta != null)
              _SummaryTile(
                icon: Icons.trending_down,
                label: 'Falta',
                value: '${(user.pesoAtual! - user.pesoMeta!).abs().toStringAsFixed(1)} kg',
                valueColor: const Color(0xFFE91E8C),
              ),
            if (user.altura != null)
              _SummaryTile(
                icon: Icons.height,
                label: 'Altura',
                value: '${user.altura!.toStringAsFixed(2)} m',
              ),
            if (user.pesoAtual != null && user.altura != null) ...[
              Builder(builder: (_) {
                final imc = user.pesoAtual! / (user.altura! * user.altura!);
                final classificacao = imc < 18.5
                    ? 'Abaixo do peso'
                    : imc < 25
                        ? 'Peso normal'
                        : imc < 30
                            ? 'Sobrepeso'
                            : 'Obesidade';
                return _SummaryTile(
                  icon: Icons.calculate,
                  label: 'IMC',
                  value: '${imc.toStringAsFixed(1)} — $classificacao',
                );
              }),
            ],
          ],
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryTile({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon, color: const Color(0xFFE91E8C)),
        title: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        trailing: Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: valueColor)),
        dense: true,
      );
}
