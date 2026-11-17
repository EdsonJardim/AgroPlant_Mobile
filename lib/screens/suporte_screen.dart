import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/agroplant_app_bar.dart';

class SuporteScreen extends StatefulWidget {
  const SuporteScreen({super.key});

  @override
  State<SuporteScreen> createState() => _SuporteScreenState();
}

class _SuporteScreenState extends State<SuporteScreen> {
  static const Color verde = Color(0xFF174D2A);
  static const Color verdeClaro = Color(0xFF78A878);
  static const Color bege = Color(0xFFE8DCC6);
  static const Color begeClaro = Color(0xFFF7F2E8);
  static const Color textoSecundario = Color(0xFF62594B);

  final _formKey = GlobalKey<FormState>();
  final _assuntoController = TextEditingController();
  final _mensagemController = TextEditingController();

  bool _enviando = false;

  User? get _usuario => FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    _assuntoController.dispose();
    _mensagemController.dispose();
    super.dispose();
  }

  Future<void> _enviarAtendimento() async {
    if (!_formKey.currentState!.validate()) return;

    final usuario = _usuario;

    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Faça login para enviar uma mensagem.'),
        ),
      );
      return;
    }

    setState(() {
      _enviando = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(usuario.uid)
          .collection('atendimentos')
          .add({
        'assunto': _assuntoController.text.trim(),
        'mensagem': _mensagemController.text.trim(),
        'status': 'Pendente',
        'email': usuario.email ?? '',
        'criadoEm': FieldValue.serverTimestamp(),
        'resposta': '',
        'respondidoEm': null,
      });

      if (!mounted) return;

      _assuntoController.clear();
      _mensagemController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mensagem enviada com sucesso!'),
        ),
      );

      DefaultTabController.of(context).animateTo(2);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível enviar sua mensagem. Tente novamente.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _enviando = false;
        });
      }
    }
  }

  Widget _tituloSecao(String titulo, String descricao) {
    final escuro = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              color: escuro ? Colors.white : verde,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            descricao,
            style: TextStyle(
              color: escuro ? Colors.white70 : textoSecundario,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartao({required Widget child}) {
    final escuro = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ??
            Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: escuro
            ? []
            : [
                BoxShadow(
                  color: verde.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: child,
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icone,
    int maxLines = 1,
    int maxLength = 100,
  }) {
    final escuro = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      style: TextStyle(
        color: escuro ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icone,
          color: escuro ? verdeClaro : verde,
        ),
        filled: true,
        fillColor: escuro ? const Color(0xFF202B23) : begeClaro,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: escuro ? Colors.white12 : bege,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: escuro ? verdeClaro : verde,
            width: 1.5,
          ),
        ),
      ),
      validator: (valor) {
        if (valor == null || valor.trim().isEmpty) {
          return 'Preencha este campo.';
        }

        return null;
      },
    );
  }

  Widget _centralAjuda() {
    final perguntas = [
      {
        'pergunta': 'Como cadastrar uma conta no AgroPlant?',
        'resposta':
            'Acesse a tela de login, escolha a opção Criar conta e preencha os dados solicitados.',
        'icone': Icons.person_add_alt_1_rounded,
      },
      {
        'pergunta': 'Como recuperar minha senha?',
        'resposta':
            'Na tela de login ou nas configurações, acesse a opção de recuperar senha e informe seu e-mail cadastrado. Você receberá um link para redefinição.',
        'icone': Icons.lock_reset_rounded,
      },
      {
        'pergunta': 'Como cadastrar uma propriedade?',
        'resposta':
            'Acesse Minha Propriedade e utilize a opção de adicionar propriedade. Informe o nome, a área em hectares e os demais dados solicitados.',
        'icone': Icons.agriculture_rounded,
      },
      {
        'pergunta': 'Como utilizar minha localização GPS?',
        'resposta':
            'Ao cadastrar ou editar uma propriedade, utilize a opção de obter localização atual. Permita o acesso à localização quando o Android solicitar.',
        'icone': Icons.my_location_rounded,
      },
      {
        'pergunta': 'Como funciona o mapa da propriedade?',
        'resposta':
            'O mapa permite visualizar a localização da propriedade e selecionar um ponto. Você também pode utilizar a visualização de satélite quando disponível.',
        'icone': Icons.map_outlined,
      },
      {
        'pergunta': 'Como consultar o clima da propriedade?',
        'resposta':
            'Na tela Minha Propriedade, o AgroPlant consulta as condições meteorológicas utilizando as coordenadas cadastradas de cada propriedade.',
        'icone': Icons.cloud_outlined,
      },
      {
        'pergunta': 'O clima é atualizado automaticamente?',
        'resposta':
            'Sim. O cartão de clima realiza uma nova consulta a cada 30 minutos enquanto está ativo. Ao retornar ao aplicativo, ele também verifica se já passou esse intervalo. Você pode atualizar manualmente pelo botão de atualização.',
        'icone': Icons.refresh_rounded,
      },
      {
        'pergunta': 'Por que o clima pode apresentar diferenças?',
        'resposta':
            'As informações são fornecidas por um serviço meteorológico com base nas coordenadas da propriedade. Elas são estimativas da região e podem apresentar diferenças em relação às condições observadas diretamente na fazenda.',
        'icone': Icons.thermostat_rounded,
      },
      {
        'pergunta': 'Como alterar minhas preferências?',
        'resposta':
            'Acesse Configurações para ajustar as opções de notificações e o modo de exibição do aplicativo.',
        'icone': Icons.settings_outlined,
      },
      {
        'pergunta': 'Como acompanhar meus atendimentos?',
        'resposta':
            'Acesse a aba Atendimentos dentro da tela de Suporte. Nela você poderá consultar suas mensagens, seus status e as respostas da equipe quando disponíveis.',
        'icone': Icons.support_agent_rounded,
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _tituloSecao(
          'Central de ajuda',
          'Encontre orientações sobre as principais funcionalidades do AgroPlant.',
        ),
        ...perguntas.map(
          (item) => _cartao(
            child: ExpansionTile(
              leading: Icon(
                item['icone'] as IconData,
                color: verdeClaro,
              ),
              title: Text(
                item['pergunta'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item['resposta'] as String,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : textoSecundario,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _enviarMensagem() {
    final escuro = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _tituloSecao(
          'Enviar mensagem',
          'Descreva sua dúvida ou problema. Nossa equipe poderá consultar seu atendimento.',
        ),
        _cartao(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _campo(
                    controller: _assuntoController,
                    label: 'Assunto',
                    hint: 'Ex.: Problema ao cadastrar propriedade',
                    icone: Icons.subject_rounded,
                    maxLength: 100,
                  ),
                  const SizedBox(height: 16),
                  _campo(
                    controller: _mensagemController,
                    label: 'Mensagem',
                    hint: 'Conte como podemos ajudar...',
                    icone: Icons.message_outlined,
                    maxLines: 6,
                    maxLength: 1000,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _enviando ? null : _enviarAtendimento,
                      icon: _enviando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded),
                      label: Text(
                        _enviando ? 'Enviando...' : 'Enviar mensagem',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: escuro ? verdeClaro : verde,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatarData(dynamic valor) {
    if (valor is! Timestamp) return 'Data não disponível';

    final data = valor.toDate().toLocal();

    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$ano às $hora:$minuto';
  }

  Color _corStatus(String status) {
    switch (status.toLowerCase()) {
      case 'respondido':
        return Colors.green;
      case 'em andamento':
        return Colors.orange;
      case 'pendente':
        return Colors.blue;
      default:
        return Colors.blueGrey;
    }
  }

  Widget _meusAtendimentos() {
    final usuario = _usuario;
    final escuro = Theme.of(context).brightness == Brightness.dark;

    if (usuario == null) {
      return const Center(
        child: Text('Faça login para visualizar seus atendimentos.'),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(usuario.uid)
          .collection('atendimentos')
          .orderBy('criadoEm', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Não foi possível carregar seus atendimentos.'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: verdeClaro),
          );
        }

        final atendimentos = snapshot.data?.docs ?? [];

        if (atendimentos.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.support_agent_rounded,
                    size: 64,
                    color: escuro ? verdeClaro : verde,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum atendimento ainda',
                    style: TextStyle(
                      color: escuro ? Colors.white : verde,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Quando você enviar uma mensagem, ela aparecerá aqui.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: escuro ? Colors.white70 : textoSecundario,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _tituloSecao(
              'Meus atendimentos',
              'Acompanhe suas mensagens e as respostas da equipe de suporte.',
            ),
            ...atendimentos.map((documento) {
              final dados = documento.data();
              final assunto = dados['assunto'] ?? 'Sem assunto';
              final mensagem = dados['mensagem'] ?? '';
              final status = dados['status'] ?? 'Pendente';
              final resposta = dados['resposta'] ?? '';
              final respondidoEm = dados['respondidoEm'];

              return _cartao(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              assunto,
                              style: TextStyle(
                                color: escuro ? Colors.white : verde,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _corStatus(status).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: _corStatus(status),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        mensagem,
                        style: TextStyle(
                          color: escuro ? Colors.white70 : textoSecundario,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Enviado em: ${_formatarData(dados['criadoEm'])}',
                        style: TextStyle(
                          color: escuro ? Colors.white54 : textoSecundario,
                          fontSize: 12,
                        ),
                      ),
                      if (resposta is String && resposta.trim().isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Divider(
                          color: escuro ? Colors.white12 : bege,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.support_agent_rounded,
                              color: verdeClaro,
                              size: 21,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Resposta do suporte',
                              style: TextStyle(
                                color: escuro ? Colors.white : verde,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          resposta,
                          style: TextStyle(
                            color: escuro ? Colors.white70 : textoSecundario,
                            height: 1.5,
                          ),
                        ),
                        if (respondidoEm != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Respondido em: ${_formatarData(respondidoEm)}',
                            style: TextStyle(
                              color: escuro ? Colors.white54 : textoSecundario,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: escuro ? const Color(0xFF121A14) : bege,
        appBar: AgroPlantAppBar(
          backgroundColor: escuro ? const Color(0xFF202B23) : Colors.white,
          foregroundColor: escuro ? Colors.white : verde,
          title: const Text(
            'Suporte',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            indicatorColor: verdeClaro,
            labelColor: verdeClaro,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(
                icon: Icon(Icons.help_outline_rounded),
                text: 'Ajuda',
              ),
              Tab(
                icon: Icon(Icons.mail_outline_rounded),
                text: 'Mensagem',
              ),
              Tab(
                icon: Icon(Icons.history_rounded),
                text: 'Atendimentos',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _centralAjuda(),
            _enviarMensagem(),
            _meusAtendimentos(),
          ],
        ),
      ),
    );
  }
}