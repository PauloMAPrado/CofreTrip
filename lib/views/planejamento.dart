import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// Imports do Projeto
import 'package:travelbox/stores/detalhesCofreStore.dart';
import 'package:travelbox/models/despesa.dart';
import 'package:travelbox/models/enums/categoriaDespesa.dart';
import 'package:travelbox/models/enums/tipoDespesa.dart';
import 'package:travelbox/utils/feedbackHelper.dart';
import 'package:travelbox/utils/currency_input_formatter.dart';
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

  // --- Diálogo Unificado (Criar ou Editar) ---
  void _mostrarDialogoFormulario(BuildContext context, {Despesa? despesaParaEditar}) {
    final isEditing = despesaParaEditar != null;
    
    final tituloController = TextEditingController(text: isEditing ? despesaParaEditar.titulo : "");
    // Se estiver editando, já formata o valor atual
    final valorInicial = isEditing ? _currencyFormat.format(despesaParaEditar.valor) : "R\$ 0,00";
    final valorController = TextEditingController(text: valorInicial);
    
    CategoriaDespesa categoriaSelecionada = isEditing ? despesaParaEditar.categoria : CategoriaDespesa.outros;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? "Editar Estimativa" : "Nova Estimativa", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tituloController,
              decoration: InputDecoration(
                labelText: "O que é? (Ex: Hotel)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 10),
            
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

            DropdownButtonFormField<CategoriaDespesa>(
              value: categoriaSelecionada,
              decoration: InputDecoration(
                labelText: "Categoria",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: CategoriaDespesa.values.map((cat) {
                return DropdownMenuItem(
                  value: cat,
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
              // Tratamento do Valor
              final valorRaw = valorController.text.replaceAll(RegExp(r'[^0-9]'), '');
              if (valorRaw.isEmpty) return;
              final double valorFinal = double.parse(valorRaw) / 100;

              if (tituloController.text.isEmpty || valorFinal <= 0) {
                FeedbackHelper.mostrarErro(context, "Preencha o título e um valor válido.");
                return;
              }

              final store = context.read<DetalhesCofreStore>();
              Navigator.pop(ctx); 

              bool sucesso;
              
              if (isEditing) {
                // MODO EDIÇÃO: Atualiza o objeto existente
                // Usamos um novo construtor ou copyWith (se tiver) para manter o ID
                Despesa editada = Despesa(
                  id: despesaParaEditar.id, // IMPORTANTE: Manter o ID
                  idCofre: despesaParaEditar.idCofre,
                  titulo: tituloController.text.trim(),
                  valor: valorFinal,
                  tipo: TipoDespesa.planejada,
                  categoria: categoriaSelecionada,
                  // Campos de data/pagador mantêm-se nulos pois é planejamento
                );
                sucesso = await store.editarDespesa(editada);
              } else {
                // MODO CRIAÇÃO
                sucesso = await store.adicionarDespesaPlanejada(
                  titulo: tituloController.text.trim(),
                  valor: valorFinal,
                  categoria: categoriaSelecionada,
                );
              }

              if (mounted) {
                if (sucesso) {
                  FeedbackHelper.mostrarSucesso(context, isEditing ? "Atualizado com sucesso!" : "Adicionado com sucesso!");
                } else {
                  FeedbackHelper.mostrarErro(context, store.errorMessage);
                }
              }
            },
            child: Text(isEditing ? "Salvar" : "Adicionar", style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- Função de Confirmação de Exclusão ---
  void _confirmarExclusao(BuildContext context, Despesa despesa) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Excluir Item?"),
        content: Text("Tem certeza que deseja remover '${despesa.titulo}' do planejamento?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final store = context.read<DetalhesCofreStore>();
              bool sucesso = await store.removerDespesa(despesa.id!);
              
              if (mounted && sucesso) {
                 FeedbackHelper.mostrarSucesso(context, "Item removido.");
              }
            },
            child: const Text("Excluir", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(DetalhesCofreStore store) {
    double total = store.totalPlanejado;
    double mensalidade = store.sugestaoMensal;

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
    final listaPlanejada = store.despesasPlanejadas;

    return Scaffold(
      backgroundColor: const Color(0xFF1E90FF),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton(
          onPressed: () => _mostrarDialogoFormulario(context), // Modo Criação (sem parâmetro)
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
                    
                    _buildSummaryCard(store),

                    Expanded(
                      child: listaPlanejada.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.list_alt, size: 50, color: Colors.grey[300]),
                                  const SizedBox(height: 10),
                                  Text("Nenhuma despesa planejada.", style: GoogleFonts.poppins(color: Colors.grey)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 80),
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
                                    
                                    // PREÇO E BOTÕES
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _currencyFormat.format(item.valor),
                                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                        // MENU DE OPÇÕES (Editar/Excluir)
                                        PopupMenuButton<String>(
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              _mostrarDialogoFormulario(context, despesaParaEditar: item);
                                            } else if (value == 'delete') {
                                              _confirmarExclusao(context, item);
                                            }
                                          },
                                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                            const PopupMenuItem<String>(
                                              value: 'edit',
                                              child: Row(children: [Icon(Icons.edit, size: 18, color: Colors.blue), SizedBox(width: 8), Text('Editar')]),
                                            ),
                                            const PopupMenuItem<String>(
                                              value: 'delete',
                                              child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Excluir')]),
                                            ),
                                          ],
                                        ),
                                      ],
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