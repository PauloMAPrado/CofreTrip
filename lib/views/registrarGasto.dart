import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:travelbox/stores/detalhesCofreStore.dart';
import 'package:travelbox/stores/authStore.dart'; // Para saber quem sou eu (default)
import 'package:travelbox/models/enums/categoriaDespesa.dart';
import 'package:travelbox/utils/feedbackHelper.dart';
import 'package:travelbox/utils/currency_input_formatter.dart';
import 'package:travelbox/views/modules/header.dart';
import 'package:travelbox/views/modules/footbar.dart';

class RegistrarGasto extends StatefulWidget {
  const RegistrarGasto({super.key});

  @override
  State<RegistrarGasto> createState() => _RegistrarGastoState();
}

class _RegistrarGastoState extends State<RegistrarGasto> {
  final _tituloController = TextEditingController();
  final _valorController = TextEditingController(text: "R\$ 0,00");
  final _dataController = TextEditingController(text: DateFormat('dd/MM/yyyy').format(DateTime.now()));
  
  CategoriaDespesa _categoriaSelecionada = CategoriaDespesa.alimentacao;
  String? _pagadorSelecionado; // ID de quem pagou

  @override
  void initState() {
    super.initState();
    // Tenta pré-selecionar o usuário logado como pagador
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final meuId = context.read<AuthStore>().usuario?.id;
      if (meuId != null) {
        setState(() {
          _pagadorSelecionado = meuId;
        });
      }
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dataController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  void _salvar() async {
    FocusScope.of(context).unfocus();
    
    // Validações
    final valorRaw = _valorController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (valorRaw.isEmpty) return;
    final double valorFinal = double.parse(valorRaw) / 100;

    if (_tituloController.text.isEmpty || valorFinal <= 0 || _pagadorSelecionado == null) {
      FeedbackHelper.mostrarErro(context, "Preencha todos os campos e selecione quem pagou.");
      return;
    }

    final store = context.read<DetalhesCofreStore>();
    
    bool sucesso = await store.adicionarDespesaReal(
      titulo: _tituloController.text.trim(),
      valor: valorFinal,
      categoria: _categoriaSelecionada,
      pagoPorId: _pagadorSelecionado!,
      data: DateFormat('dd/MM/yyyy').parse(_dataController.text),
    );

    if (mounted) {
      if (sucesso) {
        FeedbackHelper.mostrarSucesso(context, "Gasto registrado!");
        Navigator.pop(context);
      } else {
        FeedbackHelper.mostrarErro(context, store.errorMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DetalhesCofreStore>();
    final membros = store.membros;
    final mapUsuarios = store.contribuidoresMap;
    final isLoading = store.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF1E90FF),
      body: Column(
        children: [
          const Header(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Text('Registrar Gasto', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 30),

                    // Título
                    TextField(
                      controller: _tituloController,
                      decoration: InputDecoration(labelText: "Descrição (Ex: Jantar)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                    ),
                    const SizedBox(height: 15),

                    // Valor
                    TextField(
                      controller: _valorController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
                      decoration: InputDecoration(labelText: "Valor Total", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                    ),
                    const SizedBox(height: 15),

                    // Data
                    GestureDetector(
                      onTap: _selectDate,
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _dataController,
                          decoration: InputDecoration(labelText: "Data", prefixIcon: const Icon(Icons.calendar_today), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // QUEM PAGOU? (Dropdown dos Membros)
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Quem Pagou?', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                      value: _pagadorSelecionado,
                      items: membros.map((m) {
                        final user = mapUsuarios[m.idUsuario];
                        return DropdownMenuItem(
                          value: m.idUsuario,
                          child: Text(user?.nome ?? "Desconhecido"),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _pagadorSelecionado = val),
                    ),
                    const SizedBox(height: 15),

                    // Categoria
                    DropdownButtonFormField<CategoriaDespesa>(
                      decoration: InputDecoration(labelText: 'Categoria', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                      value: _categoriaSelecionada,
                      items: CategoriaDespesa.values.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat.name.toUpperCase()));
                      }).toList(),
                      onChanged: (val) => setState(() => _categoriaSelecionada = val!),
                    ),
                    const SizedBox(height: 30),

                    // Botão
                    ElevatedButton(
                      onPressed: isLoading ? null : _salvar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent, // Vermelho para indicar gasto
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('Confirmar Gasto', style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
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