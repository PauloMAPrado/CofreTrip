import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:travelbox/views/modules/header.dart';
import 'package:travelbox/views/modules/footbar.dart';
import 'package:travelbox/stores/detalhesCofreStore.dart'; 
import 'package:travelbox/views/convidar.dart';

class ListaUser extends StatelessWidget {
  final String cofreId;
  const ListaUser({super.key, required this.cofreId});

  @override
  Widget build(BuildContext context) {
    final detalhesStore = context.watch<DetalhesCofreStore>();
    final membros = detalhesStore.membros;
    final contribuidoresMap = detalhesStore.contribuidoresMap;

    return Scaffold(
      backgroundColor: const Color(0xFF1E90FF),
      body: Column(
        children: [
          const Header(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Text('Participantes', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),

//                    BOTÃO CONVIDAR (Descomente quando criar a tela Convidar)
                    ElevatedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Convidar(cofreId: cofreId))),
                      icon: const Icon(Icons.person_add, color: Colors.white),
                      label: Text('Convidar Novo Membro', style: GoogleFonts.poppins(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                    const SizedBox(height: 20),

                    Expanded(
                      child: membros.isEmpty
                          ? const Center(child: Text("Nenhum membro encontrado."))
                          : ListView.builder(
                              itemCount: membros.length,
                              itemBuilder: (context, index) {
                                final perm = membros[index];
                                final usuario = contribuidoresMap[perm.idUsuario];
                                final nome = usuario?.nome ?? 'Carregando...';
                                final email = usuario?.email ?? '---';
                                final isCoord = perm.nivelPermissao.name == 'coordenador';

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: isCoord ? Colors.orange.shade100 : Colors.blue.shade100,
                                      child: Icon(Icons.person, color: isCoord ? Colors.orange : Colors.blue),
                                    ),
                                    title: Text(nome, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                                    subtitle: Text(email),
                                    trailing: isCoord 
                                        ? Chip(label: Text("Dono", style: TextStyle(fontSize: 10, color: Colors.white)), backgroundColor: Colors.orange)
                                        : null,
                                  ),
                                );
                              },
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