import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../providers/weight_provider.dart';
import '../../models/weight_goal_model.dart';

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
      final p = context.read<WeightProvider>();
      p.loadActiveGoal();
      p.loadGoalHistory();
    });
  }

  void _showCreateGoalDialog() {
    final pesoCtrl = TextEditingController();
    final metaCtrl = TextEditingController();
    String? tipoPreview;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Nova Meta de Peso'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pesoCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Seu peso atual (kg)', suffixText: 'kg'),
                onChanged: (_) => setS(() => tipoPreview = _calcTipo(pesoCtrl.text, metaCtrl.text)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: metaCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Peso meta (kg)', suffixText: 'kg'),
                onChanged: (_) => setS(() => tipoPreview = _calcTipo(pesoCtrl.text, metaCtrl.text)),
              ),
              if (tipoPreview != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: tipoPreview == 'perda' ? Colors.green.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        tipoPreview == 'perda' ? Icons.trending_down : Icons.trending_up,
                        color: tipoPreview == 'perda' ? Colors.green : Colors.orange,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tipoPreview == 'perda' ? 'Meta de perda de peso' : 'Meta de ganho de peso',
                        style: TextStyle(
                          color: tipoPreview == 'perda' ? Colors.green.shade700 : Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () async {
                final atual = double.tryParse(pesoCtrl.text.replaceAll(',', '.'));
                final meta = double.tryParse(metaCtrl.text.replaceAll(',', '.'));
                if (atual == null || meta == null) return;
                if (atual == meta) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('O peso meta não pode ser igual ao peso atual')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                final provider = context.read<WeightProvider>();
                final ok = await provider.createGoal(atual, meta);
                if (mounted && !ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(provider.error ?? 'Erro')),
                  );
                }
              },
              child: const Text('Criar meta'),
            ),
          ],
        ),
      ),
    );
  }

  String? _calcTipo(String pesoStr, String metaStr) {
    final peso = double.tryParse(pesoStr.replaceAll(',', '.'));
    final meta = double.tryParse(metaStr.replaceAll(',', '.'));
    if (peso == null || meta == null || peso == meta) return null;
    return meta < peso ? 'perda' : 'ganho';
  }

  void _showAddWeightDialog() {
    final ctrl = TextEditingController();
    final provider = context.read<WeightProvider>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Registrar peso da semana'),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Peso atual (kg)', suffixText: 'kg'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              final peso = double.tryParse(ctrl.text.replaceAll(',', '.'));
              if (peso != null) {
                Navigator.pop(context);
                await provider.addWeight(peso);
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
    final provider = context.watch<WeightProvider>();
    final goal = provider.activeGoal;

    return Scaffold(
      appBar: AppBar(title: const Text('Evolução de Peso')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await provider.loadActiveGoal();
                await provider.loadGoalHistory();
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (goal == null || goal.status == 'finalizado') ...[
                    _NoGoalCard(onCreateGoal: _showCreateGoalDialog),
                  ] else ...[
                    _ActiveGoalCard(goal: goal, onAddWeight: _showAddWeightDialog),
                    const SizedBox(height: 16),
                    _WeightChartCard(goal: goal),
                    const SizedBox(height: 16),
                    _WeeklyEntriesList(goal: goal),
                  ],
                  if (provider.goalHistory.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text('Histórico de metas',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...provider.goalHistory.map((h) => _HistoryCard(item: h)),
                  ],
                ],
              ),
            ),
    );
  }
}

// ─── Chart ───────────────────────────────────────────────────────────────────

class _WeightChartCard extends StatelessWidget {
  final WeightGoalModel goal;
  const _WeightChartCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final totalDays = goal.dataFim.difference(goal.dataInicio).inDays.toDouble();
    if (totalDays <= 0) return const SizedBox.shrink();

    // Actual spots: start + all recorded progressos
    final actualSpots = <FlSpot>[
      FlSpot(0, goal.pesoInicial),
      ...goal.progressos.map((p) {
        final d = p.dataRegistro
            .toLocal()
            .difference(goal.dataInicio.toLocal())
            .inDays
            .toDouble()
            .clamp(0.0, totalDays);
        return FlSpot(d, p.peso);
      }),
    ]..sort((a, b) => a.x.compareTo(b.x));

    // Prediction: straight line from start to goal date
    final predSpots = [FlSpot(0, goal.pesoInicial), FlSpot(totalDays, goal.pesoMeta)];

    // Y range with padding
    final allWeights = [...actualSpots.map((s) => s.y), goal.pesoMeta];
    final minY = (allWeights.reduce(min) - 2).floorToDouble();
    final maxY = (allWeights.reduce(max) + 2).ceilToDouble();
    final yRange = maxY - minY;
    final yInterval = yRange <= 5 ? 1.0 : yRange <= 10 ? 2.0 : 5.0;
    final xInterval = max(1.0, (totalDays / 4).roundToDouble());

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Row(
                children: [
                  const Text('Evolução de peso',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const Spacer(),
                  _ChartLegend(color: Colors.grey.shade400, label: 'Previsão', dashed: true),
                  const SizedBox(width: 12),
                  _ChartLegend(color: const Color(0xFFE91E8C), label: 'Real'),
                  const SizedBox(width: 4),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: totalDays,
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: yInterval,
                    getDrawingHorizontalLine: (_) =>
                        FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        interval: yInterval,
                        getTitlesWidget: (v, meta) => Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            '${v.toStringAsFixed(0)}kg',
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: xInterval,
                        getTitlesWidget: (v, meta) {
                          if (v == 0 || v == totalDays) return const SizedBox.shrink();
                          final date =
                              goal.dataInicio.add(Duration(days: v.toInt()));
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${date.day}/${date.month}',
                              style:
                                  const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    // Prediction line (dashed gray)
                    LineChartBarData(
                      spots: predSpots,
                      isCurved: false,
                      color: Colors.grey.shade400,
                      barWidth: 1.5,
                      dashArray: [6, 4],
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                    // Actual line (solid pink)
                    LineChartBarData(
                      spots: actualSpots,
                      isCurved: actualSpots.length > 2,
                      curveSmoothness: 0.25,
                      color: const Color(0xFFE91E8C),
                      barWidth: 2.5,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, xp, bar, idx) => FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xFFE91E8C),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFFE91E8C).withAlpha(20),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => const Color(0xFF333333),
                      getTooltipItems: (spots) => spots.map((s) {
                        if (s.barIndex == 0) return null;
                        final date =
                            goal.dataInicio.add(Duration(days: s.x.toInt()));
                        return LineTooltipItem(
                          '${s.y.toStringAsFixed(1)} kg\n'
                          '${date.day.toString().padLeft(2, '0')}/'
                          '${date.month.toString().padLeft(2, '0')}',
                          const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            if (goal.progressos.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 0, 0),
                child: Text(
                  'Adicione registros semanais para acompanhar sua evolução',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;
  final bool dashed;
  const _ChartLegend({required this.color, required this.label, this.dashed = false});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          SizedBox(
            width: 20,
            height: 12,
            child: CustomPaint(painter: _LinePainter(color: color, dashed: dashed)),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      );
}

class _LinePainter extends CustomPainter {
  final Color color;
  final bool dashed;
  const _LinePainter({required this.color, required this.dashed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    final cy = size.height / 2;
    if (!dashed) {
      canvas.drawLine(Offset(0, cy), Offset(size.width, cy), paint);
    } else {
      const dashW = 4.0, gap = 3.0;
      double x = 0;
      while (x < size.width) {
        canvas.drawLine(
            Offset(x, cy), Offset((x + dashW).clamp(0, size.width), cy), paint);
        x += dashW + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Other cards ─────────────────────────────────────────────────────────────

class _NoGoalCard extends StatelessWidget {
  final VoidCallback onCreateGoal;
  const _NoGoalCard({required this.onCreateGoal});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.monitor_weight_outlined, size: 56, color: Colors.grey),
              const SizedBox(height: 12),
              const Text('Nenhuma meta ativa',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Crie uma meta para acompanhar seu progresso de peso',
                  style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onCreateGoal,
                icon: const Icon(Icons.add),
                label: const Text('Criar meta de peso'),
              ),
            ],
          ),
        ),
      );
}

class _ActiveGoalCard extends StatelessWidget {
  final WeightGoalModel goal;
  final VoidCallback onAddWeight;
  const _ActiveGoalCard({required this.goal, required this.onAddWeight});

  @override
  Widget build(BuildContext context) {
    final diff = goal.diferencaAtual;
    final isPerda = goal.isPerda;
    final progressoOk = isPerda ? (diff != null && diff < 0) : (diff != null && diff > 0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(isPerda ? Icons.trending_down : Icons.trending_up,
                    color: const Color(0xFFE91E8C)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(goal.tipoLabel,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Ativo', style: TextStyle(color: Colors.green, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: goal.progresso,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
              backgroundColor: Colors.grey.shade200,
              color: const Color(0xFFE91E8C),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Início: ${goal.pesoInicial.toStringAsFixed(1)} kg',
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
                Text('Meta: ${goal.pesoMeta.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                        color: Color(0xFFE91E8C), fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Peso atual',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(
                        goal.ultimoPeso != null
                            ? '${goal.ultimoPeso!.toStringAsFixed(1)} kg'
                            : '—',
                        style:
                            const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                if (diff != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Variação',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(
                        '${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(1)} kg',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: progressoOk ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (goal.ultimoPeso != null) _StatusBanner(goal: goal),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAddWeight,
                icon: const Icon(Icons.add),
                label: const Text('Registrar peso da semana'),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Previsão: ${_fmt(goal.dataFim)}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _WeeklyEntriesList extends StatelessWidget {
  final WeightGoalModel goal;
  const _WeeklyEntriesList({required this.goal});

  @override
  Widget build(BuildContext context) {
    if (goal.progressos.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Registros semanais',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            ...goal.progressos.reversed.map((p) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.monitor_weight,
                      color: Color(0xFFE91E8C), size: 20),
                  title: Text('${p.peso.toStringAsFixed(1)} kg',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: Text(
                    '${p.dataRegistro.day.toString().padLeft(2, '0')}/${p.dataRegistro.month.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final WeightGoalHistoryItem item;
  const _HistoryCard({required this.item});

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor:
                item.atingida ? Colors.green.shade100 : Colors.orange.shade100,
            child: Icon(
              item.atingida ? Icons.check : Icons.close,
              color: item.atingida ? Colors.green : Colors.orange,
              size: 20,
            ),
          ),
          title: Text(item.mesAno, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
            '${item.tipoLabel} · ${item.pesoInicial.toStringAsFixed(1)} → ${item.pesoMeta.toStringAsFixed(1)} kg'
            '${item.pesoFinal != null ? ' (final: ${item.pesoFinal!.toStringAsFixed(1)} kg)' : ''}',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: Text(
            item.atingida ? 'Atingida' : 'Não atingida',
            style: TextStyle(
              color: item.atingida ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      );
}

class _StatusBanner extends StatelessWidget {
  final WeightGoalModel goal;
  const _StatusBanner({required this.goal});

  @override
  Widget build(BuildContext context) {
    final status = goal.statusProgresso;
    final diff = goal.diferencaVsPrevisao?.abs();
    final esperado = goal.pesoEsperadoHoje;

    final (Color bg, Color fg, IconData icon, String titulo, String subtitulo) =
        switch (status) {
      'adiantado' => (
          Colors.green.shade50,
          Colors.green.shade700,
          Icons.rocket_launch_outlined,
          'Adiantado!',
          diff != null
              ? '${diff.toStringAsFixed(1)} kg à frente da previsão (esperado ${esperado.toStringAsFixed(1)} kg)'
              : '',
        ),
      'atrasado' => (
          Colors.orange.shade50,
          Colors.orange.shade700,
          Icons.warning_amber_rounded,
          'Abaixo do esperado',
          diff != null
              ? '${diff.toStringAsFixed(1)} kg atrás da previsão (esperado ${esperado.toStringAsFixed(1)} kg)'
              : '',
        ),
      _ => (
          Colors.blue.shade50,
          Colors.blue.shade700,
          Icons.check_circle_outline,
          'No prazo!',
          'Você está seguindo a previsão direitinho',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: fg, fontSize: 13)),
                if (subtitulo.isNotEmpty)
                  Text(subtitulo,
                      style: TextStyle(fontSize: 11, color: fg.withAlpha(200))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
