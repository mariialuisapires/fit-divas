import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/water_provider.dart';

class WaterScreen extends StatefulWidget {
  const WaterScreen({super.key});

  @override
  State<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends State<WaterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WaterProvider>().loadToday();
    });
  }

  Future<void> _addWater(int ml) async {
    final ok = await context.read<WaterProvider>().addWater(ml);
    if (mounted && !ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<WaterProvider>().error ?? 'Erro')),
      );
    }
  }

  void _showCustomDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Quantidade personalizada'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Quantidade em ml', suffixText: 'ml'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              final ml = int.tryParse(ctrl.text);
              if (ml != null && ml > 0) {
                Navigator.pop(context);
                _addWater(ml);
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WaterProvider>();
    final summary = provider.summary;

    return Scaffold(
      appBar: AppBar(title: const Text('Controle de Água 💧')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.loadToday(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (summary != null) ...[
                    _WaterProgress(summary: summary),
                    const SizedBox(height: 24),
                  ],
                  const Text('Adicionar água', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [200, 300, 400, 500].map((ml) => FilledButton.tonal(
                      onPressed: () => _addWater(ml),
                      child: Text('${ml}ml'),
                    )).toList(),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _showCustomDialog,
                    icon: const Icon(Icons.edit),
                    label: const Text('Quantidade personalizada'),
                  ),
                  if (summary != null && summary.registrosHoje.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text('Registros de hoje', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...summary.registrosHoje.map((r) => ListTile(
                          leading: const Icon(Icons.water_drop, color: Color(0xFF2196F3)),
                          title: Text('${r.quantidadeMl}ml'),
                          subtitle: Text('${r.dataRegistro.hour.toString().padLeft(2, '0')}:${r.dataRegistro.minute.toString().padLeft(2, '0')}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => provider.removeEntry(r.id),
                          ),
                        )),
                  ],
                ],
              ),
            ),
    );
  }
}

class _WaterProgress extends StatelessWidget {
  final dynamic summary;
  const _WaterProgress({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              '${summary.totalMlHoje}ml',
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
            ),
            Text('de ${summary.metaDiariaMl}ml', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: summary.percentualAtingido / 100,
                minHeight: 16,
                color: summary.metaAtingida ? Colors.green : const Color(0xFF2196F3),
                backgroundColor: Colors.blue.shade100,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              summary.metaAtingida ? 'Meta atingida! 🎉' : '${summary.percentualAtingido.toStringAsFixed(0)}% da meta diária',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: summary.metaAtingida ? Colors.green : const Color(0xFF2196F3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
