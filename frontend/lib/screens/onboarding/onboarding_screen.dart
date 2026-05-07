import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/weight_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _step = 0;
  bool _isLoading = false;

  String? _genero;
  String? _objetivo;
  int _idade = 25;
  int _alturaCm = 165;
  int _pesoAtual = 70;
  int _pesoMeta = 65;

  static const _pink = Color(0xFFE91E8C);
  static const _steps = 7;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _canProceed() {
    switch (_step) {
      case 0:
        return _genero != null;
      case 1:
        return _objetivo != null;
      case 5:
        if (_pesoMeta == _pesoAtual) return false;
        if (_objetivo == 'perda' && _pesoMeta >= _pesoAtual) return false;
        if (_objetivo == 'ganho' && _pesoMeta <= _pesoAtual) return false;
        return true;
      default:
        return true;
    }
  }

  void _next() {
    if (_step < _steps - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _step++);
    }
  }

  void _prev() {
    if (_step > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _step--);
    }
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final weight = context.read<WeightProvider>();

    await auth.updateProfile(
      genero: _genero,
      objetivo: _objetivo,
      idade: _idade,
      altura: _alturaCm / 100.0,
      pesoAtual: _pesoAtual.toDouble(),
    );

    final hasGoal = weight.activeGoal != null;
    if (!hasGoal) {
      await weight.createGoal(_pesoAtual.toDouble(), _pesoMeta.toDouble());
    }

    if (mounted) setState(() => _isLoading = false);
  }

  String _imcLabel(int pesoKg, int alturaCm) {
    final alturaM = alturaCm / 100.0;
    final imc = pesoKg / (alturaM * alturaM);
    final label = imc < 18.5
        ? 'Abaixo do peso'
        : imc < 25
            ? 'Peso normal'
            : imc < 30
                ? 'Sobrepeso'
                : 'Obesidade';
    return 'IMC ${imc.toStringAsFixed(1)} · $label';
  }

  String _metaMessage() {
    if (_pesoMeta == _pesoAtual) return 'O peso meta deve ser diferente do peso atual';
    final diff = (_pesoMeta - _pesoAtual).abs();
    final pct = (diff / _pesoAtual * 100).toStringAsFixed(1);
    if (_objetivo == 'perda') {
      if (_pesoMeta >= _pesoAtual) return 'Para perda de peso, a meta deve ser menor que o atual';
      return 'Você deseja perder $diff kg ($pct% do seu peso)';
    } else {
      if (_pesoMeta <= _pesoAtual) return 'Para ganho de peso, a meta deve ser maior que o atual';
      return 'Você deseja ganhar $diff kg ($pct% do seu peso)';
    }
  }

  bool _metaIsValid() {
    if (_pesoMeta == _pesoAtual) return false;
    if (_objetivo == 'perda' && _pesoMeta >= _pesoAtual) return false;
    if (_objetivo == 'ganho' && _pesoMeta <= _pesoAtual) return false;
    return true;
  }

  DateTime _predictDate() {
    final diff = (_pesoMeta - _pesoAtual).abs();
    final rate = _objetivo == 'perda' ? 0.5 : 0.25;
    final weeks = max((diff / rate).ceil(), 4);
    return DateTime.now().add(Duration(days: weeks * 7));
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _buildGenderStep();
      case 1:
        return _buildObjetivoStep();
      case 2:
        return _buildScrollStep(
          title: 'Quantos anos você tem?',
          subtitle: 'Informe sua idade',
          icon: Icons.cake_outlined,
          items: List.generate(68, (i) => '${i + 13} anos'),
          selectedIndex: _idade - 13,
          onChanged: (i) => setState(() => _idade = i + 13),
        );
      case 3:
        return _buildScrollStep(
          title: 'Qual é sua altura?',
          subtitle: 'Usaremos para calcular seu IMC',
          icon: Icons.height,
          items: List.generate(81, (i) => '${i + 140} cm'),
          selectedIndex: _alturaCm - 140,
          onChanged: (i) => setState(() => _alturaCm = i + 140),
        );
      case 4:
        return _buildScrollStep(
          title: 'Qual é seu peso atual?',
          subtitle: _imcLabel(_pesoAtual, _alturaCm),
          subtitleColor: _imcColor(_pesoAtual, _alturaCm),
          icon: Icons.monitor_weight_outlined,
          items: List.generate(171, (i) => '${i + 30} kg'),
          selectedIndex: _pesoAtual - 30,
          onChanged: (i) => setState(() => _pesoAtual = i + 30),
        );
      case 5:
        return _buildScrollStep(
          title: 'Qual é sua meta de peso?',
          subtitle: _metaMessage(),
          subtitleColor: _metaIsValid() ? Colors.green : Colors.orange,
          icon: Icons.flag_outlined,
          items: List.generate(171, (i) => '${i + 30} kg'),
          selectedIndex: (_pesoMeta - 30).clamp(0, 170),
          onChanged: (i) => setState(() => _pesoMeta = i + 30),
        );
      case 6:
        return _buildPredictionStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Color _imcColor(int peso, int altura) {
    final alturaM = altura / 100.0;
    final imc = peso / (alturaM * alturaM);
    if (imc < 18.5) return Colors.blue;
    if (imc < 25) return Colors.green;
    if (imc < 30) return Colors.orange;
    return Colors.red;
  }

  Widget _buildGenderStep() {
    final options = [
      ('Feminino', Icons.female, 'feminino'),
      ('Masculino', Icons.male, 'masculino'),
      ('Outro', Icons.person_outline, 'outro'),
    ];
    return _StepLayout(
      title: 'Qual é o seu gênero?',
      subtitle: 'Isso nos ajuda a personalizar sua experiência',
      icon: Icons.wc_outlined,
      child: Column(
        children: options.map((opt) {
          final selected = _genero == opt.$3;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ChoiceCard(
              label: opt.$1,
              icon: opt.$2,
              selected: selected,
              onTap: () => setState(() => _genero = opt.$3),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildObjetivoStep() {
    final options = [
      ('Perda de Peso', Icons.trending_down, 'perda', 'Quero emagrecer e melhorar minha saúde'),
      ('Ganho de Peso', Icons.trending_up, 'ganho', 'Quero ganhar massa e me fortalecer'),
    ];
    return _StepLayout(
      title: 'Qual é seu objetivo?',
      subtitle: 'Vamos criar um plano personalizado para você',
      icon: Icons.flag_outlined,
      child: Column(
        children: options.map((opt) {
          final selected = _objetivo == opt.$3;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ChoiceCard(
              label: opt.$1,
              icon: opt.$2,
              description: opt.$4,
              selected: selected,
              onTap: () => setState(() => _objetivo = opt.$3),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildScrollStep({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<String> items,
    required int selectedIndex,
    required ValueChanged<int> onChanged,
    Color? subtitleColor,
  }) {
    return _StepLayout(
      title: title,
      subtitle: subtitle,
      subtitleColor: subtitleColor,
      icon: icon,
      child: SizedBox(
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 52,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: _pink.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _pink.withAlpha(80)),
              ),
            ),
            ListWheelScrollView.useDelegate(
              controller: FixedExtentScrollController(initialItem: selectedIndex),
              itemExtent: 52,
              onSelectedItemChanged: onChanged,
              physics: const FixedExtentScrollPhysics(),
              perspective: 0.003,
              diameterRatio: 2.5,
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: items.length,
                builder: (ctx, i) => Center(
                  child: Text(
                    items[i],
                    style: TextStyle(
                      fontSize: i == selectedIndex ? 24 : 18,
                      fontWeight: i == selectedIndex ? FontWeight.bold : FontWeight.normal,
                      color: i == selectedIndex ? _pink : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionStep() {
    final date = _predictDate();
    final diff = (_pesoMeta - _pesoAtual).abs();
    final isPerda = _objetivo == 'perda';

    return _StepLayout(
      title: 'Sua previsão',
      subtitle: 'Com dedicação e consistência, chegamos a este resultado',
      icon: Icons.insights,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_pink.withAlpha(20), _pink.withAlpha(5)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _pink.withAlpha(60)),
            ),
            child: Column(
              children: [
                Icon(
                  isPerda ? Icons.trending_down : Icons.trending_up,
                  size: 48,
                  color: _pink,
                ),
                const SizedBox(height: 16),
                Text(
                  'Prevemos que você estará pesando',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '$_pesoMeta kg',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: _pink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'até ${_fmtDate(date)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                _InfoChip(
                  icon: isPerda ? Icons.remove_circle_outline : Icons.add_circle_outline,
                  label: '${isPerda ? "-" : "+"}$diff kg no total',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.grey, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isPerda
                        ? 'Baseado em uma taxa segura de 0,5 kg por semana'
                        : 'Baseado em uma taxa segura de 0,25 kg por semana',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.fitness_center, color: _pink, size: 20),
                      const SizedBox(width: 6),
                      const Text('FitDivas',
                          style: TextStyle(
                              color: _pink, fontWeight: FontWeight.bold, fontSize: 16)),
                      const Spacer(),
                      Text('${_step + 1}/$_steps',
                          style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_step + 1) / _steps,
                      minHeight: 4,
                      backgroundColor: Colors.grey.shade200,
                      color: _pink,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(_steps, (_) => _buildStep()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  if (_step > 0) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _prev,
                        child: const Text('Voltar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _canProceed() && !_isLoading
                          ? (_step == _steps - 1 ? _submit : _next)
                          : null,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              _step == _steps - 1 ? 'Vamos lá!' : 'Próximo',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color? subtitleColor;
  final IconData icon;
  final Widget child;

  const _StepLayout({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE91E8C).withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFE91E8C), size: 28),
          ),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: subtitleColor ?? Colors.grey.shade600,
              fontWeight:
                  subtitleColor != null ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 32),
          child,
        ],
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? description;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    const pink = Color(0xFFE91E8C);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? pink.withAlpha(15) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? pink : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selected ? pink : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: selected ? Colors.white : Colors.grey, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: selected ? pink : Colors.black87)),
                  if (description != null)
                    Text(description!,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: Color(0xFFE91E8C), size: 20),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE91E8C).withAlpha(20),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFFE91E8C)),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE91E8C))),
          ],
        ),
      );
}
