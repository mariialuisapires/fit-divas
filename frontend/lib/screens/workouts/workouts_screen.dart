import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workout_provider.dart';
import '../../models/workout_model.dart';
import 'create_workout_screen.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutProvider>().loadWorkouts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Meus Treinos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateWorkoutScreen())),
        child: const Icon(Icons.add),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.workouts.isEmpty
              ? _EmptyState()
              : RefreshIndicator(
                  onRefresh: () => provider.loadWorkouts(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.workouts.length,
                    itemBuilder: (_, i) => _WorkoutCard(workout: provider.workouts[i]),
                  ),
                ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Nenhum treino cadastrado', style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 8),
            Text('Toque no + para criar seu primeiro treino', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
}

class _WorkoutCard extends StatelessWidget {
  final WorkoutModel workout;
  const _WorkoutCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<WorkoutProvider>();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.fitness_center, color: Color(0xFFE91E8C)),
                const SizedBox(width: 8),
                Expanded(child: Text(workout.nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                PopupMenuButton(
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'complete', child: Text('Concluir treino ✓')),
                    const PopupMenuItem(value: 'delete', child: Text('Excluir', style: TextStyle(color: Colors.red))),
                  ],
                  onSelected: (v) async {
                    if (v == 'complete') {
                      final ok = await provider.completeWorkout(workout.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(ok ? 'Treino concluído! 🎉' : provider.error ?? 'Erro'),
                          backgroundColor: ok ? Colors.green : Colors.red,
                        ));
                      }
                    } else if (v == 'delete') {
                      await provider.deleteWorkout(workout.id);
                    }
                  },
                ),
              ],
            ),
            if (workout.observacoes != null) ...[
              const SizedBox(height: 4),
              Text(workout.observacoes!, style: const TextStyle(color: Colors.grey)),
            ],
            const SizedBox(height: 8),
            Text('${workout.exercicios.length} exercício(s)', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            ...workout.exercicios.take(3).map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text('• ${e.nome} — ${e.series}x${e.repeticoes}${e.carga != null ? ' (${e.carga}kg)' : ''}',
                      style: const TextStyle(fontSize: 13)),
                )),
            if (workout.exercicios.length > 3)
              Text('+ ${workout.exercicios.length - 3} mais...', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
