import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/challenge_provider.dart';
import '../../providers/water_provider.dart';
import '../../providers/calendar_provider.dart';

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
      context.read<ChallengeProvider>().loadActive();
      context.read<WaterProvider>().loadToday();
      context.read<CalendarProvider>().loadMonth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final challenge = context.watch<ChallengeProvider>();
    final water = context.watch<WaterProvider>();
    final calendar = context.watch<CalendarProvider>();

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
            context.read<ChallengeProvider>().loadActive(),
            context.read<WaterProvider>().loadToday(),
            context.read<CalendarProvider>().loadMonth(),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ChallengeCard(challenge: challenge),
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

class _ChallengeCard extends StatelessWidget {
  final ChallengeProvider challenge;
  const _ChallengeCard({required this.challenge});

  @override
  Widget build(BuildContext context) {
    if (challenge.isLoading) return const Card(child: Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())));
    if (challenge.activeChallenge == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.emoji_events_outlined, size: 40, color: Colors.grey),
              const SizedBox(height: 8),
              const Text('Nenhum desafio ativo', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Crie um desafio para começar!', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    final c = challenge.activeChallenge!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events, color: Color(0xFFE91E8C)),
                const SizedBox(width: 8),
                Text(c.nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: c.progressoPercentual / 100,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text('${c.diasTreinados} de ${c.metaDiasTreinados} dias treinados', style: const TextStyle(color: Colors.grey)),
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
                Text('Este mês', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            if (month != null)
              Text('${month.totalDiasTreinados} dias treinados', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFE91E8C)))
            else
              const Text('Carregando...'),
          ],
        ),
      ),
    );
  }
}
