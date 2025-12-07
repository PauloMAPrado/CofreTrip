// lib/views/Saldos.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../stores/despesaStore.dart';
import '../stores/detalhesCofreStore.dart'; // Para obter nomes dos usuários
import '../models/usuario.dart';
import 'modules/header.dart';
import 'modules/footbar.dart';

class Saldos extends StatefulWidget {
  final String cofreId;
  const Saldos({super.key, required this.cofreId});
  
  @override
  State<Saldos> createState() => _SaldosState();
}

class _SaldosState extends State<Saldos> {
  // Formatador
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR', 
    symbol: 'R\$ ', 
    decimalDigits: 2
  );

  @override
  void initState() {
    super.initState();
    // 💡 IMPORTANTE: Força o carregamento das despesas ao entrar na tela.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DespesaProvider>(context, listen: false)
          .carregarDespesas(widget.cofreId);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Escuta os dados
    final despesaProvider = context.watch<DespesaProvider>();
    final detalhesStore = context.watch<DetalhesCofreStore>();
    
    // Obtém o resultado do cálculo
    final Map<String, double> saldos = despesaProvider.saldosFinais;
    final Map<String, Usuario> perfis = detalhesStore.contribuidoresMap; // Mapa de nomes
    
    // Filtra saldos não-zerados para exibir quem tem algo para acertar
    final List<MapEntry<String, double>> saldosAExibir = saldos.entries
        .where((entry) => entry.value.abs() > 0.01) // Ignora valores próximos de zero
        .toList();

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
                borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text('Saldos e Acertos', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                  despesaProvider.isLoading 
                      ? const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                      : saldosAExibir.isEmpty && despesaProvider.despesas.isNotEmpty
                          ? const Center(child: Text('Nenhum saldo pendente. Tudo acertado!'))
                          : saldosAExibir.isEmpty && despesaProvider.despesas.isEmpty
                              ? const Center(child: Text('Nenhuma despesa registrada neste cofre.'))
                              : Expanded(
                                  child: ListView.builder(
                                    itemCount: saldosAExibir.length,
                                    itemBuilder: (context, index) {
                                      final saldoEntry = saldosAExibir[index];
                                      final String userId = saldoEntry.key;
                                      final double valor = saldoEntry.value; // Positivo (recebe) ou Negativo (deve)
                                      final Usuario? user = perfis[userId];
                                      
                                      final String nome = user?.nome ?? 'Usuário Desconhecido';
                                      final bool isCredit = valor > 0;
                                      final String status = isCredit ? 'RECEBE' : 'DEVE';
                                      final Color cor = isCredit ? Colors.green.shade600 : Colors.red.shade600;
                                      final String valorFormatado = _currencyFormat.format(valor.abs());

                                      return ListTile(
                                        leading: CircleAvatar(child: Text(nome[0])),
                                        title: Text(nome, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                                        subtitle: Text(status, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: cor)),
                                        trailing: Text(
                                          valorFormatado, 
                                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: cor, fontSize: 16)
                                        ),
                                      );
                                    },
                                  ),
                                ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          const Footbarr(),
        ],
      ),
    );
  }
}