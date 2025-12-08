import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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

// --- Dialog para Editar Meta (Com Formatador de Moeda) ---
  void _mostrarDialogoEditarMeta(BuildContext context, double valorAtual) {
    // 1. INICIALIZAÇÃO FORMATADA
    // Já mostramos o valor atual bonito (ex: "R$ 1.000,00")
    final controller = TextEditingController(text: _currencyFormat.format(valorAtual));
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Alterar Meta", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          // 2. CONFIGURAÇÃO DO TECLADO E FORMATADOR
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly, // Aceita só números
            CurrencyInputFormatter(), // Aplica sua máscara mágica
          ],
          decoration: const InputDecoration(
            labelText: "Novo Valor",
            // Não precisamos de prefixText "R$ " aqui pois o formatador já coloca
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              // 3. LIMPEZA DO VALOR (Lógica Inversa)
              // Remove tudo que não é número (sobra "100000" de "R$ 1.000,00")
              String valorLimpo = controller.text.replaceAll(RegExp(r'[^0-9]'), '');
              
              if (valorLimpo.isEmpty) return;

              // Divide por 100 para voltar a ser decimal (1000.00)
              double novoValorDouble = double.parse(valorLimpo) / 100;

              if (novoValorDouble > 0) {
                Navigator.pop(ctx); // Fecha o dialog
                
                // Chama o Store (convertendo para int, já que seu Model usa int para meta)
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

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

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
                    overflow: TextOverflow.ellipsis, // Evita quebra de texto
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15), // Ajustei para 15 para caber melhor
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18, // Reduzi um pouco a fonte para caber R$ grandes
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
    // Se não tiver sugestão (meta batida ou sem data), esconde o card
    if (sugestao <= 0.01) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 20), // Espaço abaixo
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9), // Verde bem clarinho (fundo)
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200), // Borda sutil
      ),
      child: Row(
        children: [
          // Ícone de Destaque
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
          
          // Textos
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
    final cofre = detalhesStore.cofreAtivo;
    final isLoading = detalhesStore.isLoading;

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
                            // 1. O VALOR QUE IMPORTA (Dinheiro na mão)
                            Text(
                              'Arrecadado',
                              style: GoogleFonts.poppins(fontSize: 14.0, color: Colors.grey[600]),
                            ),
                            Text(
                              _currencyFormat.format(valorArrecadado),
                              style: GoogleFonts.poppins(
                                fontSize: 32.0, // Bem grande!
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E90FF),
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // 2. A BARRA (Baseada na Meta)
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

                            // 3. O COMPARATIVO (Meta vs Planejado)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Lado Esquerdo: A META (Agora Editável)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text('Meta do Cofre', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                                        const SizedBox(width: 4),
                                        
                                        // BOTÃO DE EDITAR (Pequeno e discreto)
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

                                // Lado Direito: O CUSTO PLANEJADO (Sua ideia!)
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
                                        // Se estourou, fica Laranja para avisar!
                                        color: orcamentoEstourado ? Colors.orange[800] : Colors.green[700]
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            
                            // Mensagem de aviso opcional se estourar
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

                      // Sugestão
                      _buildSugestaoCard(sugestao),

                      // Botões de Ação
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

                      // Botão Planejamento
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