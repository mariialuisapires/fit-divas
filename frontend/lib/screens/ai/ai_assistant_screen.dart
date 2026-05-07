import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/weight_provider.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _api = ApiClient();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  static const _suggestions = [
    'Como está meu progresso?',
    'Dicas para perder peso mais rápido',
    'Quantas calorias devo beber de água?',
    'Exercício para iniciantes em casa',
    'Como melhorar meu sono para emagrecer?',
    'O que comer antes do treino?',
  ];

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final nome = auth.user?.nome.split(' ').first ?? 'você';
    _messages.add(_ChatMessage(
      text: 'Olá, $nome! Sou a Diva, sua assistente fitness 💪\nPode me perguntar sobre treinos, nutrição, hidratação ou seu progresso. Estou aqui para te ajudar!',
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildContexto() {
    final auth = context.read<AuthProvider>();
    final weight = context.read<WeightProvider>();
    final user = auth.user;
    final goal = weight.activeGoal;

    final ctx = <String, dynamic>{};
    if (user?.nome != null) ctx['nome'] = user!.nome.split(' ').first;
    if (user?.genero != null) ctx['genero'] = user!.genero;
    if (user?.idade != null) ctx['idade'] = user!.idade;
    if (user?.altura != null) ctx['alturaCm'] = (user!.altura! * 100).round();
    if (user?.objetivo != null) ctx['objetivo'] = user!.objetivo;

    if (goal != null) {
      ctx['pesoAtual'] = goal.ultimoPeso ?? goal.pesoInicial;
      ctx['pesoMeta'] = goal.pesoMeta;
      ctx['statusProgresso'] = goal.statusProgresso;
      final d = goal.dataFim;
      ctx['previsaoMeta'] =
          '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    }

    return ctx;
  }

  List<Map<String, String>> _buildHistorico() {
    // Envia até os últimos 20 mensagens (10 trocas), pulando a mensagem inicial da Diva
    final msgs = _messages.skip(1).toList();
    final start = msgs.length > 20 ? msgs.length - 20 : 0;
    return msgs.sublist(start).map((m) => {
          'role': m.isUser ? 'user' : 'assistant',
          'content': m.text,
        }).toList();
  }

  Future<void> _send(String text) async {
    final question = text.trim();
    if (question.isEmpty) return;

    _ctrl.clear();
    setState(() {
      _messages.add(_ChatMessage(text: question, isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final data = await _api.post(ApiConstants.aiChat, {
        'pergunta': question,
        'historico': _buildHistorico(),
        'contexto': _buildContexto(),
      });
      if (mounted) {
        setState(() {
          _messages
              .add(_ChatMessage(text: data['resposta'] ?? 'Sem resposta.', isUser: false));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: 'Não consegui responder agora. Tente novamente.',
            isUser: false,
            isError: true,
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    final auth = context.read<AuthProvider>();
    final nome = auth.user?.nome.split(' ').first ?? 'você';
    setState(() {
      _messages.clear();
      _messages.add(_ChatMessage(
        text: 'Olá, $nome! Sou a Diva, sua assistente fitness 💪\nPode me perguntar sobre treinos, nutrição, hidratação ou seu progresso. Estou aqui para te ajudar!',
        isUser: false,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Text('D',
                  style: TextStyle(
                      color: Color(0xFFE91E8C),
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Diva', style: TextStyle(fontSize: 16)),
                Text('Assistente Fitness',
                    style: TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _clearChat,
            tooltip: 'Nova conversa',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_messages.length == 1) ...[
            Container(
              color: Colors.grey.shade50,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _suggestions.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => ActionChip(
                    label: Text(_suggestions[i],
                        style: const TextStyle(fontSize: 12)),
                    onPressed: () => _send(_suggestions[i]),
                    backgroundColor: const Color(0xFFE91E8C).withAlpha(15),
                    side: BorderSide(
                        color: const Color(0xFFE91E8C).withAlpha(60)),
                  ),
                ),
              ),
            ),
          ],
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == _messages.length) return const _TypingIndicator();
                return _MessageBubble(message: _messages[i]);
              },
            ),
          ),
          _InputBar(
            controller: _ctrl,
            isLoading: _isLoading,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final bool isError;
  _ChatMessage({required this.text, required this.isUser, this.isError = false});
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: message.isError
              ? Colors.red.shade100
              : isUser
                  ? const Color(0xFFE91E8C)
                  : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
              color: isUser ? Colors.white : Colors.black87, fontSize: 15),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(delay: 0),
            SizedBox(width: 4),
            _Dot(delay: 150),
            SizedBox(width: 4),
            _Dot(delay: 300),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.4, end: 1.0).animate(CurvedAnimation(
        parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _anim,
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFFE91E8C),
            shape: BoxShape.circle,
          ),
        ),
      );
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final void Function(String) onSend;

  const _InputBar(
      {required this.controller,
      required this.isLoading,
      required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          12, 8, 12, MediaQuery.of(context).padding.bottom + 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 8,
              offset: const Offset(0, -2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Pergunte qualquer coisa sobre fitness...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: isLoading ? null : onSend,
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: isLoading ? null : () => onSend(controller.text),
            icon: const Icon(Icons.send),
            style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFE91E8C)),
          ),
        ],
      ),
    );
  }
}
