import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:travelbox/models/usuario.dart';
import 'package:travelbox/stores/authStore.dart';
import 'package:travelbox/stores/ConviteStore.dart'; // Corrija o nome se estiver diferente
import 'package:travelbox/utils/feedbackHelper.dart';
import 'package:travelbox/views/modules/header.dart';

class Convidar extends StatefulWidget {
  final String cofreId;
  const Convidar({super.key, required this.cofreId});

  @override
  _ConvidarState createState() => _ConvidarState();
}

class _ConvidarState extends State<Convidar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _enviarConvite(Usuario usuarioDestino) async {
    // Fecha o teclado
    FocusScope.of(context).unfocus();

    final conviteStore = context.read<ConviteStore>();
    final authStore = context.read<AuthStore>();
    final meuId = authStore.usuario?.id;

    if (meuId == null) return;

    // Chama o método de enviar (reaproveitando a lógica que já existe)
    String? erro = await conviteStore.enviarConvite(
      emailDestino: usuarioDestino.email, // Passamos o email do usuário encontrado
      cofreId: widget.cofreId,
      idUsuarioConvidador: meuId,
    );

    if (!mounted) return;

    if (erro == null) {
      FeedbackHelper.mostrarSucesso(context, "Convite enviado para ${usuarioDestino.nome}!");
      // Limpa a busca para não enviar duas vezes sem querer
      _searchController.clear();
      conviteStore.limparDados();
    } else {
      FeedbackHelper.mostrarErro(context, erro);
    }
  }

  @override
  Widget build(BuildContext context) {
    final conviteStore = context.watch<ConviteStore>();
    final usuarios = conviteStore.usuariosEncontrados;
    final isLoading = conviteStore.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF1E90FF),
      body: Column(
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
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Text(
                      'Convidar Amigo',
                      style: GoogleFonts.poppins(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    
                    // CAMPO DE BUSCA
                    TextField(
                      controller: _searchController,
                      onChanged: (text) {
                        // Chama o Store a cada letra digitada
                        context.read<ConviteStore>().buscarUsuarios(text);
                      },
                      decoration: InputDecoration(
                        labelText: 'Buscar por nome',
                        hintText: 'Ex: Fernando...',
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF1E90FF)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // LISTA DE RESULTADOS
                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : usuarios.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  itemCount: usuarios.length,
                                  itemBuilder: (context, index) {
                                    final user = usuarios[index];
                                    return _buildUserTile(user);
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_searchController.text.isNotEmpty) {
      return Center(
        child: Text("Nenhum usuário encontrado.", style: GoogleFonts.poppins(color: Colors.grey)),
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text("Digite um nome para buscar.", style: GoogleFonts.poppins(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildUserTile(Usuario user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1E90FF).withOpacity(0.1),
          child: const Icon(Icons.person, color: Color(0xFF1E90FF)),
        ),
        title: Text(user.nome, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        // Mostramos o email menorzinho para diferenciar homônimos
        subtitle: Text(user.email, style: GoogleFonts.poppins(fontSize: 12)),
        trailing: IconButton(
          icon: const Icon(Icons.send, color: Colors.green),
          onPressed: () => _enviarConvite(user),
        ),
      ),
    );
  }
}