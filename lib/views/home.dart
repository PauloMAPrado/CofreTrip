import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelbox/views/criacofre.dart';
import 'package:travelbox/views/entracofre.dart';
import 'package:travelbox/views/modules/footbar.dart';
import 'package:travelbox/views/modules/header.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controllers/cofreProvider.dart'; 
import '../services/authProvider.dart'; 
import '../models/cofre.dart' as CofreModel; 
import 'cofre.dart'; 

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Flag para controle de carregamento inicial (Sinconização)
  bool _isInitialLoad = true; 
  
  // Formatador de moeda
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR', 
    symbol: 'R\$',
    decimalDigits: 0,
  );

  // 🚀 Lógica de carregamento de dados (Chamado uma vez ao entrar na tela)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (_isInitialLoad) {
      final authStore = Provider.of<AuthStore>(context, listen: false);
      final cofreProvider = Provider.of<CofreProvider>(context, listen: false);
      
      if (authStore.usuario?.id?.isNotEmpty ?? false) {
        final userId = authStore.usuario!.id!;
        cofreProvider.carregarCofres(userId); 
      }
      
      _isInitialLoad = false;
    }
  }
  
  // --- Widget para Exibir Cada Cofre na Lista (Item) ---
  Widget _buildCofreItem(BuildContext context, CofreModel.Cofre cofre) {
    
    final valorAlvo = cofre.valorPlano.toDouble(); 
    final valorAtual = 0.0;
    
    final valorAlvoFormatado = _currencyFormat.format(valorAlvo);
    final progress = valorAlvo > 0 ? (valorAtual / valorAlvo).clamp(0.0, 1.0) : 0.0;
    
    final String? cofreId = cofre.id; 

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          if (cofreId == null || cofreId.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro: ID do cofre não encontrado.')));
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Cofre(cofreId: cofreId), 
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cofre.nome,
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E90FF)),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Meta: $valorAlvoFormatado',
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1E90FF)),
                minHeight: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  // --- Renderização dos Botões (Adaptável e Finalizado) ---
  Widget _buildActionButtons({required bool isListEmpty}) {
    const Color highlightColor = Color.fromARGB(255, 255, 179, 72); 
    const Color primaryColor = Color(0xFF1E90FF);

    // ESTADO 1: LISTA VAZIA (Botões grandes e empilhados)
    if (isListEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // BOTÃO CRIAR COFRE (AZUL PRIMÁRIO)
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Criacofre())),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)), padding: const EdgeInsets.symmetric(vertical: 16.0)),
            child: Text('Criar Cofre', style: GoogleFonts.poppins(fontSize: 16.0, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16.0),
          // BOTÃO ENTRAR COM CÓDIGO (LARANJA/AMARELO)
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Entracofre())),
            style: ElevatedButton.styleFrom(backgroundColor: highlightColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)), padding: const EdgeInsets.symmetric(vertical: 16.0)),
            child: Text('Entre com um código', style: GoogleFonts.poppins(fontSize: 16.0, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      );
    }
    
    // ESTADO 2: LISTA CHEIA (Botões pequenos lado a lado - Paleta Corrigida)
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          // BOTÃO CRIAR NOVO (AZUL PRIMÁRIO)
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Criacofre())),
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text('Criar Novo', style: GoogleFonts.poppins(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(vertical: 12)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          // BOTÃO ENTRAR (LARANJA/AMARELO)
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Entracofre())),
            icon: const Icon(Icons.lock_open, color: Colors.white), // Ícone Branco para contraste
            label: Text('Entrar', style: GoogleFonts.poppins(color: Colors.white)), // Texto Branco para contraste
            style: ElevatedButton.styleFrom(backgroundColor: highlightColor, padding: const EdgeInsets.symmetric(vertical: 12)),
          ),
        ),
      ],
    );
  }

  // --- Cartão de Estatísticas Simples (Omitido para brevidade, mas deve existir no código) ---
  Widget _buildStatsCard(int totalCofres, double totalMetas) {
    // ... (Implementação do Cartão de Estatísticas)
    return const SizedBox.shrink(); // Placeholder
  }


  @override
  Widget build(BuildContext context) {
    // 1. Obtém o estado
    final cofreProvider = context.watch<CofreProvider>();
    final authStore = context.watch<AuthStore>();

    final List<CofreModel.Cofre> cofres = cofreProvider.cofres;
    final bool isLoading = cofreProvider.isLoading;
    final String? errorMessage = cofreProvider.errorMessage;

    // Estatísticas (Cálculo)
    final int totalCofres = cofres.length;
    final double totalMetas = cofres.fold(0.0, (sum, cofre) => sum + cofre.valorPlano);

    final userName = authStore.usuario?.nome ?? "Viajante";
    final String welcomeMessage = "Boas-vindas, $userName!";
    
    // --- RENDERIZAÇÃO DE ESTADOS ---
    if (isLoading && cofres.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    if (errorMessage != null) {
      return Scaffold(body: Center(child: Text('Erro: $errorMessage. Por favor, reinicie.', style: GoogleFonts.poppins(color: Colors.red))));
    }

    final bool isListEmpty = cofres.isEmpty;

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
                    const SizedBox(height: 30.0),
                    // SAUDAÇÃO
                    Text(
                      welcomeMessage,
                      textAlign: TextAlign.left,
                      style: GoogleFonts.lato(fontSize: 20.0, fontWeight: FontWeight.bold, color: const Color(0xFF1E90FF)),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      'Minhas Viagens',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(fontSize: 24.0, fontWeight: FontWeight.bold, color: const Color(0xFF333333)),
                    ),
                    const SizedBox(height: 10.0),

                    // CARTÃO DE ESTATÍSTICAS
                    if (!isListEmpty) 
                      _buildStatsCard(totalCofres, totalMetas),
                    
                    // D. Renderiza Lista ou Tela Vazia
                    Expanded(
                      child: isListEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Mensagem de incentivo
                                Text('Aparentemente você não tem cofres. Crie ou entre em um!', textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.black54)),
                                const SizedBox(height: 40),
                                // Botões grandes e centrais
                                _buildActionButtons(isListEmpty: true), 
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Título da Lista
                                Text('Minhas Viagens Ativas (${totalCofres})', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                                const SizedBox(height: 10.0),
                                
                                // Botões pequenos (Criar/Entrar)
                                _buildActionButtons(isListEmpty: false),
                                const SizedBox(height: 10.0),
                                
                                // Lista de Cofres
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: cofres.length,
                                    itemBuilder: (context, index) {
                                      return _buildCofreItem(context, cofres[index]);
                                    },
                                  ),
                                ),
                              ],
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