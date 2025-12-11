import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:travelbox/models/enums/nivelPermissao.dart';
import 'package:travelbox/utils/currency_input_formatter.dart';
import 'package:travelbox/views/balanco.dart';

// Imports Views
import 'package:travelbox/views/contribuicao.dart';
import 'package:travelbox/views/historicoContr.dart';
import 'package:travelbox/views/listaUser.dart';
import 'package:travelbox/views/modules/header.dart';
import 'package:travelbox/views/modules/footbar.dart';
import 'package:travelbox/views/planejamento.dart';

// Imports Store
import 'package:travelbox/stores/detalhesCofreStore.dart';
import 'package:travelbox/stores/authStore.dart';

class CofreScreen extends StatefulWidget {
  final String cofreId;

  const CofreScreen({super.key, required this.cofreId});

  @override
  State<CofreScreen> createState() => _CofreScreenState();
}

class _CofreScreenState extends State<CofreScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$ ',
    decimalDigits: 2,
  );

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  // NOVA FUNÇÃO: Confirmar Encerramento
  void _confirmarEncerramento(BuildContext context, DetalhesCofreStore store) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Encerrar Viagem?"),
        content: const Text("Ao encerrar, ninguém poderá adicionar novos gastos. Apenas acertos de dívidas serão permitidos na tela de Balanço.\n\nEssa ação não pode ser desfeita."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              bool sucesso = await store.encerrarViagem();
              if (mounted && sucesso) {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Viagem encerrada com sucesso.")));
              }
            },
            child: const Text("Encerrar Agora", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  // --- Dialog para Editar Meta ---
  void _mostrarDialogoEditarMeta(BuildContext context, double valorAtual) {
    final controller = TextEditingController(text: _currencyFormat.format(valorAtual));
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Alterar Meta", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly, 
            CurrencyInputFormatter(), 
          ],
          decoration: const InputDecoration(
            labelText: "Novo Valor",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              String valorLimpo = controller.text.replaceAll(RegExp(r'[^0-9]'), '');
              if (valorLimpo.isEmpty) return;
              double novoValorDouble = double.parse(valorLimpo) / 100;

              if (novoValorDouble > 0) {
                Navigator.pop(ctx); 
                final store = context.read<DetalhesCofreStore>();
                bool sucesso = await store.alterarMeta(novoValorDouble.toInt()); 
                if (mounted && sucesso) {
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text("Meta atualizada com sucesso!"))
                   );
                }
              }
            },
            child: const Text("Salvar"),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarDados();
    });
  }

  Future<void> _carregarDados() async {
    await Provider.of<DetalhesCofreStore>(
      context,
      listen: false,
    ).carregarDadosCofre(widget.cofreId);
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF1E90FF), size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF333333),
                    ),
                    overflow: TextOverflow.ellipsis, 
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15), 
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget: Card de Sugestão Inteligente ---
  Widget _buildSugestaoCard(double sugestao) {
    if (sugestao <= 0.01) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 20), 
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9), 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200), 
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.green.withOpacity(0.2), blurRadius: 5)
              ],
            ),
            child: const Icon(Icons.savings_outlined, color: Colors.green, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sugestão de Depósito",
                  style: GoogleFonts.poppins(
                    fontSize: 12, 
                    fontWeight: FontWeight.w600, 
                    color: Colors.green.shade800
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "${_currencyFormat.format(sugestao)} /mês",
                  style: GoogleFonts.poppins(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.green.shade900
                  ),
                ),
                Text(
                  "para cada membro até a viagem",
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.green.shade700),
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
    final detalhesStore = context.watch<DetalhesCofreStore>();
    final authStore = context.watch<AuthStore>();
    final cofre = detalhesStore.cofreAtivo;
    final isLoading = detalhesStore.isLoading;
    final bool isFinalizado = detalhesStore.isCofreFinalizado;

    final meuId = authStore.usuario?.id;
    bool souCoordenador = false;
    try {
        final minhaPermissao = detalhesStore.membros.firstWhere((m) => m.idUsuario == meuId);
        souCoordenador = minhaPermissao.nivelPermissao == NivelPermissao.coordenador;
    } catch (_) {}

    if (isLoading && cofre == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (detalhesStore.errorMessage != null || cofre == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Erro")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Não foi possível carregar o cofre.", style: GoogleFonts.poppins()),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: _carregarDados, child: const Text("Tentar Novamente")),
            ],
          ),
        ),
      );
    }

    // Variáveis Seguras (Bang Operator '!')
    final double valorAlvo = cofre.valorPlano.toDouble();
    final double valorArrecadado = detalhesStore.totalArrecadado;
    final double valorGasto = detalhesStore.totalGasto;
    final double saldoDisponivel = detalhesStore.saldoDisponivel;
    final double valorPlanejado = detalhesStore.totalPlanejado;
    final double sugestao = detalhesStore.sugestaoMensal;

    final double progress = (valorAlvo != 0) ? (valorArrecadado / valorAlvo) : 0.0;
    final double valorRestante = (valorAlvo - valorArrecadado).clamp(0.0, double.infinity);
    final bool orcamentoEstourado = valorPlanejado > valorAlvo;

    return Scaffold(
      backgroundColor: const Color(0xFF1E90FF),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Header(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF4F9FB),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50.0),
                  topRight: Radius.circular(50.0),
                ),
              ),
              child: RefreshIndicator(
                onRefresh: _carregarDados,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Nome do Cofre
                      Text(
                        cofre.nome,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 30.0),

                      // Card Principal (Progresso)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Arrecadado',
                              style: GoogleFonts.poppins(fontSize: 14.0, color: Colors.grey[600]),
                            ),
                            Text(
                              _currencyFormat.format(valorArrecadado),
                              style: GoogleFonts.poppins(
                                fontSize: 32.0, 
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E90FF),
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            LinearProgressIndicator(
                              value: progress.clamp(0.0, 1.0),
                              backgroundColor: Colors.grey.shade200,
                              color: const Color(0xFF1E90FF),
                              minHeight: 12,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '${(progress * 100).toStringAsFixed(0)}% da Meta',
                                style: GoogleFonts.poppins(fontSize: 12.0, color: Colors.grey[600]),
                              ),
                            ),

                            const Divider(height: 30),

                            // COMPARATIVO (Meta vs Planejado)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Lado Esquerdo: A META
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text('Meta do Cofre', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                                        const SizedBox(width: 4),
                                        
                                        // BOTÃO EDITAR META (Só aparece se aberto)
                                        if (!isFinalizado)
                                          InkWell(
                                            onTap: () => _mostrarDialogoEditarMeta(context, valorAlvo),
                                            child: const Padding(
                                              padding: EdgeInsets.all(4.0),
                                              child: Icon(Icons.edit, size: 14, color: Color(0xFF1E90FF)),
                                            ),
                                          ),
                                      ],
                                    ),
                                    Text(
                                      _currencyFormat.format(valorAlvo),
                                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                    ),
                                  ],
                                ),

                                // Lado Direito: O CUSTO PLANEJADO
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        if (orcamentoEstourado) 
                                          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
                                        const SizedBox(width: 4),
                                        Text('Custo Planejado', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                    Text(
                                      _currencyFormat.format(valorPlanejado),
                                      style: GoogleFonts.poppins(
                                        fontSize: 16, 
                                        fontWeight: FontWeight.bold, 
                                        color: orcamentoEstourado ? Colors.orange[800] : Colors.green[700]
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            
                            if (orcamentoEstourado)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  "Atenção: Seus planos custam mais que sua meta!",
                                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.orange[800], fontStyle: FontStyle.italic),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30.0),

                      // ALERTA DE ENCERRADO
                      if (isFinalizado)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.lock, color: Colors.red),
                              const SizedBox(width: 8),
                              Text("Viagem Encerrada", style: GoogleFonts.poppins(color: Colors.red.shade900, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),

                      // Sugestão (Só se aberto)
                      if (!isFinalizado) _buildSugestaoCard(sugestao),

                      // Botões de Ação (CONDICIONAIS)
                      if (!isFinalizado) ...[
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Contribuicao(cofreId: widget.cofreId)),
                            ).then((_) => _carregarDados());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 255, 187, 0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                          ),
                          child: Text('Adicionar Contribuição', style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
                        ),

                        const SizedBox(height: 20.0),

                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PlanejamentoScreen(cofreId: widget.cofreId)),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade400,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                          ),
                          child: Text('Planejamento de Custos', style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
                        ),
                        const SizedBox(height: 20.0),
                      ],

                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ListaUser(cofreId: widget.cofreId)),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E90FF),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: Text('Visualizar Participantes', style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
                      ),

                      const SizedBox(height: 30.0),

                      // Cards de Informação
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              title: 'Valor Alvo',
                              value: _currencyFormat.format(valorAlvo),
                              icon: Icons.flag,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildInfoCard(
                              title: 'Restante',
                              value: _currencyFormat.format(valorRestante),
                              icon: Icons.trending_down,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // NOVOS CARDS (Gastos e Saldo)
                      Row(
                        children: [
                          Expanded(child: _buildInfoCard(
                            title: 'Total Gasto', 
                            value: _currencyFormat.format(valorGasto), 
                            icon: Icons.shopping_cart_outlined,
                          )),
                          const SizedBox(width: 10),
                          Expanded(child: _buildInfoCard(
                            title: 'Saldo Disp.', 
                            value: _currencyFormat.format(saldoDisponivel), 
                            icon: Icons.account_balance_wallet_outlined,
                          )),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              title: 'Início',
                              value: cofre.dataViagem != null ? _dateFormat.format(cofre.dataViagem!) : '---',
                              icon: Icons.calendar_today,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildInfoCard(
                              title: 'Código',
                              value: cofre.joinCode,
                              icon: Icons.lock_open,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30.0),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const BalancoScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: Text('Balanço e Gastos', style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
                      ),

                      const SizedBox(height: 30.0),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Historicocontr(cofreId: widget.cofreId)),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade400,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: Text('Histórico de Contribuições', style: GoogleFonts.poppins(fontSize: 18, color: Colors.black)),
                      ),
                      
                      // BOTÃO DE ENCERRAR (NOVO - Só para Coordenador)
                      if (souCoordenador && !isFinalizado) ...[
                        const SizedBox(height: 40.0),
                        const Divider(),
                        const SizedBox(height: 10.0),
                        
                        TextButton.icon(
                          onPressed: () => _confirmarEncerramento(context, detalhesStore),
                          icon: const Icon(Icons.lock_outline, color: Colors.red),
                          label: Text("Encerrar Viagem", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            backgroundColor: Colors.red.withOpacity(0.1),
                          ),
                        ),
                      ],

                      const SizedBox(height: 50.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Footbarr(),
        ],
      ),
    );
  }
}