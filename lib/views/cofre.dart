import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelbox/views/contribuicao.dart';
import 'package:travelbox/views/modules/footbar.dart';
import 'package:travelbox/views/modules/header.dart';
import 'package:intl/intl.dart';
import 'package:travelbox/views/historicoContr.dart';
import 'package:travelbox/views/listaUser.dart';

// TODO: Importe seu Model e seu Provider/Gerenciador de Estado aqui
// ex: import 'package:travelbox/models/cofre_model.dart';
// ex: import 'package:provider/provider.dart';

class Cofre extends StatelessWidget {
  // 1. O Construtor agora é limpo, sem parâmetros de dados
  Cofre({super.key});

  // --- Formatação de Moeda e Data ---
  // (Movidos para dentro do build ou podem ficar aqui se preferir)
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR', 
    symbol: 'R\$',
    decimalDigits: 2,
  );

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  // --- Widgets de Informação Reutilizáveis ---
  // (Este método auxiliar continua igual)
  Widget _buildInfoCard({required String title, required String value, required IconData icon}) {
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
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
          
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    var cofreModel = {
      'cofreNome': 'Viagem (Exemplo)',
      'valorAtual': 100.0,
      'valorAlvo': 1000.0,
      'dataInicio': DateTime.now(),
      'codigoAcesso': 'XYZ987'
    };
    // NOTA: Use seu model tipado, ex: final CofreModel cofreModel = ...


    // 3. LÓGICA DE FRONT-END (Cálculos de exibição)
    // Agora usando 'cofreModel' ao invés de 'widget.'
    double valorAtual = cofreModel['valorAtual'] as double;
    double valorAlvo = cofreModel['valorAlvo'] as double;
    DateTime dataInicio = cofreModel['dataInicio'] as DateTime;

    double progress = (valorAtual / valorAlvo).clamp(0.0, 1.0);
    double valorRestante = valorAlvo - valorAtual;
    
    String valorAtualFormatado = _currencyFormat.format(valorAtual);
    String valorAlvoFormatado = _currencyFormat.format(valorAlvo);
    String dataInicioFormatada = _dateFormat.format(dataInicio);
    String valorRestanteFormatado = _currencyFormat.format(valorRestante.clamp(0.0, double.infinity));


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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 30.0),
                    // TÍTULO DO COFRE (vindo do model)
                    Text(
                      cofreModel['cofreNome'] as String, // 4. Usando o model
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // SALDO ATUAL
                    _buildInfoCard(
                      title: 'Saldo Atual',
                      value: valorAtualFormatado, // 4. Usando o model
                      icon: Icons.account_balance_wallet,
                    ),
                    
                    const SizedBox(height: 20),

                    // --- VISUALIZAÇÃO DE PROGRESSO DO COFRE ---
                    Center(
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: Stack(
                          children: [
                            ClipRect(
                              child: Align(
                                alignment: Alignment.topCenter, 
                                heightFactor: progress, // 4. Usando o model
                                child: const Icon(
                                  Icons.savings,
                                  size: 100,
                                  color: Color(0xFF1E90FF),
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.savings,
                              size: 100,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Texto de porcentagem
                    Text(
                      '${(progress * 100).toStringAsFixed(1)}% da Meta alcançada', // 4. Usando o model
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E90FF)),
                    ),
                    const SizedBox(height: 20.0),

                    // Botão para adicionar contribuições
                    ElevatedButton(
                      onPressed: () {
                        // Redirecionar para tela de pagamento
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Contribuicao()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E90FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: Text(
                        'Adicionar Contribuição',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    ElevatedButton(
                      onPressed: () {
                        //Redirecionar para a tela de lista de usuários
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ListaUser()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 255, 187, 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: Text(
                        'Visualizar Participantes',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    
                    // INFORMAÇÕES SECUNDÁRIAS (GRID)
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            title: 'Valor Alvo',
                            value: valorAlvoFormatado, // 4. Usando o model
                            icon: Icons.flag,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildInfoCard(
                            title: 'Restante',
                            value: valorRestanteFormatado, // 4. Usando o model
                            icon: Icons.trending_down,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            title: 'Início da Viagem',
                            value: dataInicioFormatada, // 4. Usando o model
                            icon: Icons.calendar_today,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildInfoCard(
                            title: 'Código de Acesso',
                            value: cofreModel['codigoAcesso'] as String, // 4. Usando o model
                            icon: Icons.lock_open,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // BOTÃO PRINCIPAL (Adicionar/Ver Itens)
                    ElevatedButton(
                      onPressed: () {
                        // acesso para a tela de Histórico de Contribuições
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Historicocontr()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E90FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: Text(
                        'Histórico de Contribuições',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
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