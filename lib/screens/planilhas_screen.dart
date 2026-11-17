import 'package:flutter/material.dart';

import '../widgets/agroplant_app_bar.dart';
import 'estoque_screen.dart';
import 'estatisticas_geral_screen.dart';
import 'gestao_screen.dart';
import 'maquinas_screen.dart';
import 'safra_screen.dart';

class PlanilhasScreen extends StatelessWidget {
  const PlanilhasScreen({super.key});

  static const Color verde = Color(0xFF174D2A);
  static const Color verdeClaro = Color(0xFF78A878);
  static const Color bege = Color(0xFFE8DCC6);
  static const Color begeClaro = Color(0xFFF7F2E8);
  static const Color textoSecundario = Color(0xFF62594B);

  @override
  Widget build(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;

    final corFundo = escuro ? const Color(0xFF101A13) : bege;
    final corAppBar = escuro ? const Color(0xFF1E2D23) : begeClaro;
    final corTexto = escuro ? Colors.white : verde;
    final corTextoSecundario = escuro
        ? const Color(0xFFB8C1B9)
        : textoSecundario;
    final corDetalhe = escuro ? const Color(0xFF9BCB9A) : verde;

    return Scaffold(
      backgroundColor: corFundo,
      appBar: AgroPlantAppBar(
        backgroundColor: corAppBar,
        foregroundColor: corDetalhe,
        centerTitle: true,
        title: Text(
          'Planilhas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: corTexto,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Controle do AgroPlant',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: corTexto,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Escolha uma área para gerenciar.',
              style: TextStyle(
                fontSize: 16,
                color: corTextoSecundario,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            _PlanilhaCard(
              icone: Icons.inventory_2_outlined,
              titulo: 'Estoque',
              descricao: 'Gerencie seus produtos e recursos.',
              corIcone: escuro ? const Color(0xFF9BCB9A) : verde,
              escuro: escuro,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const EstoqueScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _PlanilhaCard(
              icone: Icons.dashboard_outlined,
              titulo: 'Gestão',
              descricao: 'Controle suas receitas e despesas.',
              corIcone: escuro
                  ? const Color(0xFF9BCB9A)
                  : const Color(0xFF47754B),
              escuro: escuro,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const GestaoScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _PlanilhaCard(
              icone: Icons.agriculture_outlined,
              titulo: 'Máquinas',
              descricao: 'Acompanhe seus equipamentos.',
              corIcone: escuro
                  ? const Color(0xFFB8C98A)
                  : const Color(0xFF6B7D39),
              escuro: escuro,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MaquinasScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _PlanilhaCard(
              icone: Icons.grass_outlined,
              titulo: 'Safra',
              descricao: 'Acompanhe suas produções.',
              corIcone: escuro
                  ? const Color(0xFF9BCB9A)
                  : verdeClaro,
              escuro: escuro,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SafraScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _PlanilhaCard(
              icone: Icons.analytics_outlined,
              titulo: 'Estatísticas Geral',
              descricao: 'Visualize todos os dados das suas planilhas.',
              corIcone: escuro
                  ? const Color(0xFF9BCB9A)
                  : verde,
              escuro: escuro,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        const EstatisticasGeralScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.eco_outlined,
                    color: corDetalhe,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AgroPlant',
                    style: TextStyle(
                      color: corTexto,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tecnologia e organização para o campo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: corTextoSecundario,
                      fontSize: 12,
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

class _PlanilhaCard extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String descricao;
  final Color corIcone;
  final bool escuro;
  final VoidCallback onTap;

  const _PlanilhaCard({
    required this.icone,
    required this.titulo,
    required this.descricao,
    required this.corIcone,
    required this.escuro,
    required this.onTap,
  });

  static const Color verde = Color(0xFF174D2A);
  static const Color bege = Color(0xFFE8DCC6);
  static const Color begeClaro = Color(0xFFF7F2E8);
  static const Color textoSecundario = Color(0xFF62594B);

  @override
  Widget build(BuildContext context) {
    final corCartao = escuro
        ? const Color(0xFF1E2D23)
        : Colors.white;
    final corTexto = escuro ? Colors.white : verde;
    final corDescricao = escuro
        ? const Color(0xFFB8C1B9)
        : textoSecundario;
    final corIconeFundo = escuro
        ? const Color(0xFF293B2F)
        : begeClaro;
    final corBorda = escuro
        ? const Color(0xFF354C3A)
        : bege;

    return Card(
      color: corCartao,
      elevation: 3,
      shadowColor: verde.withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: corIconeFundo,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: corBorda,
                    width: 1,
                  ),
                ),
                child: Icon(
                  icone,
                  size: 31,
                  color: corIcone,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: corTexto,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      descricao,
                      style: TextStyle(
                        fontSize: 14,
                        color: corDescricao,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: corIconeFundo,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: escuro ? const Color(0xFF9BCB9A) : verde,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}