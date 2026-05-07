import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workout_provider.dart';
import '../../models/workout_model.dart';
import 'create_workout_screen.dart';
import 'workout_execution_screen.dart';

const _dias = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];

int _diaAtualIndex() => DateTime.now().weekday - 1;

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _dias.length, vsync: this, initialIndex: _diaAtualIndex());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutProvider>().loadWorkouts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _abrirCriar() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateWorkoutScreen()));
    if (mounted) context.read<WorkoutProvider>().loadWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Treinos'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _dias.asMap().entries.map((e) {
            final isHoje = e.key == _diaAtualIndex();
            return Tab(
              child: Text(
                e.value.substring(0, 3),
                style: TextStyle(fontWeight: isHoje ? FontWeight.bold : FontWeight.normal),
              ),
            );
          }).toList(),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: _dias.map((dia) {
                final workoutsDia = provider.workouts.where((w) => w.diaSemana == dia).toList();
                return RefreshIndicator(
                  onRefresh: () => provider.loadWorkouts(),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      OutlinedButton.icon(
                        onPressed: _abrirCriar,
                        icon: const Icon(Icons.add),
                        label: Text('Criar treino de $dia'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (workoutsDia.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 60),
                          child: Column(
                            children: [
                              Icon(Icons.fitness_center, size: 56, color: Colors.grey),
                              SizedBox(height: 12),
                              Text('Nenhum treino cadastrado para este dia',
                                  style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
                            ],
                          ),
                        )
                      else
                        ...workoutsDia.map((w) => _WorkoutCard(workout: w)),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final WorkoutModel workout;
  const _WorkoutCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<WorkoutProvider>();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => WorkoutExecutionScreen(workout: workout)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.fitness_center, color: Color(0xFFE91E8C)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(workout.nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  PopupMenuButton(
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'delete', child: Text('Excluir', style: TextStyle(color: Colors.red))),
                    ],
                    onSelected: (v) async {
                      if (v == 'delete') await provider.deleteWorkout(workout.id);
                    },
                  ),
                ],
              ),
              if (workout.observacoes != null) ...[
                const SizedBox(height: 4),
                Text(workout.observacoes!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
              const SizedBox(height: 8),
              Text('${workout.exercicios.length} exercício(s)',
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 6),
              ...workout.exercicios.take(3).map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      '• ${e.nome} — ${e.series}x${e.repeticoes}${e.carga != null ? ' (${e.carga}kg)' : ''}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  )),
              if (workout.exercicios.length > 3)
                Text('+ ${workout.exercicios.length - 3} mais...',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.play_circle_outline, size: 16, color: Color(0xFFE91E8C)),
                  const SizedBox(width: 4),
                  const Text('Toque para iniciar', style: TextStyle(color: Color(0xFFE91E8C), fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
