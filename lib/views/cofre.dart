// Imports essenciais 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// Imports Views
import 'package:travelbox/views/contribuicao.dart';
import 'package:travelbox/views/historicoContr.dart';
import 'package:travelbox/views/listaUser.dart';
import 'package:travelbox/views/modules/header.dart';
import 'package:travelbox/views/modules/footbar.dart';

// Imports Store
import 'package:travelbox/stores/detalhesCofreStore.dart';


class CofreScreen extends StatefulWidget { // Mantenha como StatefulWidget para initState
  final String cofreId; 
  
  const CofreScreen({super.key, required this.cofreId});

  @override
  State<CofreScreen> createState() => _CofreScreenState();
}

class _CofreScreenState extends State<CofreScreen> {
  // --- Formatação de Moeda e Data ---
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR', 
    symbol: 'R\$ ', 
    decimalDigits: 2
  
  );

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    // Dispara a busca de dados assim que o widget for criado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarDados();
    });
  }

  // Função que inicia a busca de dados
  Future<void> _carregarDados() async {
    await Provider.of<DetalhesCofreStore>(context, listen: false)
        .carregarDadosCofre(widget.cofreId);
  }

  // --- Widgets de Informação Reutilizáveis ---
  Widget _buildInfoCard({required String title, required String value, required IconData icon}) {
    // ... (Método InfoCard omitido para brevidade - está correto) ...
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
                Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF333333))),
              ],
            ),
            const SizedBox(height: 20),
            Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    final store = context.watch<DetalhesCofreStore>();
    final cofre = store.cofreAtivo;
    final isLoading = store.isLoading;

    if (isLoading && cofre == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (store.errorMessage != null || cofre == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Erro")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Não foi possível carregar o cofre.", style: GoogleFonts.poppins()),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: _carregarDados, child: const Text("Tentar Novamente"))
            ],
          ),
        )
      );
    }
    
    // --- Estrutura de Dados Dinâmicos ---
    // Os dados são lidos diretamente do cofreAtivo e do totalArrecadado
    final double valorAlvo = cofre.valorPlano.toDouble(); 
    final double valorArrecadado = store.totalArrecadado;
    
    // Cálculos e Formatação
    final double progress = (valorAlvo != 0) ? (valorArrecadado / valorAlvo) : 0.0;
    final double valorRestante = (valorAlvo - valorArrecadado).clamp(0.0, double.infinity);

    // --- Layout da View (Dashboard) ---
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
                borderRadius: BorderRadius.only(topLeft: Radius.circular(50.0), topRight: Radius.circular(50.0)),
              ),
child: RefreshIndicator(
                onRefresh: _carregarDados,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(), // Permite puxar para atualizar mesmo se a lista for pequena
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Nome do Cofre
                      Text(
                        cofre.nome, 
                        textAlign: TextAlign.center, 
                        style: GoogleFonts.poppins(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.black)
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
                            Text('Meta: ${_currencyFormat.format(valorAlvo)}', style: GoogleFonts.poppins(fontSize: 16.0)),
                            const SizedBox(height: 10),
                            Text(
                              'Arrecadado: ${_currencyFormat.format(valorArrecadado)}', 
                              style: GoogleFonts.poppins(fontSize: 20.0, fontWeight: FontWeight.bold, color: const Color(0xFF1E90FF))
                            ),
                            const SizedBox(height: 20),
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey.shade300,
                              color: const Color(0xFF1E90FF),
                              minHeight: 10,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            const SizedBox(height: 5),
                            Text('${(progress * 100).toStringAsFixed(0)}% Concluído', style: GoogleFonts.poppins(fontSize: 14.0, color: Colors.black54)),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40.0),
                      
                      // Botões de Ação
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Contribuicao(cofreId: widget.cofreId)), 
                          ).then((_) => _carregarDados()); // Recarrega ao voltar
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
                          Expanded(child: _buildInfoCard(title: 'Valor Alvo', value: _currencyFormat.format(valorAlvo), icon: Icons.flag)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildInfoCard(title: 'Restante', value: _currencyFormat.format(valorRestante), icon: Icons.trending_down)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      
                      Row(
                        children: [
                          Expanded(child: _buildInfoCard(
                            title: 'Início da Viagem', 
                            value: cofre.dataViagem != null ? _dateFormat.format(cofre.dataViagem!) : '---', 
                            icon: Icons.calendar_today)
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: _buildInfoCard(title: 'Código de Acesso', value: cofre.joinCode, icon: Icons.lock_open)),
                        ],
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






// Esta é uma tela temporária só para testar a navegação da Home
/*
class CofreScreen extends StatelessWidget {
  final String cofreId;

  const CofreScreen({super.key, required this.cofreId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalhes (Em Construção)")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 60, color: Colors.orange),
            const SizedBox(height: 20),
            Text("Você clicou no cofre ID:\n$cofreId", textAlign: TextAlign.center),
            const SizedBox(height: 20),
            const Text("Fase 3: Implementaremos esta tela a seguir!"),
          ],
        ),
      ),
    );
  }
}
*/
