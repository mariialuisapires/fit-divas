import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/challenge_provider.dart';

class CreateChallengeScreen extends StatefulWidget {
  const CreateChallengeScreen({super.key});

  @override
  State<CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends State<CreateChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _metaDiasCtrl = TextEditingController(text: '20');
  final _pesoInicialCtrl = TextEditingController();
  final _pesoMetaCtrl = TextEditingController();
  DateTime _dataInicio = DateTime.now();
  DateTime _dataFim = DateTime.now().add(const Duration(days: 30));

  final _presets = [
    _ChallengePreset('Desafio 30 dias', 30, 20),
    _ChallengePreset('Constância Mensal', 30, 22),
    _ChallengePreset('Desafio 21 dias', 21, 15),
    _ChallengePreset('Sprint Quinzenal', 15, 12),
  ];

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _metaDiasCtrl.dispose();
    _pesoInicialCtrl.dispose();
    _pesoMetaCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final initial = isStart ? _dataInicio : _dataFim;
    final first = isStart ? DateTime.now() : _dataInicio;
    final last = DateTime.now().add(const Duration(days: 31));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _dataInicio = picked;
          if (_dataFim.isBefore(picked)) {
            _dataFim = picked.add(const Duration(days: 30));
          }
        } else {
          _dataFim = picked;
        }
      });
    }
  }

  void _applyPreset(_ChallengePreset preset) {
    setState(() {
      _nomeCtrl.text = preset.nome;
      _metaDiasCtrl.text = preset.metaDias.toString();
      _dataFim = _dataInicio.add(Duration(days: preset.duracaoDias));
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ChallengeProvider>();
    final ok = await provider.createChallenge(
      nome: _nomeCtrl.text.trim(),
      pesoInicial: double.tryParse(_pesoInicialCtrl.text.replaceAll(',', '.')),
      pesoMeta: double.tryParse(_pesoMetaCtrl.text.replaceAll(',', '.')),
      metaDias: int.tryParse(_metaDiasCtrl.text) ?? 20,
      dataInicio: _dataInicio,
      dataFim: _dataFim,
    );

    if (mounted) {
      if (ok) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Erro ao criar desafio'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChallengeProvider>();
    final fmt = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Novo Desafio')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Modelos prontos', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _presets.map((p) => ActionChip(
                label: Text(p.nome),
                onPressed: () => _applyPreset(p),
              )).toList(),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nomeCtrl,
              decoration: const InputDecoration(labelText: 'Nome do desafio', prefixIcon: Icon(Icons.emoji_events)),
              validator: (v) => v!.isEmpty ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _metaDiasCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Meta de dias treinados',
                prefixIcon: Icon(Icons.fitness_center),
                helperText: 'Quantos dias você quer treinar neste período?',
              ),
              validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Informe a meta' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _DateButton(
                    label: 'Início',
                    value: fmt.format(_dataInicio),
                    onTap: () => _pickDate(true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DateButton(
                    label: 'Fim',
                    value: fmt.format(_dataFim),
                    onTap: () => _pickDate(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Duração: ${_dataFim.difference(_dataInicio).inDays + 1} dias',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Text('Evolução de peso (opcional)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _pesoInicialCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Peso inicial (kg)', suffixText: 'kg'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _pesoMetaCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Peso meta (kg)', suffixText: 'kg'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : FilledButton(onPressed: _save, child: const Text('Criar desafio')),
          ],
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateButton({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.calendar_today, size: 16),
        label: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );
}

class _ChallengePreset {
  final String nome;
  final int duracaoDias;
  final int metaDias;
  _ChallengePreset(this.nome, this.duracaoDias, this.metaDias);
}
