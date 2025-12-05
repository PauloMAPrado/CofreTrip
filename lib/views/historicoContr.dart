import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:travelbox/views/modules/header.dart';
import 'package:travelbox/views/modules/footbar.dart';

// Imports de Lógica
import '../stores/detalhesCofreStore.dart';
import '../models/contribuicao.dart';
import '../models/usuario.dart';

class Historicocontr extends StatefulWidget {
  // 🎯 O ID do Cofre é obrigatório para buscar o histórico correto
  final String cofreId; 

  const Historicocontr({super.key, required this.cofreId});

  @override
  _HistoricocontrState createState() => _HistoricocontrState();
}

class _HistoricocontrState extends State<Historicocontr> {
  
  // Formatadores
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR', 
    symbol: 'R\$',
    decimalDigits: 2,
  );
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    // ⚠️ Dispara o carregamento dos detalhes do cofre específico
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DetalhesCofreStore>(context, listen: false)
          .carregarDadosCofre(widget.cofreId);
    });
  }

  // --- Módulo para renderizar cada item da contribuição ---
  Widget _buildContribuicaoCard(Contribuicao contr, Map<String, Usuario> contribuidores) {
    // Busca o objeto Usuário para obter o nome
    final usuario = contribuidores[contr.idUsuario];
    final nomeUsuario = usuario?.nome ?? 'Usuário Desconhecido';
    
    return Card(
      elevation: 2.0,
      color: const Color.fromARGB(255, 240, 240, 240), // Cor mais clara
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      margin: const EdgeInsets.only(bottom: 10.0),
      child: ListTile(
        leading: const Icon(Icons.paid, color: Color(0xFF1E90FF)),
        title: Text(
          nomeUsuario,
          style: GoogleFonts.poppins(fontSize: 16.0, fontWeight: FontWeight.bold, color: const Color(0xFF333333)),
        ),
        subtitle: Text(
          'Data: ${_dateFormat.format(contr.data)}',
          style: GoogleFonts.poppins(fontSize: 14.0, color: Colors.black54),
        ),
        trailing: Text(
          _currencyFormat.format(contr.valor),
          style: GoogleFonts.poppins(fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.green.shade700),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Lê o estado do Provider
    final detalhesProvider = context.watch<DetalhesCofreStore>();
    final cofre = detalhesProvider.cofreAtivo;
    final contribuicoes = detalhesProvider.contribuicoes;
    final contribuidoresMap = detalhesProvider.contribuidoresMap; // Mapa de ID -> Usuário
    
    final isLoading = detalhesProvider.isLoading;
    final errorMessage = detalhesProvider.errorMessage;

    // 2. Determina o título e o estado
    final nomeCofre = cofre?.nome ?? 'Carregando Cofre...';
    
    // 3. Renderização de Estados
    if (isLoading && contribuicoes.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (errorMessage != null) {
      return Scaffold(body: Center(child: Text('Erro: $errorMessage', style: TextStyle(color: Colors.red))));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E90FF),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Header(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF4F9FB),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50.0),
                  topRight: Radius.circular(50.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40.0),
                    Text(
                      'Histórico de Contribuições',
                      style: GoogleFonts.poppins(fontSize: 20.0, color: const Color(0xFF333333)),
                    ),
                    
                    const SizedBox(height: 20.0),

                    // Nome do Cofre (Título Dinâmico)
                    Text(
                      nomeCofre,
                      style: GoogleFonts.poppins(fontSize: 17.0, fontWeight: FontWeight.bold, color: const Color(0xFF333333)),
                    ),
                    
                    const SizedBox(height: 20.0),

                    // LISTA DE CONTRIBUIÇÕES
                    Expanded(
                      child: contribuicoes.isEmpty
                          ? Center(child: Text('Nenhuma contribuição registrada ainda.'))
                          : ListView.builder(
                              itemCount: contribuicoes.length,
                              itemBuilder: (context, index) {
                                return _buildContribuicaoCard(contribuicoes[index], contribuidoresMap);
                              },
                            ),
                    ),
                    
                    // Total Arrecadado no Rodapé da Lista
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        'Total Arrecadado: ${_currencyFormat.format(detalhesProvider.totalArrecadado)}',
                        textAlign: TextAlign.right,
                        style: GoogleFonts.poppins(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E90FF),
                        ),
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