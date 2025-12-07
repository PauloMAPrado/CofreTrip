// lib/views/RegistrarAcerto.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// Imports de modelos e stores
import '../models/transacaoAcerto.dart';
import '../models/acerto.dart';
import '../models/usuario.dart';
import '../stores/despesaStore.dart'; // Usando o nome correto
import '../stores/detalhesCofreStore.dart';
import '../utils/feedbackHelper.dart';
import '../utils/currency_input_formatter.dart';
import 'modules/header.dart';
import 'modules/footbar.dart';


class RegistrarAcerto extends StatefulWidget {
  final TransacaoAcerto transacao;
  final String cofreId; // 🎯 Recebe o ID do cofre
  
  // Construtor corrigido
  const RegistrarAcerto({
    super.key, 
    required this.transacao,
    required this.cofreId, // Agora é obrigatório
  });

  @override
  _RegistrarAcertoState createState() => _RegistrarAcertoState();
}

class _RegistrarAcertoState extends State<RegistrarAcerto> {
  final TextEditingController _valorController = TextEditingController();
  final CurrencyInputFormatter _decimalInputFormatter = CurrencyInputFormatter();
  
  bool _isLoading = false;
  
  // Formatadores
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR', 
    symbol: 'R\$ ', 
    decimalDigits: 2
  );

  // 🎯 CORRIGIDO: Formatador sem R$ para preencher o input sem conflito
  static final NumberFormat _decimalFormat = NumberFormat.currency(
    locale: 'pt_BR', 
    symbol: '', 
    decimalDigits: 2
  );


  @override
  void initState() {
    super.initState();
    
    // CORRIGIDO: Usa NumberFormat para formatar o double em string para o input
    final valorInicialFormatado = _decimalFormat.format(widget.transacao.valor);
    _valorController.text = valorInicialFormatado;
  }

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirmarAcerto(String cofreId) async {
    final valorRaw = _valorController.text.trim();
    
    // Limpeza e validação do valor
    final cleanValor = valorRaw.replaceAll('.', '').replaceAll(',', '.').replaceAll(RegExp(r'[^0-9.]'), '');
    final double? valorAcerto = double.tryParse(cleanValor);
    
    final double valorMaximoDevido = widget.transacao.valor;

    if (valorAcerto == null || valorAcerto <= 0) {
      FeedbackHelper.mostrarErro(context, "Insira um valor de quitação válido.");
      return;
    }
    
    // Validação de pagamento máximo (impede que o usuário pague R$ 500 se só deve R$ 100)
    if (valorAcerto > valorMaximoDevido + 0.01) {
       FeedbackHelper.mostrarErro(
         context, 
         "O valor de R${_currencyFormat.format(valorAcerto)} não pode ser superior à dívida total de ${_currencyFormat.format(valorMaximoDevido)}."
       );
       return;
    }

    setState(() => _isLoading = true);

    // Constrói o novo Acerto (o registro oficial no banco)
    final novoAcerto = Acerto(
      idCofre: cofreId, // ID recebido via construtor
      idUsuarioPagador: widget.transacao.pagadorId,
      idUsuarioRecebedor: widget.transacao.recebedorId,
      valor: valorAcerto,
      data: DateTime.now(),
    );

    // Chama o Provider para registrar
    final success = await Provider.of<DespesaProvider>(context, listen: false)
        .registrarAcerto(novoAcerto);

    setState(() => _isLoading = false);

    if (success) {
      FeedbackHelper.mostrarSucesso(context, "Pagamento de ${_currencyFormat.format(valorAcerto)} registrado! Saldos atualizados.");
      Navigator.pop(context); // Volta para a tela de Saldos
    } else {
      FeedbackHelper.mostrarErro(context, "Falha ao registrar acerto.");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Para obter os nomes
    final detalhesStore = context.watch<DetalhesCofreStore>();
    final Map<String, Usuario> perfis = detalhesStore.contribuidoresMap;

    // Obtém o nome real dos envolvidos (do Store)
    final String pagadorNome = perfis[widget.transacao.pagadorId]?.nome ?? 'Devedor';
    final String recebedorNome = perfis[widget.transacao.recebedorId]?.nome ?? 'Credor';
    final String valorTotalDevido = _currencyFormat.format(widget.transacao.valor);
    
    // O ID do Cofre é pego do widget.cofreId

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
                borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40.0),
                      Text('Quitar Dívida', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 22.0, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 30.0),

                      // Informação da Dívida
                      Card(
                        elevation: 0,
                        color: Colors.red.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text.rich(
                            TextSpan(
                              text: '$pagadorNome deve ',
                              style: GoogleFonts.poppins(fontSize: 16),
                              children: [
                                TextSpan(
                                  text: valorTotalDevido,
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.red.shade600),
                                ),
                                TextSpan(text: ' para $recebedorNome. Insira o valor do pagamento abaixo.'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      
                      // Campo de Valor a Pagar
                      TextField(
                        controller: _valorController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        enabled: !_isLoading,
                        inputFormatters: [_decimalInputFormatter], 
                        decoration: InputDecoration(
                          labelText: 'Valor a Pagar Agora',
                          prefixIcon: const Icon(Icons.money, color: Color(0xFF1E90FF)),
                          labelStyle: GoogleFonts.poppins(),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      
                      const SizedBox(height: 40.0),
                      
                      // --- BOTÃO DE CONFIRMAÇÃO ---
                      ElevatedButton(
                        onPressed: _isLoading 
                            ? null 
                            // 🎯 Passando o ID do Cofre recebido via construtor
                            : () => _handleConfirmarAcerto(widget.cofreId), 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                            : Text('Registrar Pagamento', style: GoogleFonts.poppins(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                      const SizedBox(height: 25.0),
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