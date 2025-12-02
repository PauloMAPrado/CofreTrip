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
  // Formatador de moeda
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR', 
    symbol: 'R\$',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    
    // 🚀 DISPARA O CARREGAMENTO: Garante que a lista de cofres seja buscada assim que a Home abre.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authStore = Provider.of<AuthStore>(context, listen: false);
      final cofreProvider = Provider.of<CofreProvider>(context, listen: false);
      
      // Checagem de segurança para garantir que o UID esteja disponível e ativo
      if (authStore.usuario?.id?.isNotEmpty ?? false) {
        final userId = authStore.usuario!.id!;
        cofreProvider.carregarCofres(userId); 
      }
    });
  }
  
  // --- Widget para Exibir Cada Cofre na Lista ---
  Widget _buildCofreItem(BuildContext context, CofreModel.Cofre cofre) {
    
    final valorAlvo = cofre.valorPlano.toDouble(); 
    final valorAtual = 0.0; // Substitua pela lógica real do saldo atual do cofre!
    
    final valorAlvoFormatado = _currencyFormat.format(valorAlvo);
    final progress = valorAlvo > 0 ? (valorAtual / valorAlvo).clamp(0.0, 1.0) : 0.0;
    
    final String? cofreId = cofre.id; // O ID do cofre pode ser nulo antes de ser salvo

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          // ⚠️ VERIFICAÇÃO DE ID ANTES DE NAVEGAR
          if (cofreId == null || cofreId.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Erro: ID do cofre não encontrado.')),
            );
            return;
          }
          // Navega para o Dashboard da Viagem (Cofre.dart)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Cofre(cofreId: cofreId), // Passa o ID seguro
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

  
  // --- Renderização dos Botões (Adaptável) ---
  Widget _buildActionButtons({required bool isListEmpty}) {
    // Se a lista estiver vazia, os botões são grandes e centrais
    if (isListEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Criacofre())),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E90FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)), padding: const EdgeInsets.symmetric(vertical: 16.0)),
            child: Text('Criar Cofre', style: GoogleFonts.poppins(fontSize: 16.0, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Entracofre())),
            style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 255, 179, 72), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)), padding: const EdgeInsets.symmetric(vertical: 16.0)),
            child: Text('Entre com um código', style: GoogleFonts.poppins(fontSize: 16.0, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      );
    }
    
    // Se a lista NÃO estiver vazia, os botões são pequenos e ficam em uma Row
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Criacofre())),
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text('Criar Novo', style: GoogleFonts.poppins(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 12)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Entracofre())),
            icon: const Icon(Icons.lock_open, color: Colors.black),
            label: Text('Entrar', style: GoogleFonts.poppins(color: Colors.black)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow, padding: const EdgeInsets.symmetric(vertical: 12)),
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    // 1. Obtém o estado do CofreProvider
    final cofreProvider = context.watch<CofreProvider>();
    final List<CofreModel.Cofre> cofres = cofreProvider.cofres;
    final bool isLoading = cofreProvider.isLoading;
    final String? errorMessage = cofreProvider.errorMessage;

    // 2. Obtém a saudação (melhoria de UX)
    final authStore = context.watch<AuthStore>();
    final userName = authStore.usuario?.nome ?? "Viajante";
    final String welcomeMessage = "Boas-vindas, $userName!";
    
    // 3. Renderiza o Estado

    // A. Carregando (Tela cheia)
    if (isLoading && cofres.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    // B. Erro (Tela cheia)
    if (errorMessage != null) {
      return Scaffold(body: Center(child: Text('Erro: $errorMessage. Por favor, reinicie.', style: GoogleFonts.poppins(color: Colors.red))));
    }

    // C. Conteúdo principal
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
                    Text(
                      welcomeMessage,
                      textAlign: TextAlign.left,
                      style: GoogleFonts.lato(fontSize: 20.0, fontWeight: FontWeight.bold, color: const Color(0xFF1E90FF)),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      'Suas Viagens',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(fontSize: 24.0, fontWeight: FontWeight.bold, color: const Color(0xFF333333)),
                    ),
                    const SizedBox(height: 20.0),

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
                              children: [
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