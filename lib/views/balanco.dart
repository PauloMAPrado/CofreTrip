import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:travelbox/stores/detalhesCofreStore.dart';
import 'package:travelbox/views/registrarGasto.dart';
import 'package:travelbox/views/modules/header.dart';
import 'package:travelbox/views/modules/footbar.dart';

class BalancoScreen extends StatelessWidget {
  const BalancoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DetalhesCofreStore>();
    final despesasReais = store.despesasReais;
    final saldos = store.mapaDeSaldos;
    final mapUsuarios = store.contribuidoresMap;
    
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      backgroundColor: const Color(0xFF1E90FF),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistrarGasto())),
          backgroundColor: Colors.redAccent,
          icon: const Icon(Icons.receipt, color: Colors.white),
          label: const Text("Novo Gasto", style: TextStyle(color: Colors.white)),
        ),
      ),
      body: Column(
        children: [
          const Header(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(color: Color(0xFFF4F9FB), borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50))),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 0),
                child: Column(
                  children: [
                    Text('Balanço da Viagem', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),

                    // --- CARD DE QUEM DEVE QUEM ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Acerto de Contas", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Divider(),
                          if (saldos.isEmpty)
                            const Padding(padding: EdgeInsets.all(8.0), child: Text("Sem dados ainda.")),
                          
                          ...saldos.entries.map((entry) {
                            final userId = entry.key;
                            final saldo = entry.value;
                            final nome = mapUsuarios[userId]?.nome ?? "Membro";
                            
                            // Se saldo for muito próximo de zero (erro de arredondamento), ignora
                            if (saldo.abs() < 0.01) return const SizedBox.shrink();

                            final bool aReceber = saldo > 0;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(nome, style: GoogleFonts.poppins()),
                                  Text(
                                    aReceber ? "Recebe ${currencyFormat.format(saldo)}" : "Deve ${currencyFormat.format(saldo.abs())}",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      color: aReceber ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    Align(alignment: Alignment.centerLeft, child: Text("Histórico de Gastos", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold))),
                    
                    // --- LISTA DE GASTOS ---
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: despesasReais.length,
                        itemBuilder: (context, index) {
                          final despesa = despesasReais[index];
                          final pagador = mapUsuarios[despesa.pagoPorId]?.nome ?? "Alguém";
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: const CircleAvatar(backgroundColor: Colors.redAccent, child: Icon(Icons.shopping_bag, color: Colors.white)),
                              title: Text(despesa.titulo, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                              subtitle: Text("$pagador pagou em ${DateFormat('dd/MM').format(despesa.data!)}"),
                              trailing: Text(currencyFormat.format(despesa.valor), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.red)),
                            ),
                          );
                        },
                      ),
                    ),
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