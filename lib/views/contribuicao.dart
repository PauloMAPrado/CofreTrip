import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; 
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart'; 

import 'package:travelbox/views/modules/footbar.dart';
import 'package:travelbox/views/modules/header.dart';

import '../stores/detalhesCofreStore.dart'; 
import '../services/authProvider.dart'; 


class Contribuicao extends StatefulWidget {
  // CRÍTICO: O ID do Cofre é obrigatório
  final String cofreId;
  
  const Contribuicao({super.key, required this.cofreId});

  @override
  _ContribuicaoState createState() => _ContribuicaoState();
}

class _ContribuicaoState extends State<Contribuicao> {
  // --- Controladores e Estado ---
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  String? _formaPagamentoSelecionada; 
  bool _isLoading = false; 

  // --- Formatadores ---
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final _currencyMask = MaskTextInputFormatter(
    mask: '##.###.###,00', 
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // --- Funções de UX e Validação ---
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
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

  // --- Lógica Principal: Fazer Contribuição ---
  void _handleFazerContribuicao() async {
    // 1. Inicia o Loading
    setState(() { _isLoading = true; });

    final valorRaw = _valorController.text.trim();
    final dataRaw = _dataController.text.trim();
    final formaPagamento = _formaPagamentoSelecionada;

    // 2. Validação Básica
    if (valorRaw.isEmpty || dataRaw.isEmpty || formaPagamento == null) {
      _showSnackBar('Preencha o valor, a data e a forma de pagamento.', isError: true);
      setState(() { _isLoading = false; });
      return;
    }
    
    // 3. Limpeza e Validação do Valor (R$ para double)
    final cleanValor = valorRaw
        .replaceAll('R\$', '')
        .replaceAll('.', '') 
        .replaceAll(',', '.') 
        .trim(); 

    final double? valorContribuicao = double.tryParse(cleanValor);
    if (valorContribuicao == null || valorContribuicao <= 0) {
      _showSnackBar('Insira um valor válido maior que R\$ 0,00.', isError: true);
      setState(() { _isLoading = false; });
      return;
    }

    // 4. Acessa Providers e Chama a Ação
    final detalhesProvider = Provider.of<DetalhesCofreStore>(context, listen: false);
    final authStore = Provider.of<AuthStore>(context, listen: false);

    if (authStore.usuario?.id == null) {
        _showSnackBar('Erro de sessão. Faça login novamente.', isError: true);
        setState(() { _isLoading = false; });
        return;
    }
    
    // 5. Salva a transação
    final userId = authStore.usuario!.id!;
    final DateTime dataTransacao = DateTime.parse(dataRaw);

    bool sucesso = await detalhesProvider.adicionarContribuicao(
        cofreId: widget.cofreId, // Usando o ID recebido no construtor
        usuarioId: userId,
        valor: valorContribuicao,
        data: dataTransacao,
    );
    
    // 6. Feedback e Navegação
    setState(() { _isLoading = false; });

    if (sucesso && mounted) {
        _showSnackBar('Contribuição de R\$${valorContribuicao.toStringAsFixed(2)} registrada!', isError: false);
        Navigator.pop(context); // Volta para o Dashboard do Cofre
    } else {
        final String msg = detalhesProvider.errorMessage ?? 'Falha ao registrar contribuição. Verifique a conexão.';
        _showSnackBar(msg, isError: true);
    }
  }

  @override
  void dispose() {
    _valorController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E90FF),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Header(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40.0),
                      Text(
                        'Selecione os dados para fazer sua contribuição ao cofre:',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 20.0,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      
                      // 1. CAMPO VALOR
                      TextField(
                        controller: _valorController,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          labelText: 'Valor da Contribuição',
                          prefixIcon: const Icon(Icons.attach_money),
                          prefixText: 'R\$ ',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [_currencyMask], // Aplica máscara de moeda
                      ),
                      const SizedBox(height: 20.0),
                      
                      // 2. CAMPO DATA (Seletor)
                      GestureDetector(
                        onTap: _isLoading ? null : () => _selectDate(context),
                        child: AbsorbPointer(
                          child: TextField(
                            controller: _dataController,
                            enabled: !_isLoading,
                            decoration: InputDecoration(
                              labelText: _dataController.text.isEmpty 
                                  ? 'Data da Contribuição' : _dataController.text,
                              prefixIcon: const Icon(Icons.calendar_today),
                              suffixIcon: const Icon(Icons.arrow_drop_down),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                            ),
                            keyboardType: TextInputType.datetime,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // 3. FORMA DE PAGAMENTO (Dropdown)
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Forma de Pagamento',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                          prefixIcon: const Icon(Icons.payment),
                        ),
                        value: _formaPagamentoSelecionada,
                        items: const [
                          DropdownMenuItem(value: 'cartao', child: Text('Cartão de Crédito')),
                          DropdownMenuItem(value: 'boleto', child: Text('Boleto Bancário')),
                          DropdownMenuItem(value: 'pix', child: Text('PIX')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _formaPagamentoSelecionada = value;
                          });
                        },
                      ),
                      const SizedBox(height: 40.0),

                      // BOTÃO FAZER CONTRIBUIÇÃO
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleFazerContribuicao,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 255, 187, 0), // Laranja/Amarelo
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          child: _isLoading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(
                                  'Fazer Contribuição',
                                  style: GoogleFonts.poppins(fontSize: 16.0, color: Colors.white),
                                ),
                        ),
                      ),
                      
                      const SizedBox(height: 20.0),
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