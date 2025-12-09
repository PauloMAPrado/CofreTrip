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

  // Função auxiliar para confirmar pagamento
  void _confirmarPagamento(BuildContext context, DetalhesCofreStore store, String devedorId, double valor, String nome) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Quitar Dívida de $nome"),
        content: Text("Confirma que $nome pagou R\$ ${valor.toStringAsFixed(2)}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              Navigator.pop(ctx);
              await store.quitarDivida(devedorId, valor);
            },
            child: const Text("Confirmar Pagamento", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    final store = context.watch<DetalhesCofreStore>();
    final despesasReais = store.despesasReais;
    final saldos = store.mapaDeSaldos;
    final mapUsuarios = store.contribuidoresMap;
    final bool isFinalizado = store.isCofreFinalizado;
    
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    

    return Scaffold(
      backgroundColor: const Color(0xFF1E90FF),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: isFinalizado 
          ? null 
          : FloatingActionButton.extended(
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
                    Text(
                      'Balanço da Viagem', 
                      style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)
                    ),
                    const SizedBox(height: 10),
                    
                    // --- STATUS INFORMATIVO (NOVO) ---
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isFinalizado ? Colors.red.shade100 : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isFinalizado ? Colors.red : Colors.green),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isFinalizado ? Icons.lock : Icons.lock_open, 
                            size: 16, 
                            color: isFinalizado ? Colors.red : Colors.green
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isFinalizado ? "Viagem Encerrada - Apenas Acertos" : "Viagem Aberta - Gastos Permitidos",
                            style: GoogleFonts.poppins(
                              fontSize: 12, 
                              color: isFinalizado ? Colors.red.shade800 : Colors.green.shade800,
                              fontWeight: FontWeight.w600
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- CARD DE SALDOS ---
                    // (O restante do arquivo continua igual ao anterior...)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Acerto de Contas", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Divider(),
                          if (saldos.isEmpty) const Padding(padding: EdgeInsets.all(8.0), child: Text("Sem dados ainda.")),
                          
                          ...saldos.entries.map((entry) {
                            final userId = entry.key;
                            final saldo = entry.value;
                            final nome = mapUsuarios[userId]?.nome ?? "Membro";
                            
                            if (saldo.abs() < 0.01) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                       Text(nome, style: GoogleFonts.poppins(color: Colors.grey)),
                                       const Text("Quitado ✅", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                );
                            }

                            final bool aReceber = saldo > 0;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(nome, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                                  Row(
                                    children: [
                                      Text(
                                        aReceber ? "Recebe ${currencyFormat.format(saldo)}" : "Deve ${currencyFormat.format(saldo.abs())}",
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: aReceber ? Colors.green : Colors.red),
                                      ),
                                      
                                      // BOTÃO QUITAR (Mantido)
                                      if (isFinalizado && !aReceber) 
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0),
                                          child: SizedBox(
                                            height: 30,
                                            child: ElevatedButton(
                                              onPressed: () => _confirmarPagamento(context, store, userId, saldo.abs(), nome),
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 10)),
                                              child: const Text("Pagar", style: TextStyle(fontSize: 12, color: Colors.white)),
                                            ),
                                          ),
                                        )
                                    ],
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