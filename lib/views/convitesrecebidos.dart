import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; 
// Imports de Lógica
import '../stores/ConviteStore.dart'; // Seu Provider de Convites
import '../services/authProvider.dart'; // AuthStore (para userId)
import '../models/convite.dart'; // O Model Convite
import 'modules/header.dart';
import 'modules/footbar.dart';

class ConvitesRecebidos extends StatefulWidget {
  const ConvitesRecebidos({super.key});

  @override
  _ConvitesRecebidosState createState() => _ConvitesRecebidosState();
}

class _ConvitesRecebidosState extends State<ConvitesRecebidos> {
  
  @override
  void initState() {
    super.initState();
    // Dispara o carregamento dos convites pendentes assim que a tela abre
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarConvitesPendentes();
    });
  }
  
  // Função que inicia a busca de convites
  void _carregarConvitesPendentes() {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    
    if (authStore.usuario?.id != null) {
      final userId = authStore.usuario!.id!;
      Provider.of<ConviteStore>(context, listen: false)
          .carregarConvites(userId);
    }
  }

  // Função que processa a resposta do usuário
  void _responderConvite(Convite convite, bool aceitar) async {
    final conviteProvider = Provider.of<ConviteStore>(context, listen: false);
    
    await conviteProvider.responderConvite(convite, aceitar);
    
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(aceitar ? 'Convite aceito! Cofre adicionado.' : 'Convite recusado.')),
    );
  }


  // --- Widget para exibir cada item de convite ---
  Widget _buildConviteCard(Convite convite, BuildContext context) {
    
    final String convidador = convite.idUsuarioConvidador.substring(0, 8) + '...';
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Novo Convite de ${convidador}',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E90FF)),
            ),
            Text('Enviado em: ${dateFormat.format(convite.dataEnvio)}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
            
            const SizedBox(height: 15),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 1. Botão Recusar
                TextButton(
                  onPressed: () => _responderConvite(convite, false),
                  child: Text('Recusar', style: GoogleFonts.poppins(color: Colors.red)),
                ),
                const SizedBox(width: 10),
                // 2. Botão Aceitar
                ElevatedButton(
                  onPressed: () => _responderConvite(convite, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text('Aceitar', style: GoogleFonts.poppins(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conviteProvider = context.watch<ConviteStore>();
    final List<Convite> convites = conviteProvider.convitesRecebidos;
    final bool isLoading = conviteProvider.isLoading;
    final String? errorMessage = conviteProvider.errorMessage;


    // --- Renderização de Estados ---
    Widget bodyContent;

    if (isLoading && convites.isEmpty) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (errorMessage != null) {
      bodyContent = Center(child: Text('Erro ao carregar convites: $errorMessage', style: const TextStyle(color: Colors.red)));
    } else if (convites.isEmpty) {
      bodyContent = Center(
          child: Text('Você não tem convites pendentes.', style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54)),
      );
    } else {
      // Lista de Convites
      bodyContent = ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        itemCount: convites.length,
        itemBuilder: (context, index) {
          return _buildConviteCard(convites[index], context);
        },
      );
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
                borderRadius: BorderRadius.only(topLeft: Radius.circular(50.0), topRight: Radius.circular(50.0)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 30.0),
                    Text('Convites Recebidos', style: GoogleFonts.poppins(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(height: 20.0),
                    
                    Expanded(child: bodyContent), // Exibe o conteúdo dinâmico
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