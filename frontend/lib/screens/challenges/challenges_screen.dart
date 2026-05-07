import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/challenge_provider.dart';
import '../../models/challenge_model.dart';
import 'create_challenge_screen.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChallengeProvider>().loadActive();
      context.read<ChallengeProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChallengeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Desafios 🏆')),
      floatingActionButton: provider.activeChallenge == null
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateChallengeScreen()),
              ),
              child: const Icon(Icons.add),
            )
          : null,
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await provider.loadActive();
                await provider.loadAll();
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (provider.activeChallenge != null) ...[
                    const Text('Desafio Ativo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _ActiveChallengeCard(challenge: provider.activeChallenge!, provider: provider),
                    const SizedBox(height: 24),
                  ],
                  if (provider.challenges.where((c) => c.status != 'Ativo').isNotEmpty) ...[
                    const Text('Histórico', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...provider.challenges
                        .where((c) => c.status != 'Ativo')
                        .map((c) => _ChallengeHistoryCard(challenge: c)),
                  ],
                  if (provider.activeChallenge == null && provider.challenges.isEmpty)
                    _EmptyState(),
                ],
              ),
            ),
    );
  }
}

class _ActiveChallengeCard extends StatelessWidget {
  final ChallengeModel challenge;
  final ChallengeProvider provider;

  const _ActiveChallengeCard({required this.challenge, required this.provider});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    final diasRestantes = challenge.dataFim.difference(DateTime.now()).inDays;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events, color: Color(0xFFE91E8C), size: 28),
                const SizedBox(width: 8),
                Expanded(child: Text(challenge.nome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: challenge.progressoPercentual / 100,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${challenge.diasTreinados}/${challenge.metaDiasTreinados} dias', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${challenge.progressoPercentual.toStringAsFixed(0)}%', style: const TextStyle(color: Color(0xFFE91E8C), fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 24),
            _InfoRow(icon: Icons.calendar_today, label: 'Início', value: fmt.format(challenge.dataInicio)),
            const SizedBox(height: 4),
            _InfoRow(icon: Icons.flag, label: 'Fim', value: fmt.format(challenge.dataFim)),
            const SizedBox(height: 4),
            _InfoRow(
              icon: Icons.timelapse,
              label: 'Dias restantes',
              value: diasRestantes > 0 ? '$diasRestantes dias' : 'Encerrado hoje',
            ),
            if (challenge.pesoInicial != null) ...[
              const SizedBox(height: 4),
              _InfoRow(icon: Icons.monitor_weight, label: 'Peso inicial', value: '${challenge.pesoInicial!.toStringAsFixed(1)} kg'),
            ],
            if (challenge.pesoMeta != null) ...[
              const SizedBox(height: 4),
              _InfoRow(icon: Icons.flag_outlined, label: 'Meta de peso', value: '${challenge.pesoMeta!.toStringAsFixed(1)} kg'),
            ],
            if (challenge.pesoAtual != null) ...[
              const SizedBox(height: 4),
              _InfoRow(
                icon: Icons.trending_down,
                label: 'Peso atual',
                value: '${challenge.pesoAtual!.toStringAsFixed(1)} kg',
                valueColor: challenge.pesoMeta != null && challenge.pesoAtual! <= challenge.pesoMeta! ? Colors.green : null,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _confirmFinish(context),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.green),
                    child: const Text('Concluir'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _confirmCancel(context),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Cancelar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmFinish(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Concluir desafio'),
        content: const Text('Deseja marcar este desafio como concluído?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Concluir')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await provider.finishChallenge(challenge.id);
    }
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancelar desafio'),
        content: const Text('Tem certeza? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Não')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancelar desafio'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await provider.cancelChallenge(challenge.id);
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Text('$label: ', style: const TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: valueColor)),
        ],
      );
}

class _ChallengeHistoryCard extends StatelessWidget {
  final ChallengeModel challenge;
  const _ChallengeHistoryCard({required this.challenge});

  @override
  Widget build(BuildContext context) {
    final isCompleted = challenge.status == 'Concluido';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          isCompleted ? Icons.check_circle : Icons.cancel,
          color: isCompleted ? Colors.green : Colors.red,
        ),
        title: Text(challenge.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${challenge.diasTreinados}/${challenge.metaDiasTreinados} dias treinados'),
        trailing: Chip(
          label: Text(isCompleted ? 'Concluído' : 'Cancelado', style: const TextStyle(fontSize: 12)),
          backgroundColor: isCompleted ? Colors.green.shade100 : Colors.red.shade100,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Icon(Icons.emoji_events_outlined, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Nenhum desafio ainda', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              const Text('Crie seu primeiro desafio e comece sua jornada!', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
}
