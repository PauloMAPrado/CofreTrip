import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:travelbox/views/modules/header.dart';
import 'package:travelbox/views/modules/footbar.dart';
import 'package:travelbox/stores/detalhesCofreStore.dart';


class Historicocontr extends StatelessWidget { // Transformei em Stateless (Store já tem os dados)
  final String cofreId; 

  const Historicocontr({super.key, required this.cofreId});

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

    // Lendo do Store
    final detalhesStore = context.watch<DetalhesCofreStore>();
    final contribuicoes = detalhesStore.contribuicoes;
    final contribuidoresMap = detalhesStore.contribuidoresMap;
    final nomeCofre = detalhesStore.cofreAtivo?.nome ?? 'Detalhes';

    return Scaffold(
      backgroundColor: const Color(0xFF1E90FF),
      body: Column(
        children: [
          const Header(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(color: Color(0xFFF4F9FB), borderRadius: BorderRadius.only(topLeft: Radius.circular(50.0), topRight: Radius.circular(50.0))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 30.0),
                    Text('Extrato', style: GoogleFonts.poppins(fontSize: 22.0, fontWeight: FontWeight.bold)),
                    Text(nomeCofre, style: GoogleFonts.poppins(fontSize: 16.0, color: Colors.grey)),
                    const SizedBox(height: 20.0),

                    // LISTA
                    Expanded(
                      child: contribuicoes.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.receipt_long, size: 60, color: Colors.grey[300]),
                                  const Text('Nenhuma transação ainda.'),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: contribuicoes.length,
                              itemBuilder: (context, index) {
                                final contr = contribuicoes[index];
                                final usuario = contribuidoresMap[contr.idUsuario];
                                final nomeUser = usuario?.nome ?? 'Usuário Desconhecido';

                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.only(bottom: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.green.shade100,
                                      child: Icon(Icons.arrow_downward, color: Colors.green.shade700),
                                    ),
                                    title: Text(nomeUser, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                                    subtitle: Text(dateFormat.format(contr.data)),
                                    trailing: Text(
                                      currencyFormat.format(contr.valor),
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.green[800], fontSize: 16),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    
                    // RODAPÉ COM TOTAL
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total Geral:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                          Text(currencyFormat.format(detalhesStore.totalArrecadado), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF1E90FF), fontSize: 18)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
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