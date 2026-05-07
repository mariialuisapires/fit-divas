import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/water_provider.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/weight_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WaterProvider>().loadToday();
      context.read<CalendarProvider>().loadMonth();
      context.read<WeightProvider>().loadActiveGoal();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final water = context.watch<WaterProvider>();
    final calendar = context.watch<CalendarProvider>();
    final weight = context.watch<WeightProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, ${auth.user?.nome.split(' ').first ?? ''} 💪'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            context.read<WaterProvider>().loadToday(),
            context.read<CalendarProvider>().loadMonth(),
            context.read<WeightProvider>().loadActiveGoal(),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _WeightCard(auth: auth, weight: weight),
            const SizedBox(height: 16),
            _WaterCard(water: water),
            const SizedBox(height: 16),
            _CalendarSummaryCard(calendar: calendar),
          ],
        ),
      ),
    );
  }
}

class _WeightCard extends StatelessWidget {
  final AuthProvider auth;
  final WeightProvider weight;
  const _WeightCard({required this.auth, required this.weight});

  @override
  Widget build(BuildContext context) {
    final goal = weight.activeGoal;
    final pesoAtual = goal?.ultimoPeso;
    final pesoMeta = goal?.pesoMeta;
    final progresso = goal?.progresso;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.monitor_weight, color: Color(0xFFE91E8C)),
                SizedBox(width: 8),
                Text('Meta de peso', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            if (pesoAtual != null && pesoMeta != null) ...[
              if (progresso != null) ...[
                LinearProgressIndicator(
                  value: progresso,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                  backgroundColor: Colors.grey.shade200,
                  color: const Color(0xFFE91E8C),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Atual: ${pesoAtual.toStringAsFixed(1)} kg',
                      style: const TextStyle(color: Colors.grey)),
                  Text('Meta: ${pesoMeta.toStringAsFixed(1)} kg',
                      style: const TextStyle(color: Color(0xFFE91E8C), fontWeight: FontWeight.w600)),
                ],
              ),
              if (progresso != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${(progresso * 100).round()}% da meta atingida',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              if (goal != null && goal.ultimoPeso != null) ...[
                const SizedBox(height: 8),
                _HomeStatusChip(status: goal.statusProgresso, diff: goal.diferencaVsPrevisao),
              ],
            ] else ...[
              const Text('Acesse Evolução para criar sua meta mensal',
                  style: TextStyle(color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }
}

class _WaterCard extends StatelessWidget {
  final WaterProvider water;
  const _WaterCard({required this.water});

  @override
  Widget build(BuildContext context) {
    if (water.isLoading) return const Card(child: Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())));
    final s = water.summary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.water_drop, color: Color(0xFF2196F3)),
                SizedBox(width: 8),
                Text('Hidratação de hoje', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            if (s != null) ...[
              LinearProgressIndicator(
                value: s.percentualAtingido / 100,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
                color: s.metaAtingida ? Colors.green : const Color(0xFF2196F3),
              ),
              const SizedBox(height: 8),
              Text('${s.totalMlHoje}ml de ${s.metaDiariaMl}ml', style: const TextStyle(color: Colors.grey)),
              if (s.metaAtingida) const Text('Meta atingida! 🎉', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ] else
              const Text('Sem dados de hoje'),
          ],
        ),
      ),
    );
  }
}

class _CalendarSummaryCard extends StatelessWidget {
  final CalendarProvider calendar;
  const _CalendarSummaryCard({required this.calendar});

  @override
  Widget build(BuildContext context) {
    final month = calendar.currentMonth;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.calendar_month, color: Color(0xFFE91E8C)),
                SizedBox(width: 8),
                Text('Treinos este mês', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            if (month != null)
              Text('${month.totalDiasTreinados} dias treinados',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFE91E8C)))
            else
              const Text('Carregando...'),
          ],
        ),
      ),
    );
  }
}

class _HomeStatusChip extends StatelessWidget {
  final String status;
  final double? diff;
  const _HomeStatusChip({required this.status, required this.diff});

  @override
  Widget build(BuildContext context) {
    final (Color color, IconData icon, String label) = switch (status) {
      'adiantado' => (
          Colors.green,
          Icons.rocket_launch_outlined,
          diff != null ? '${diff!.toStringAsFixed(1)} kg à frente' : 'Adiantado',
        ),
      'atrasado' => (
          Colors.orange,
          Icons.warning_amber_rounded,
          diff != null ? '${diff!.toStringAsFixed(1)} kg atrás' : 'Atrasado',
        ),
      _ => (Colors.blue, Icons.check_circle_outline, 'No prazo'),
    };

    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }
}
