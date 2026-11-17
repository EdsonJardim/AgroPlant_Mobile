import 'package:flutter/material.dart';

import '../widgets/agroplant_app_bar.dart';

class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});

  static const Color verde = Color(0xFF174D2A);
  static const Color bege = Color(0xFFE8DCC6);
  static const Color verdeDetalhe = Color(0xFF78A878);
  static const Color begeClaro = Color(0xFFF7F2E8);

  static const List<Map<String, String>> equipe = [
    {
      'nome': 'Rafaela Pereira Paes',
      'funcao': 'Designer',
      'foto': 'assets/images/rafaela.jpg',
    },
    {
      'nome': 'André Luis Alves',
      'funcao': 'Líder do projeto e desenvolvedor geral',
      'foto': 'assets/images/andre.jpg',
    },
    {
      'nome': 'Edson Eduardo',
      'funcao': 'Desenvolvedor BackEnd',
      'foto': 'assets/images/edson.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;

    final corFundo = escuro
        ? const Color(0xFF121A14)
        : bege;

    final corAppBar = escuro
        ? const Color(0xFF202B23)
        : Colors.white;

    final corTexto = escuro
        ? Colors.white
        : verde;

    final corTextoSecundario = escuro
        ? Colors.white70
        : const Color(0xFF665D4F);

    final corDetalhe = escuro
        ? verdeDetalhe
        : verdeDetalhe;

    final corIconeFundo = escuro
        ? const Color(0xFF29372D)
        : begeClaro;

    final corCartao = escuro
        ? const Color(0xFF202B23)
        : Colors.white;

    return Scaffold(
      backgroundColor: corFundo,
      appBar: AgroPlantAppBar(
        backgroundColor: corAppBar,
        foregroundColor: escuro ? Colors.white : verde,
        showBackButton: true,
        logoWidth: 150,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
          child: Column(
            children: [
              Container(
                height: 68,
                width: 68,
                decoration: BoxDecoration(
                  color: corIconeFundo,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: escuro ? 0.15 : 0.05,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.eco_rounded,
                  size: 38,
                  color: corDetalhe,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Conheça nossa equipe',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: corTexto,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Pessoas que unem tecnologia, inovação e amor pelo campo.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: corTextoSecundario,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              LayoutBuilder(
                builder: (context, constraints) {
                  final largura = constraints.maxWidth;
                  final colunas = largura >= 950
                      ? 3
                      : largura >= 620
                          ? 2
                          : 1;

                  final larguraCartao =
                      (largura - (colunas - 1) * 18) / colunas;

                  return Wrap(
                    spacing: 18,
                    runSpacing: 18,
                    alignment: WrapAlignment.center,
                    children: equipe.map((integrante) {
                      return SizedBox(
                        width: larguraCartao,
                        child: _CartaoIntegrante(
                          nome: integrante['nome']!,
                          funcao: integrante['funcao']!,
                          foto: integrante['foto']!,
                          corCartao: corCartao,
                          corTexto: corTexto,
                          corDetalhe: corDetalhe,
                          corFuncao: corIconeFundo,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: escuro
                      ? const Color(0xFF29372D)
                      : verde,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.agriculture_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'AgroPlant',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tecnologia e organização para o campo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFF7F2E8),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.eco_outlined,
                    color: corDetalhe,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Cultivando inovação',
                    style: TextStyle(
                      color: corTexto,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartaoIntegrante extends StatelessWidget {
  final String nome;
  final String funcao;
  final String foto;
  final Color corCartao;
  final Color corTexto;
  final Color corDetalhe;
  final Color corFuncao;

  const _CartaoIntegrante({
    required this.nome,
    required this.funcao,
    required this.foto,
    required this.corCartao,
    required this.corTexto,
    required this.corDetalhe,
    required this.corFuncao,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: corCartao,
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          children: [
            Container(
              height: 190,
              width: 190,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: corDetalhe,
                  width: 3,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                foto,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.person_outline_rounded,
                      size: 70,
                      color: corDetalhe,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              nome,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: corTexto,
                fontSize: 19,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: corFuncao,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                funcao,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: corTexto,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}