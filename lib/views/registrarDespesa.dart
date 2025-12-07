// lib/views/registrarDespesa.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:travelbox/stores/detalhesCofreStore.dart';
// Imports Store/Providers
import '../stores/detalhesCofreStore.dart'; 
import '../stores/authStore.dart';  
import '../stores/despesaStore.dart';     
// Imports Models
import '../models/despesa.dart';             
import '../models/usuario.dart';             
// Imports Utils
import '../utils/feedbackHelper.dart';       
import '../utils/currency_input_formatter.dart'; // 🎯 NOVO: Seu formatador customizado
import 'modules/header.dart';
import 'modules/footbar.dart';


class RegistrarDespesa extends StatefulWidget {
  final String cofreId;
  const RegistrarDespesa({super.key, required this.cofreId});

  @override
  _RegistrarDespesaState createState() => _RegistrarDespesaState();
}

class _RegistrarDespesaState extends State<RegistrarDespesa> {
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  
  List<Usuario> _participantes = [];
  String? _pagadorId;
  bool _isLoading = false;

  // 🎯 Formato de Moeda Customizado
  final CurrencyInputFormatter _decimalInputFormatter = CurrencyInputFormatter();

  @override
  void initState() {
    super.initState();
    // Carrega participantes e define o usuário logado como pagador padrão
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final detalhesStore = Provider.of<DetalhesCofreStore>(context, listen: false);
      final authStore = Provider.of<AuthStore>(context, listen: false);

      // Associa a lista de participantes real do Store ao estado local
      _participantes = detalhesStore.participantesDoCofre; 
      
      // Define o pagador como o usuário logado
      _pagadorId = authStore.usuario?.id;
      
      // Se não houver participantes, o usuário logado é o único
      if (_participantes.isEmpty && authStore.usuario != null) {
          _participantes.add(authStore.usuario!);
      }
      
      setState(() {});
    });
  }
  
  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }


  // --- Lógica de Criação da Despesa ---
  Future<void> _handleRegistrarDespesa() async {
    final valorRaw = _valorController.text.trim();
    final descricao = _descricaoController.text.trim();

    if (descricao.isEmpty || valorRaw.isEmpty || _pagadorId == null) {
      FeedbackHelper.mostrarErro(context, "Preencha a descrição, valor e selecione o pagador.");
      return;
    }
    
    // 🎯 LIMPEZA DO VALOR (Lógica copiada do DecimalInputFormatter para validar)
    final cleanValor = valorRaw.replaceAll('.', '').replaceAll(',', '.').replaceAll(RegExp(r'[^0-9.]'), '');
    final double? valorTotal = double.tryParse(cleanValor);

    if (valorTotal == null || valorTotal <= 0) {
      FeedbackHelper.mostrarErro(context, "Valor inválido.");
      return;
    }

    setState(() => _isLoading = true);
    
    // LÓGICA DE DIVISÃO (Divisão Igual entre todos os participantes)
    final int numParticipantes = _participantes.length;
    
    if (numParticipantes == 0) {
        FeedbackHelper.mostrarErro(context, "Não há participantes válidos para divisão.");
        setState(() => _isLoading = false);
        return;
    }
    
    final double valorDividido = valorTotal / numParticipantes;
    
    List<Map<String, double>> divisao = [];
    
    // Cria a estrutura de divisão: {idUsuario: valorDevido}
    for (var user in _participantes) {
      divisao.add({
        user.id!: valorDividido
      });
    }

    Despesa novaDespesa = Despesa(
      idCofre: widget.cofreId,
      descricao: descricao,
      valorTotal: valorTotal,
      idUsuarioPagador: _pagadorId!,
      data: DateTime.now(),
      divisao: divisao,
    );

    final success = await Provider.of<DespesaProvider>(context, listen: false)
        .registrarDespesa(novaDespesa);

    setState(() => _isLoading = false);

    if (success) {
      FeedbackHelper.mostrarSucesso(context, "Despesa registrada e dividida igualmente!");
      // 🎯 Se a despesa for registrada com sucesso, é crucial recarregar os dados do cofre.
      Provider.of<DetalhesCofreStore>(context, listen: false).carregarDadosCofre(widget.cofreId);
      Navigator.pop(context);
    } else {
      final error = Provider.of<DespesaProvider>(context, listen: false).errorMessage;
      FeedbackHelper.mostrarErro(context, error ?? "Erro desconhecido ao registrar.");
    }
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
                borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40.0),
                      Text('Registrar Nova Despesa', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 22.0, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 30.0),

                      // --- CAMPO DESCRIÇÃO ---
                      TextField(
                        controller: _descricaoController,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          labelText: 'Descrição (Ex: Jantar em Roma)',
                          prefixIcon: const Icon(Icons.description, color: Color(0xFF1E90FF)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        style: GoogleFonts.poppins(),
                      ),
                      const SizedBox(height: 20.0),

                      // --- CAMPO VALOR ---
                      TextField(
                        controller: _valorController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        enabled: !_isLoading,
                        // 🎯 Usando o formatador corrigido!
                        inputFormatters: [_decimalInputFormatter], 
                        decoration: InputDecoration(
                          labelText: 'Valor Total Gasto',
                          prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF1E90FF)),
                          labelStyle: GoogleFonts.poppins(),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: GoogleFonts.poppins(),
                      ),
                      const SizedBox(height: 20.0),
                      
                      // --- SELETOR DE PAGADOR (DROP-DOWN) ---
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Quem Pagou?',
                          prefixIcon: const Icon(Icons.person, color: Color(0xFF1E90FF)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        value: _pagadorId,
                        items: _participantes.map((user) {
                          return DropdownMenuItem<String>(
                            value: user.id,
                            child: Text(user.nome),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _pagadorId = newValue;
                          });
                        },
                        // Se não houver participantes, desabilita a seleção
                        hint: _participantes.isEmpty ? const Text("Carregando participantes...") : null,
                      ),
                      const SizedBox(height: 40.0),
                      
                      // --- BOTÃO DE REGISTRO ---
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegistrarDespesa,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                            : Text('Dividir e Registrar Despesa', style: GoogleFonts.poppins(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white)),
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