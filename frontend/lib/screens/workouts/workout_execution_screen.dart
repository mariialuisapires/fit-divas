import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/workout_model.dart';
import '../../providers/workout_provider.dart';

class WorkoutExecutionScreen extends StatefulWidget {
  final WorkoutModel workout;
  const WorkoutExecutionScreen({super.key, required this.workout});

  @override
  State<WorkoutExecutionScreen> createState() => _WorkoutExecutionScreenState();
}

class _WorkoutExecutionScreenState extends State<WorkoutExecutionScreen> {
  late List<bool> _checked;

  @override
  void initState() {
    super.initState();
    _checked = List.filled(widget.workout.exercicios.length, false);
  }

  int get _total => widget.workout.exercicios.length;
  int get _feitos => _checked.where((c) => c).length;
  double get _porcentagem => _total == 0 ? 0 : _feitos / _total;

  Future<void> _finalizar() async {
    if (_total == 0) return;

    if (_feitos < 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Complete pelo menos 3 exercícios para finalizar o treino'),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    final completo = _feitos == _total;
    final provider = context.read<WorkoutProvider>();

    if (!completo) {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Treino incompleto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Você completou $_feitos de $_total exercícios',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: _porcentagem,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey.shade200,
                      color: const Color(0xFFE91E8C),
                    ),
                  ),
                  Text(
                    '${(_porcentagem * 100).round()}%',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Deseja finalizar mesmo assim?', textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Continuar')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Finalizar')),
          ],
        ),
      );
      if (confirmar != true) return;
    }

    final ok = await provider.completeWorkout(widget.workout.id);

    if (mounted) {
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(completo
              ? 'Treino concluído! 100% 🎉'
              : 'Treino finalizado com ${(_porcentagem * 100).round()}% ✓'),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(provider.error ?? 'Erro ao finalizar'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercicios = widget.workout.exercicios;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workout.nome),
        actions: [
          if (_total > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '$_feitos/$_total',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_total > 0)
            LinearProgressIndicator(
              value: _porcentagem,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              color: const Color(0xFFE91E8C),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: exercicios.length,
              itemBuilder: (_, i) {
                final ex = exercicios[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: CheckboxListTile(
                    value: _checked[i],
                    onChanged: (v) => setState(() => _checked[i] = v ?? false),
                    activeColor: const Color(0xFFE91E8C),
                    title: Text(
                      ex.nome,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        decoration: _checked[i] ? TextDecoration.lineThrough : null,
                        color: _checked[i] ? Colors.grey : null,
                      ),
                    ),
                    subtitle: Text(
                      '${ex.series} séries × ${ex.repeticoes} reps${ex.carga != null ? ' · ${ex.carga}kg' : ''}',
                      style: TextStyle(color: _checked[i] ? Colors.grey : null),
                    ),
                    secondary: CircleAvatar(
                      backgroundColor: _checked[i] ? const Color(0xFFE91E8C) : Colors.grey.shade200,
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: _checked[i] ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _finalizar,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Finalizar Treino', style: TextStyle(fontSize: 16)),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
