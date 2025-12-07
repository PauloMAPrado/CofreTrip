// lib/views/Saldos.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// 🎯 CORREÇÃO: Usando o nome correto do Controller (DespesaProvider)
import '../stores/despesaStore.dart'; 

import '../stores/detalhesCofreStore.dart'; // Para obter nomes dos usuários
import '../models/usuario.dart';
import 'modules/header.dart';
import 'modules/footbar.dart';
import 'package:travelbox/stores/authStore.dart';
// O modelo TransacaoAcerto já está importado (embora o caminho esteja longo, vamos manter)
import 'package:travelbox/models/transacaoAcerto.dart'; 

// 🎯 NOVO: Importa a tela de registro de acerto
import '../views/registrarAcerto.dart'; // Ajuste o caminho se necessário

class Saldos extends StatefulWidget {
  final String cofreId;
  const Saldos({super.key, required this.cofreId});
  
  @override
  State<Saldos> createState() => _SaldosState();
}

class _SaldosState extends State<Saldos> {
  // Formatador
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR', 
    symbol: 'R\$ ', 
    decimalDigits: 2
  );

  @override
  void initState() {
    super.initState();
    // Força o carregamento das despesas ao entrar na tela.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Nota: Carregar despesas também dispara o cálculo do saldo e das transações.
      // O nome DespesaProvider é usado, então assumimos que o import foi corrigido.
      Provider.of<DespesaProvider>(context, listen: false)
          .carregarDespesas(widget.cofreId);
      
      // Também é crucial garantir que os nomes dos membros estejam carregados
      Provider.of<DetalhesCofreStore>(context, listen: false)
          .carregarDadosCofre(widget.cofreId);
    });
  }

  // Função auxiliar para obter o nome (usando "Você" se for o usuário logado)
  String _getDisplayName(String userId, String? usuarioLogadoId, Map<String, Usuario> perfis) {
      if (userId == usuarioLogadoId) {
          return "Você";
      }
      return perfis[userId]?.nome ?? 'Usuário Desconhecido';
  }


  @override
  Widget build(BuildContext context) {
    // Escuta os dados
    final despesaProvider = context.watch<DespesaProvider>();
    final detalhesStore = context.watch<DetalhesCofreStore>();
    final authStore = context.watch<AuthStore>();
    
    // ID do usuário logado para exibir "Você"
    final String? usuarioLogadoId = authStore.usuario?.id;

    // Obtém a lista de transações simplificadas
    final List<TransacaoAcerto> transacoesAExibir = despesaProvider.transacoesAcerto;
    final Map<String, Usuario> perfis = detalhesStore.contribuidoresMap; // Mapa de nomes
    
    // Variáveis de estado para a UI
    final bool isDespesasEmpty = despesaProvider.despesas.isEmpty;
    final bool isSaldosZero = transacoesAExibir.isEmpty && !isDespesasEmpty;
    

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
                borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text('Acertos Mínimos', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                  
                  // --- AREA DE CONTEÚDO DINÂMICO ---
                  despesaProvider.isLoading || detalhesStore.isLoading
                      ? const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                      : isSaldosZero
                          ? const Center(child: Text('Nenhum saldo pendente. Tudo acertado! 🎉'))
                          : isDespesasEmpty
                              ? const Center(child: Text('Nenhuma despesa registrada neste cofre.'))
                              : Expanded(
                                  child: ListView.builder(
                                    itemCount: transacoesAExibir.length,
                                    itemBuilder: (context, index) {
                                      final transacao = transacoesAExibir[index];
                                      
                                      // Mapeamento de IDs para Nomes
                                      final String pagadorNome = _getDisplayName(transacao.pagadorId, usuarioLogadoId, perfis);
                                      final String recebedorNome = _getDisplayName(transacao.recebedorId, usuarioLogadoId, perfis);
                                      final String valorFormatado = _currencyFormat.format(transacao.valor);
                                      
                                      final String titleText = '$pagadorNome deve $valorFormatado para $recebedorNome.';
                                      
                                      // Cor da transação: vermelho se for uma dívida sua
                                      final Color cor = transacao.pagadorId == usuarioLogadoId 
                                          ? Colors.red.shade600 
                                          : Colors.green.shade600;

                                      return ListTile(
                                        // 🎯 IMPLEMENTAÇÃO DA NAVEGAÇÃO
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => RegistrarAcerto(
                                                transacao: transacao,
                                                cofreId:  widget.cofreId,
                                          
                                              ),
                                            ),
                                          // Quando voltar da tela de Acerto, recarrega os saldos
                                          // para refletir o novo pagamento
                                          ).then((_) {
                                             Provider.of<DespesaProvider>(context, listen: false)
                                                .carregarDespesas(widget.cofreId);
                                          });
                                        },
                                        leading: CircleAvatar(
                                          backgroundColor: cor.withOpacity(0.1),
                                          child: Icon(Icons.send, color: cor, size: 20),
                                        ),
                                        title: Text(
                                          titleText, 
                                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87)
                                        ),
                                        // Ação para indicar que é clicável
                                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey), 
                                      );
                                    },
                                  ),
                                ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          const Footbarr(),
        ],
      ),
    );
  }
}