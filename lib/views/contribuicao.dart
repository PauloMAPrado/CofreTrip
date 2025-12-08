import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; 
import 'package:travelbox/utils/currency_input_formatter.dart'; 

import 'package:travelbox/views/modules/footbar.dart';
import 'package:travelbox/views/modules/header.dart';
import 'package:travelbox/utils/feedbackHelper.dart'; 

import 'package:travelbox/stores/detalhesCofreStore.dart'; 
import 'package:travelbox/stores/authStore.dart'; 

class Contribuicao extends StatefulWidget {
  final String cofreId;
  const Contribuicao({super.key, required this.cofreId});

  @override
  _ContribuicaoState createState() => _ContribuicaoState();
}

class _ContribuicaoState extends State<Contribuicao> {
  final TextEditingController _valorController = TextEditingController(text: "R\$ 0,00");
  final TextEditingController _dataController = TextEditingController();
  String? _formaPagamentoSelecionada; 
  
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    // Pré-preenche a data com hoje
    _dataController.text = _dateFormat.format(DateTime.now());
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(), 
      helpText: 'Selecione a Data da Contribuição',
    );
    if (picked != null) {
      _dataController.text = _dateFormat.format(picked);
    }
  }

  void _handleFazerContribuicao() async {
    // 1. Validação Visual
    final valorRaw = _valorController.text.trim();
    final dataRaw = _dataController.text.trim();

    if (valorRaw.isEmpty || dataRaw.isEmpty || _formaPagamentoSelecionada == null) {
      FeedbackHelper.mostrarErro(context, 'Preencha o valor, a data e a forma de pagamento.');
      return;
    }
    
    // 2. Tratamento do Valor (Remove R$ e pontuação)
    final cleanValor = valorRaw.replaceAll(RegExp(r'[^0-9]'), ''); 
    if (cleanValor.isEmpty) return;
    
    final double valorContribuicao = double.parse(cleanValor) / 100;

    if (valorContribuicao <= 0) {
      FeedbackHelper.mostrarErro(context, 'Insira um valor válido maior que R\$ 0,00.');
      return;
    }

    // 3. Acesso aos Stores
    final detalhesStore = context.read<DetalhesCofreStore>();
    final authStore = context.read<AuthStore>();

    if (authStore.usuario?.id == null) {
        FeedbackHelper.mostrarErro(context, 'Erro de sessão. Faça login novamente.');
        return;
    }
    
    // 4. Execução
    bool sucesso = await detalhesStore.adicionarContribuicao(
        cofreId: widget.cofreId,
        usuarioId: authStore.usuario!.id!,
        valor: valorContribuicao,
        data: DateTime.parse(dataRaw),
    );
    
    if (!mounted) return;

    if (sucesso) {
        FeedbackHelper.mostrarSucesso(context, 'Contribuição de R\$${valorContribuicao.toStringAsFixed(2)} registrada!');
        Navigator.pop(context); 
    } else {
        FeedbackHelper.mostrarErro(context, detalhesStore.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Loading Global do Store
    final detalhesStore = context.watch<DetalhesCofreStore>();
    final bool isLoading = detalhesStore.isLoading;
    
    // Pegamos a sugestão calculada
    final double sugestao = detalhesStore.sugestaoMensal;

    return Scaffold(
      backgroundColor: const Color(0xFF1E90FF),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Header(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40.0),
                      Text('Nova Contribuição', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 20.0, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 30.0),
                      
                      // CAMPO VALOR
                      TextField(
                        controller: _valorController,
                        enabled: !isLoading,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CurrencyInputFormatter(),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Valor', 
                          prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF1E90FF)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))
                        ),
                      ),
                      
                      // 👇👇 RECOMENDAÇÃO INTELIGENTE 👇👇
                      if (sugestao > 0) ...[
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            // Ao clicar, preenche o campo com a sugestão
                            _valorController.text = _currencyFormat.format(sugestao);
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber),
                              const SizedBox(width: 6),
                              RichText(
                                text: TextSpan(
                                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                                  children: [
                                    const TextSpan(text: "Sugerido para este mês: "),
                                    TextSpan(
                                      text: _currencyFormat.format(sugestao),
                                      style: const TextStyle(
                                        color: Color(0xFF1E90FF), 
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      // 👆👆 FIM DA RECOMENDAÇÃO 👆👆

                      const SizedBox(height: 20.0),
                      
                      // DATA
                      GestureDetector(
                        onTap: isLoading ? null : () => _selectDate(context),
                        child: AbsorbPointer(
                          child: TextField(
                            controller: _dataController,
                            enabled: !isLoading,
                            decoration: InputDecoration(labelText: 'Data', prefixIcon: const Icon(Icons.calendar_today), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // PAGAMENTO
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Forma de Pagamento', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
                        value: _formaPagamentoSelecionada,
                        items: const [
                          DropdownMenuItem(value: 'cartao', child: Text('Cartão de Crédito')),
                          DropdownMenuItem(value: 'boleto', child: Text('Boleto Bancário')),
                          DropdownMenuItem(value: 'pix', child: Text('PIX')),
                        ],
                        onChanged: (value) => setState(() => _formaPagamentoSelecionada = value),
                      ),
                      const SizedBox(height: 40.0),

                      // BOTÃO
                      ElevatedButton(
                        onPressed: isLoading ? null : _handleFazerContribuicao,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 255, 187, 0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
                            : Text('Confirmar Depósito', style: GoogleFonts.poppins(fontSize: 16.0, color: Colors.white)),
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