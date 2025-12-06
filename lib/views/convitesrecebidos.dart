// Imports essenciais
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

//Imports das Views
import 'package:travelbox/views/modules/footbar.dart';
import 'package:travelbox/views/modules/header.dart';

// Import do models
import 'package:travelbox/models/convite.dart';

// Imports dos Stores
import 'package:travelbox/stores/conviteStore.dart';
import 'package:travelbox/stores/authStore.dart';

// Import do utils
import 'package:travelbox/utils/feedbackHelper.dart';

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
      _carregarConvites();
    });
  }
  
  // Função que inicia a busca de convites
  void _carregarConvites() {
    final user = context.read<AuthStore>().usuario;    
    if (user?.id != null) {
      context.read<ConviteStore>().carregarConvites(user!.id!);
    }
  }

  // Função que processa a resposta do usuário
  void _responderConvite(Convite convite, bool aceitar) async {
    final store = context.read<ConviteStore>();
    
    await store.responderConvite(convite, aceitar);
        
    if(mounted) {
      if(aceitar) {
        FeedbackHelper.mostrarSucesso(context,'Convite aceito! O cofre foi adicionado à sua lista.');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Convite recusado.")));
      }
    }
  }

/* ============================ codigo antigo ===================================
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

*/ //=====================================================================================

// --- Card do Convite ---
  Widget _buildConviteCard(Convite convite) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    // Idealmente, o Store buscaria o nome do usuário. Por enquanto usamos o ID.
    final remetente = "Usuário ...${convite.idUsuarioConvidador.substring(0, 5)}";

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.mark_email_unread, color: Color(0xFF1E90FF)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Convite de $remetente',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              'Recebido em: ${dateFormat.format(convite.dataEnvio)}',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _responderConvite(convite, false),
                  child: Text('Recusar', style: GoogleFonts.poppins(color: Colors.red)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _responderConvite(convite, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
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
    final conviteStore = context.watch<ConviteStore>();
    final convites = conviteStore.convitesRecebidos;
    final isLoading = conviteStore.isLoading;
      


    // --- Renderização de Estados ---
    Widget bodyContent;

    if (isLoading) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (convites.isEmpty) {
      bodyContent = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox, size: 60, color: Colors.grey),
            const SizedBox(height: 10),
            Text('Nenhum convite pendente.', style: GoogleFonts.poppins(color: Colors.grey)),
          ],
        ),
      );
    } else {
      bodyContent = ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: convites.length,
        itemBuilder: (ctx, i) => _buildConviteCard(convites[i]),
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