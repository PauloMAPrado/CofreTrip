import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:travelbox/views/modules/header.dart';
import 'package:travelbox/views/modules/footbar.dart';
import 'package:travelbox/views/cofre.dart';
import '../controllers/detalhesCofreStore.dart'; 
import '../models/usuario.dart'; 
import '../models/permissao.dart'; 
import 'package:travelbox/views/convidar.dart';

class ListaUser extends StatefulWidget {
  final String cofreId; 
  
  const ListaUser({super.key, required this.cofreId});

  @override
  _ListaUserState createState() => _ListaUserState();
}

class _ListaUserState extends State<ListaUser> {
  
  @override
  void initState() {
    super.initState();
    // Dispara a busca dos membros ao iniciar a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DetalhesCofreStore>(context, listen: false)
          .carregarDadosCofre(widget.cofreId);
    });
  }

  // --- Widget para exibir cada membro ---
  Widget _buildUserCard(Permissao permissao, Map<String, Usuario> contribuidores) {
    // Nota: O Provider deve buscar o perfil Usuario pelo ID da permissão
    final usuario = contribuidores[permissao.idUsuario];
    final nomeUsuario = usuario?.nome ?? 'Usuário Desconhecido';
    final nivel = permissao.nivelPermissao.name.toUpperCase();
    
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: ListTile(
        leading: Icon(Icons.person_pin, color: nivel == 'COORDENADOR' ? const Color.fromARGB(255, 255, 187, 0) : const Color(0xFF1E90FF), size: 30),
        title: Text(
          nomeUsuario,
          style: GoogleFonts.poppins(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Email: ${usuario?.email ?? 'N/A'}',
          style: GoogleFonts.poppins(fontSize: 14.0),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: nivel == 'COORDENADOR' ? Colors.red.shade100 : Colors.blue.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(nivel, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
        ),
        isThreeLine: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 3. Lê o estado do Provider
    final detalhesProvider = context.watch<DetalhesCofreStore>();
    final bool isLoading = detalhesProvider.isLoading;
    final List<Permissao> membros = detalhesProvider.membros;
    final Map<String, Usuario> contribuidores = detalhesProvider.contribuidoresMap;

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40.0),
                    Text('Participantes', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(height: 20.0),

                    // 4. Botão para convidar novos membros
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : () {
                        // 🎯 NAVEGAR PARA A TELA DE CONVITE
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Convidar(cofreId: widget.cofreId)));
                      },
                      icon: const Icon(Icons.person_add, color: Colors.white),
                      label: Text('Convidar Novo Membro', style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                    const SizedBox(height: 20.0),
                    
                    // 5. Exibição da Lista Dinâmica ou Loading
                    isLoading 
                        ? const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()))
                        : Expanded(
                            child: membros.isEmpty
                                ? Center(child: Text("Nenhum membro encontrado neste cofre."))
                                : ListView.builder(
                                    itemCount: membros.length,
                                    itemBuilder: (context, index) {
                                      // Renderiza o card do membro
                                      return _buildUserCard(membros[index], contribuidores); 
                                    },
                                  ),
                          ),
                          
                    const SizedBox(height: 20.0),

                    // Botão para voltar
                    ElevatedButton(
                      onPressed: () {
                        // Navega de volta para o Dashboard do Cofre
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Cofre(cofreId: widget.cofreId)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E90FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                      ),
                      child: Text('Voltar ao Cofre', style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
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