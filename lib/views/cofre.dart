import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:travelbox/views/contribuicao.dart';
import 'package:travelbox/views/modules/footbar.dart';
import 'package:travelbox/views/modules/header.dart';
import 'package:travelbox/views/historicoContr.dart';
import 'package:travelbox/views/listaUser.dart';
import 'package:travelbox/models/cofre.dart' as CofreModel;

// Importe o seu modelo de dados e o provider de detalhes
import '../controllers/detalhesCofreProvider.dart';

class Cofre extends StatefulWidget { // Mantenha como StatefulWidget para initState
  final String cofreId; 
  
  const Cofre({super.key, required this.cofreId});

  @override
  State<Cofre> createState() => _CofreState();
}

class _CofreState extends State<Cofre> {
  // --- Formatação de Moeda e Data ---
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR', 
    symbol: 'R\$',
    decimalDigits: 2,
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
  void _carregarDados() {
    // Chama o método no Provider, passando o ID
    Provider.of<DetalhesCofreProvider>(context, listen: false)
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
    // 🎯 LÊ O ESTADO: Escuta as mudanças no estado do cofre
    final detalhesProvider = context.watch<DetalhesCofreProvider>();
    final CofreModel.Cofre? cofre = detalhesProvider.cofreAtivo;
    final bool isLoading = detalhesProvider.isLoading;
    final String? errorMessage = detalhesProvider.errorMessage;

    // --- Tratamento de Estados (Carregando / Erro) ---
    if (isLoading && cofre == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (errorMessage != null || cofre == null) {
      return Scaffold(body: Center(child: Text(errorMessage ?? 'Cofre não encontrado ou erro de acesso.', style: GoogleFonts.poppins())));
    }
    
    // --- Estrutura de Dados Dinâmicos ---
    // Os dados são lidos diretamente do cofreAtivo e do totalArrecadado
    final double valorAlvo = cofre.valorPlano.toDouble(); 
    final double valorArrecadado = detalhesProvider.totalArrecadado;
    
    // Cálculos e Formatação
    double progress = (valorAlvo != 0) ? (valorArrecadado / valorAlvo) : 0.0;
    if (progress > 1.0) progress = 1.0;
    double valorRestante = valorAlvo - valorArrecadado;

    String valorAtualFormatado = _currencyFormat.format(valorArrecadado);
    String valorAlvoFormatado = _currencyFormat.format(valorAlvo);
    String dataInicioFormatada = _dateFormat.format(cofre.dataViagem!); // Usando dataViagem do model
    String valorRestanteFormatado = _currencyFormat.format(valorRestante.clamp(0.0, double.infinity));
    String codigoAcesso = cofre.joinCode; // Código de Acesso real
    

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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 30.0),
                      
                      // 1. NOME DO COFRE (Dados Reais)
                      Text(cofre.nome, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 22.0, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 0, 0, 0))),
                      const SizedBox(height: 30.0),
                      
                      // 2. PROGRESSO E SALDO (Dados Reais)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                        ),
                        child: Column(
                          children: [
                            Text('Meta: ${valorAlvoFormatado}', style: GoogleFonts.poppins(fontSize: 16.0)),
                            const SizedBox(height: 10),
                            Text('Arrecadado: ${valorAtualFormatado}', style: GoogleFonts.poppins(fontSize: 20.0, fontWeight: FontWeight.bold, color: const Color(0xFF1E90FF))),
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
                      
                      // 3. BOTÃO ADICIONAR CONTRIBUIÇÃO 
                      ElevatedButton(
                        onPressed: isLoading ? null : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              // Passa o ID para a tela de Contribuição
                              builder: (context) => Contribuicao(cofreId: widget.cofreId), 
                            ),
                          ).then((_) {
                            // Recarrega os dados ao voltar, garantindo que o saldo seja atualizado.
                            _carregarDados();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 255, 187, 0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: Text('Adicionar Contribuição', style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
                      ),
                      
                      const SizedBox(height: 20.0),

                      // 4. BOTÃO VISUALIZAR PARTICIPANTES
                      ElevatedButton(
                        onPressed: isLoading ? null : () {
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
                      
                      // 5. INFORMAÇÕES SECUNDÁRIAS (GRID)
                      Row(
                        children: [
                          Expanded(child: _buildInfoCard(title: 'Valor Alvo', value: valorAlvoFormatado, icon: Icons.flag)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildInfoCard(title: 'Restante', value: valorRestanteFormatado, icon: Icons.trending_down)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      
                      Row(
                        children: [
                          Expanded(child: _buildInfoCard(title: 'Início da Viagem', value: dataInicioFormatada, icon: Icons.calendar_today)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildInfoCard(title: 'Código de Acesso', value: codigoAcesso, icon: Icons.lock_open)),
                        ],
                      ),

                      const SizedBox(height: 50.0),
                      
                      // 6. BOTÃO HISTÓRICO DE CONTRIBUIÇÕES
                      ElevatedButton(
                        onPressed: isLoading ? null : () {
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