import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/weight_provider.dart';
import '../../providers/challenge_provider.dart';

class EvolutionScreen extends StatefulWidget {
  const EvolutionScreen({super.key});

  @override
  State<EvolutionScreen> createState() => _EvolutionScreenState();
}

class _EvolutionScreenState extends State<EvolutionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeightProvider>().loadSummary();
      context.read<ChallengeProvider>().loadActive();
    });
  }

  void _showAddWeight() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Registrar peso'),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Peso (kg)', suffixText: 'kg'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              final peso = double.tryParse(ctrl.text.replaceAll(',', '.'));
              if (peso != null) {
                Navigator.pop(context);
                await context.read<WeightProvider>().addWeight(peso);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weight = context.watch<WeightProvider>();
    final s = weight.summary;

    return Scaffold(
      appBar: AppBar(title: const Text('Evolução Física')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddWeight,
        icon: const Icon(Icons.add),
        label: const Text('Registrar peso'),
      ),
      body: weight.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => weight.loadSummary(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (s != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Peso atual', style: TextStyle(color: Colors.grey)),
                            Text(
                              s.pesoAtual != null ? '${s.pesoAtual!.toStringAsFixed(1)} kg' : '—',
                              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFFE91E8C)),
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _WeightInfo(label: 'Meta', value: s.pesoMeta != null ? '${s.pesoMeta!.toStringAsFixed(1)} kg' : '—'),
                                _WeightInfo(
                                  label: 'Variação',
                                  value: s.diferenca != null
                                      ? '${s.diferenca! >= 0 ? '+' : ''}${s.diferenca!.toStringAsFixed(1)} kg'
                                      : '—',
                                  color: s.diferenca != null
                                      ? (s.diferenca! < 0 ? Colors.green : Colors.orange)
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (s.historico.isNotEmpty) ...[
                      const Text('Histórico do mês', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...s.historico.reversed.map((h) => ListTile(
                            leading: const Icon(Icons.monitor_weight, color: Color(0xFFE91E8C)),
                            title: Text('${h.peso.toStringAsFixed(1)} kg', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${h.dataRegistro.day.toString().padLeft(2, '0')}/${h.dataRegistro.month.toString().padLeft(2, '0')}/${h.dataRegistro.year}'),
                          )),
                    ],
                  ] else
                    const Center(child: Text('Nenhum registro de peso')),
                ],
              ),
            ),
    );
  }
}

class _WeightInfo extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _WeightInfo({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      );
}
