import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:travelbox/models/nivelPermissao.dart';
import 'package:travelbox/views/modules/header.dart';
import 'package:travelbox/views/modules/footbar.dart';
import 'package:travelbox/utils/feedbackHelper.dart'; // Importante para feedbacks

import 'package:travelbox/stores/detalhesCofreStore.dart'; 
import 'package:travelbox/stores/authStore.dart';
import 'package:travelbox/views/convidar.dart';

class ListaUser extends StatelessWidget {
  final String cofreId;
  const ListaUser({super.key, required this.cofreId});

  // Função auxiliar para mostrar diálogo de confirmação
  void _confirmarAcao(BuildContext context, String titulo, String corpo, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(corpo, style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: const Text("Confirmar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detalhesStore = context.watch<DetalhesCofreStore>();
    final authStore = context.watch<AuthStore>();
    
    final membros = detalhesStore.membros;
    final contribuidoresMap = detalhesStore.contribuidoresMap;
    final meuId = authStore.usuario?.id;

    // 1. Descobrir meu papel no grupo
    bool souCoordenador = false;
    try {
      final minhaPermissao = membros.firstWhere((m) => m.idUsuario == meuId);
      souCoordenador = minhaPermissao.nivelPermissao == NivelPermissao.coordenador;
    } catch (_) {
      // Se não me encontrar na lista (erro raro), assume que não sou coord
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E90FF),
      body: Column(
        children: [
          const Header(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50))
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Text('Participantes', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),

                    // Botão de Convidar (Visível para todos ou só coord? Geralmente todos)
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
                                
                                final isMembroCoord = perm.nivelPermissao == NivelPermissao.coordenador;
                                final ehVoce = perm.idUsuario == meuId;

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: isMembroCoord ? Colors.orange.shade100 : Colors.blue.shade100,
                                      child: Icon(Icons.person, color: isMembroCoord ? Colors.orange : Colors.blue),
                                    ),
                                    title: Text(ehVoce ? "$nome (Você)" : nome, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                                    subtitle: Text(email),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Etiqueta de Dono
                                        if (isMembroCoord)
                                          Chip(label: const Text("Dono", style: TextStyle(fontSize: 10, color: Colors.white)), backgroundColor: Colors.orange),
                                        
                                        // LIXEIRA: Só aparece se EU sou Coordenador E o alvo NÃO é Coordenador (não posso me expulsar nem outro dono)
                                        if (souCoordenador && !isMembroCoord)
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                                            onPressed: () {
                                              _confirmarAcao(context, "Expulsar Membro", "Tem certeza que deseja remover $nome do cofre?", () async {
                                                bool sucesso = await detalhesStore.expulsarMembro(perm.idUsuario, cofreId);
                                                if (sucesso) FeedbackHelper.mostrarSucesso(context, "Membro removido.");
                                              });
                                            },
                                          )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    // BOTÃO SAIR DO GRUPO (Só se NÃO for coordenador)
                    if (!souCoordenador) ...[
                      const Divider(),
                      TextButton.icon(
                        icon: const Icon(Icons.exit_to_app, color: Colors.red),
                        label: Text("Sair do Grupo", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold)),
                        onPressed: () {
                           _confirmarAcao(context, "Sair do Grupo", "Tem certeza que deseja sair deste cofre? Você precisará de um novo convite para voltar.", () async {
                              if (meuId == null) return;
                              bool sucesso = await detalhesStore.sairDoCofre(meuId, cofreId);
                              
                              if (sucesso) {
                                // Volta tudo até a Home, pois não tenho mais acesso a esse cofre
                                Navigator.of(context).popUntil((route) => route.isFirst);
                                FeedbackHelper.mostrarSucesso(context, "Você saiu do cofre.");
                              }
                           });
                        },
                      ),
                      const SizedBox(height: 20),
                    ]
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