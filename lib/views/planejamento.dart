// Imports essenciais
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// Stores e Models
import 'package:travelbox/stores/detalhesCofreStore.dart';
import 'package:travelbox/models/enums/categoriaDespesa.dart'; // Enum atualizado
import 'package:travelbox/models/despesa.dart';
import 'package:travelbox/models/enums/tipoDespesa.dart';



// Utils e Views
import 'package:travelbox/utils/feedbackHelper.dart';
import 'package:travelbox/utils/currency_input_formatter.dart'; // Seu formatador mágico
import 'package:travelbox/views/modules/header.dart';
import 'package:travelbox/views/modules/footbar.dart';

class PlanejamentoScreen extends StatefulWidget {
  final String cofreId;
  const PlanejamentoScreen({super.key, required this.cofreId});

  @override
  State<PlanejamentoScreen> createState() => _PlanejamentoScreenState();
}

class _PlanejamentoScreenState extends State<PlanejamentoScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);

  // --- Função para Adicionar Nova Estimativa (Dialog) ---
  void _mostrarDialogoAdicionar(BuildContext context) {
    final tituloController = TextEditingController();
    final valorController = TextEditingController(text: "R\$ 0,00");
    CategoriaDespesa categoriaSelecionada = CategoriaDespesa.outros;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Nova Estimativa", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Titulo
            TextField(
              controller: tituloController,
              decoration: InputDecoration(
                labelText: "O que é? (Ex: Hotel)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 10),
            
            // Valor
            TextField(
              controller: valorController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
              decoration: InputDecoration(
                labelText: "Valor Estimado",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 10),

            // Categoria (Dropdown)
            DropdownButtonFormField<CategoriaDespesa>(
              value: categoriaSelecionada,
              decoration: InputDecoration(
                labelText: "Categoria",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: CategoriaDespesa.values.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  // Aqui usamos .name e capitalizamos a primeira letra, ou criamos um helper 'nome' no enum
                  child: Text(cat.name.toUpperCase()), 
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) categoriaSelecionada = val;
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E90FF)),
            onPressed: () async {
              // 1. Tratamento do Valor
              final valorRaw = valorController.text.replaceAll(RegExp(r'[^0-9]'), '');
              if (valorRaw.isEmpty) return;
              final double valorFinal = double.parse(valorRaw) / 100;

              if (tituloController.text.isEmpty || valorFinal <= 0) {
                FeedbackHelper.mostrarErro(context, "Preencha o título e um valor válido.");
                return;
              }

              // 2. Salvar no Store
              final store = context.read<DetalhesCofreStore>();
              Navigator.pop(ctx); // Fecha o dialog antes de chamar o async

              bool sucesso = await store.adicionarDespesaPlanejada(
                titulo: tituloController.text.trim(),
                valor: valorFinal,
                categoria: categoriaSelecionada,
              );

              if (mounted) {
                if (sucesso) {
                  FeedbackHelper.mostrarSucesso(context, "Estimativa adicionada!");
                } else {
                  FeedbackHelper.mostrarErro(context, store.errorMessage);
                }
              }
            },
            child: const Text("Adicionar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- Widget Card de Resumo (A Lógica da Mensalidade) ---
  Widget _buildSummaryCard(DetalhesCofreStore store) {
    double total = store.totalPlanejado;
    double mensalidade = store.sugestaoMensal; // Usa o cálculo inteligente que fizemos

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total Planejado", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                  Text(_currencyFormat.format(total), style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
              const Icon(Icons.assignment_outlined, size: 30, color: Color(0xFF1E90FF)),
            ],
          ),
          const Divider(height: 30),
          Row(
            children: [
              const Icon(Icons.savings_outlined, color: Colors.green),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Sugestão por Pessoa:", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                    Text(
                      "${_currencyFormat.format(mensalidade)} /mês",
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DetalhesCofreStore>();
    final listaPlanejada = store.despesasPlanejadas; // Getter filtrado que criamos

    return Scaffold(
      backgroundColor: const Color(0xFF1E90FF),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0), // 80px deve ser suficiente para ficar acima da Footbar
        child: FloatingActionButton(
          onPressed: () => _mostrarDialogoAdicionar(context),
          backgroundColor: Colors.amber,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          const Header(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF4F9FB),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 0),
                child: Column(
                  children: [
                    Text('Planejamento', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    
                    // Resumo Financeiro
                    _buildSummaryCard(store),

                    // Lista de Itens
                    Expanded(
                      child: listaPlanejada.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.list_alt, size: 50, color: Colors.grey[300]),
                                  const SizedBox(height: 10),
                                  Text("Nenhuma despesa planejada.", style: GoogleFonts.poppins(color: Colors.grey)),
                                  Text("Toque no + para adicionar.", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 80), // Espaço para o FAB
                              itemCount: listaPlanejada.length,
                              itemBuilder: (context, index) {
                                final item = listaPlanejada[index];
                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.only(bottom: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blue.shade50,
                                      child: Icon(Icons.label_outline, color: Colors.blue),
                                    ),
                                    title: Text(item.titulo, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                    subtitle: Text(item.categoria.name.toUpperCase(), style: const TextStyle(fontSize: 10)),
                                    trailing: Text(
                                      _currencyFormat.format(item.valor),
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
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