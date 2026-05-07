import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workout_provider.dart';
import '../../models/workout_model.dart';

class CreateWorkoutScreen extends StatefulWidget {
  const CreateWorkoutScreen({super.key});

  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();
  final List<_ExerciseForm> _exercises = [];

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  void _addExercise() => setState(() => _exercises.add(_ExerciseForm()));

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Adicione pelo menos um exercício')));
      return;
    }

    final exercicios = _exercises.asMap().entries.map((entry) {
      final f = entry.value;
      return ExerciseModel(
        id: '',
        nome: f.nomeCtrl.text,
        series: int.tryParse(f.seriesCtrl.text) ?? 3,
        repeticoes: int.tryParse(f.repsCtrl.text) ?? 10,
        carga: double.tryParse(f.cargaCtrl.text),
        observacoes: f.obsCtrl.text.isEmpty ? null : f.obsCtrl.text,
        ordem: entry.key + 1,
      );
    }).toList();

    final provider = context.read<WorkoutProvider>();
    final ok = await provider.createWorkout(
      _nomeCtrl.text.trim(),
      _obsCtrl.text.isEmpty ? null : _obsCtrl.text.trim(),
      exercicios,
    );

    if (mounted) {
      if (ok) Navigator.pop(context);
      else ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.error ?? 'Erro')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Treino'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _save),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nomeCtrl,
              decoration: const InputDecoration(labelText: 'Nome do treino (ex: Treino A)', prefixIcon: Icon(Icons.fitness_center)),
              validator: (v) => v!.isEmpty ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _obsCtrl,
              decoration: const InputDecoration(labelText: 'Observações (opcional)', prefixIcon: Icon(Icons.notes)),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            const Text('Exercícios', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._exercises.asMap().entries.map((e) => _ExerciseTile(
                  form: e.value,
                  index: e.key,
                  onRemove: () => setState(() => _exercises.removeAt(e.key)),
                )),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _addExercise,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar exercício'),
            ),
            const SizedBox(height: 24),
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              FilledButton(onPressed: _save, child: const Text('Salvar treino')),
          ],
        ),
      ),
    );
  }
}

class _ExerciseForm {
  final nomeCtrl = TextEditingController();
  final seriesCtrl = TextEditingController(text: '3');
  final repsCtrl = TextEditingController(text: '12');
  final cargaCtrl = TextEditingController();
  final obsCtrl = TextEditingController();
}

class _ExerciseTile extends StatelessWidget {
  final _ExerciseForm form;
  final int index;
  final VoidCallback onRemove;

  const _ExerciseTile({required this.form, required this.index, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Text('Exercício ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: onRemove),
              ],
            ),
            TextFormField(
              controller: form.nomeCtrl,
              decoration: const InputDecoration(labelText: 'Nome do exercício'),
              validator: (v) => v!.isEmpty ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: TextFormField(controller: form.seriesCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Séries'))),
                const SizedBox(width: 8),
                Expanded(child: TextFormField(controller: form.repsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Reps'))),
                const SizedBox(width: 8),
                Expanded(child: TextFormField(controller: form.cargaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Kg'))),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(controller: form.obsCtrl, decoration: const InputDecoration(labelText: 'Obs (opcional)')),
          ],
        ),
      ),
    );
  }
}
