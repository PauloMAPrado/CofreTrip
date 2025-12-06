import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// VIEWS
import 'package:travelbox/views/criacofre.dart';
import 'package:travelbox/views/entracofre.dart';
import 'package:travelbox/views/modules/footbar.dart';
import 'package:travelbox/views/modules/header.dart';
import 'package:travelbox/views/cofre.dart';
import 'package:travelbox/views/convitesrecebidos.dart';

// STORES
import 'package:travelbox/stores/cofreStore.dart';
import 'package:travelbox/stores/authStore.dart';
import 'package:travelbox/stores/ConviteStore.dart'; // Nome corrigido (minúsculo)

// MODELS
import 'package:travelbox/models/cofre.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Controle para carregar apenas uma vez
  bool _dadosCarregados = false;

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 1. Ouvimos o AuthStore para saber se o usuário já chegou
    final authStore = Provider.of<AuthStore>(context);
    final cofreStore = Provider.of<CofreStore>(context, listen: false);
    final conviteStore = Provider.of<ConviteStore>(context, listen: false);

    // 2. Lógica de Carregamento Seguro
    // Só entra se ainda não carregou E se o usuário já existe
    if (!_dadosCarregados && authStore.usuario?.id != null) {
      
      final userId = authStore.usuario!.id!;
      
      // TRAVA O LOOP: Marcamos como carregado ANTES de chamar o provider
      _dadosCarregados = true; 

      // AGENDAMENTO: "Espere a tela terminar de desenhar, depois busque os dados"
      WidgetsBinding.instance.addPostFrameCallback((_) {
        cofreStore.carregarCofres(userId);
        conviteStore.carregarConvites(userId);
      });
    }
  }

  // --- Widget de Alerta ---
  Widget _buildInviteAlert(BuildContext context, int count) {
    if (count == 0) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      color: Colors.red.shade600,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ConvitesRecebidos()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.mail_outline, color: Colors.white, size: 30),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  'Você tem $count convite(s) pendente(s)!',
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  // --- Item da Lista de Cofres (COMPLETADO) ---
  Widget _buildCofreItem(BuildContext context, Cofre cofre) {
    // Lógica Financeira Correta:
    // Meta = valorPlano
    // Progresso = totalArrecadado (novo campo que criamos)
    final double meta = cofre.valorPlano.toDouble();
    final double arrecadado = cofre.totalArrecadado;

    // Evita divisão por zero e limita a barra visualmente a 100%
    final double progress = meta > 0 ? (arrecadado / meta).clamp(0.0, 1.0) : 0.0;

    final String metaFormatada = _currencyFormat.format(meta);
    final String arrecadadoFormatado = _currencyFormat.format(arrecadado);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          if (cofre.id == null) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CofreScreen(cofreId: cofre.id!),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título e Ícone de Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      cofre.nome,
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E90FF)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    arrecadado >= meta ? Icons.check_circle : Icons.flight_takeoff,
                    color: arrecadado >= meta ? Colors.green : const Color(0xFF1E90FF),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Barra de Progresso
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    arrecadado >= meta ? Colors.green : const Color(0xFF1E90FF)
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),

              // Textos de Valores
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Juntado', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                      Text(arrecadadoFormatado, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Meta', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                      Text(metaFormatada, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              
              // Porcentagem
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E90FF)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Botões de Ação ---
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Criacofre())),
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            label: const Text('Novo Cofre', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E90FF),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Entracofre())),
            icon: const Icon(Icons.vpn_key, color: Colors.white),
            label: const Text('Entrar', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  // --- Card de Estatísticas ---
  Widget _buildStatsCard(List<Cofre> cofres) {
    final int totalViagens = cofres.length;
    // Usa totalArrecadado para a soma geral
    final double totalGuardado = cofres.fold(0.0, (sum, c) => sum + c.totalArrecadado);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E90FF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("Viagens", totalViagens.toString()),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildStatItem("Total Guardado", _currencyFormat.format(totalGuardado)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Text(label.toUpperCase(), style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70, letterSpacing: 1)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cofreStore = context.watch<CofreStore>();
    final authStore = context.watch<AuthStore>();
    final conviteStore = context.watch<ConviteStore>();

    final user = authStore.usuario;
    final cofres = cofreStore.cofres;
    final convitesCount = conviteStore.convitesRecebidos.length;

    return Scaffold(
      backgroundColor: const Color(0xFF1E90FF),
      body: Column(
        children: [
          const Header(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF4F9FB),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50.0), 
                  topRight: Radius.circular(50.0)
                ),
              ),
              child: RefreshIndicator(
                // Ao puxar para atualizar, resetamos o flag e forçamos o load
                onRefresh: () async {
                   if(user?.id != null) {
                     await Future.wait([
                        cofreStore.carregarCofres(user!.id!),
                        conviteStore.carregarConvites(user.id!)
                     ]);
                   }
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 80),
                  children: [
                    Text(
                      "Olá, ${user?.nome ?? 'Viajante'}!",
                      style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 5),
                    Text("Vamos planejar sua próxima aventura?", style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 20),

                    _buildInviteAlert(context, convitesCount),
                    _buildStatsCard(cofres),
                    const SizedBox(height: 25),
                    _buildActionButtons(context),
                    const SizedBox(height: 25),

                    Text("Meus Cofres", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 10),

                    if (cofreStore.isLoading)
                      const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                    else if (cofres.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Column(
                            children: [
                              Icon(Icons.luggage, size: 60, color: Colors.grey[300]),
                              const SizedBox(height: 10),
                              Text("Nenhum cofre encontrado.\nCrie o seu primeiro!", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500])),
                            ],
                          ),
                        ),
                      )
                    else
                      ...cofres.map((c) => _buildCofreItem(context, c)).toList(),
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



































/*

//Imports Essenciais
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

//Imports das views para navegação
import 'package:travelbox/views/criacofre.dart';
import 'package:travelbox/views/entracofre.dart';
import 'package:travelbox/views/modules/footbar.dart';
import 'package:travelbox/views/modules/header.dart';
import 'package:travelbox/views/cofre.dart';
import 'package:travelbox/views/convitesrecebidos.dart';


//Imports dos STORES (Para o gerenciamento de estado) 
import 'package:travelbox/stores/cofreStore.dart'; 
import 'package:travelbox/stores/authStore.dart'; 
import 'package:travelbox/stores/conviteStore.dart';

//Imports Models 
import 'package:travelbox/models/cofre.dart'; 

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool _dadosCarregados = false;
  
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR', 
    symbol: 'R\$',
    decimalDigits: 2,
  );

    @override
    void didChangeDependencies() {
      super.didChangeDependencies();

      // 1. Ouvimos o AuthStore para saber se o usuário já chegou
      final authStore = Provider.of<AuthStore>(context);

      if (!_dadosCarregados && authStore.usuario?.id != null) {
        
        final userId = authStore.usuario!.id!;
        
        // Chamamos os stores sem 'listen' (apenas disparar ação)
        Provider.of<CofreStore>(context, listen: false).carregarCofres(userId);
        Provider.of<ConviteStore>(context, listen: false).carregarConvites(userId);

        // 3. Travamos para não entrar em loop infinito
        _dadosCarregados = true;
      }
    }

  void _carregarDados() {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    final cofreStore = Provider.of<CofreStore>(context, listen: false);
    final conviteStore = Provider.of<ConviteStore>(context, listen: false);

    if(authStore.usuario?.id != null){
      final userId = authStore.usuario!.id!;
      cofreStore.carregarCofres(userId);
      conviteStore.carregarConvites(userId);
    }
  }
  
  // --- Widget de Alerta de Convites Pendentes ---
  Widget _buildInviteAlert(BuildContext context, int count) {
    if (count == 0) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      color: Colors.red.shade600, // Cor de alerta
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          // 🎯 NAVEGAÇÃO: Para a tela de convites recebidos
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ConvitesRecebidos()), 
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.mail_outline, color: Colors.white, size: 30),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  'Você tem $count convite(s) pendente(s)! Toque para responder.',
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  // --- Item da Lista de Cofres ---          ++++++++++++         PAREI AQUIIIIIIIII    +++++++++++++++++++
  Widget _buildCofreItem(BuildContext context, Cofre cofre) {
    
    final double meta = cofre.valorPlano.toDouble(); 
    
    // 2. ARRECADADO (O Progresso Real - Novo Campo!)
    final double arrecadado = cofre.totalArrecadado; 
    
    // 3. CÁLCULO DA PORCENTAGEM
    // Se a meta for 0, o progresso é 0 para não dividir por zero.
    // O .clamp(0.0, 1.0) garante que a barra não estoure se você arrecadar mais que 100%.
    final double progress = meta > 0 ? (arrecadado / meta).clamp(0.0, 1.0) : 0.0;

    final String metaFormatada = _currencyFormat.format(meta);
    final String arrecadadoFormatado = _currencyFormat.format(arrecadado);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (cofre.id == null || cofre.id!.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro: ID do cofre não encontrado.')));
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CofreScreen(cofreId: cofre.id!), 
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
                  Expanded(child: Text(
                      cofre.nome,
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  Icon(
                    arrecadado >= meta ? Icons.check_circle : Icons.flight_takeoff, 
                    color: arrecadado >= meta ? Colors.green : const Color(0xFF1E90FF)
                  ),
                ],
              ),


              const SizedBox(height: 8),


              // Barra de Progresso
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    arrecadado >= meta ? Colors.green : const Color(0xFF1E90FF)
                    ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Juntado',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        arrecadadoFormatado, // Mostra quanto já entrou de dinheiro
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Meta',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        metaFormatada, // Mostra o objetivo final
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 5),
              
              // Porcentagem no rodapé
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.poppins(
                    fontSize: 12, 
                    fontWeight: FontWeight.bold, 
                    color: arrecadado >= meta ? Colors.green : const Color(0xFF1E90FF)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


/*  =========================================== codigo antigo ==================================



  // --- Renderização dos Botões (Adaptável e Finalizado) ---
  Widget _buildActionButtons({required bool isListEmpty}) {
    const Color highlightColor = Color.fromARGB(255, 255, 179, 72); 
    const Color primaryColor = Color(0xFF1E90FF);

    // ESTADO 1: LISTA VAZIA (Botões grandes e empilhados)
    if (isListEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Criacofre())),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)), padding: const EdgeInsets.symmetric(vertical: 16.0)),
            child: Text('Criar Cofre', style: GoogleFonts.poppins(fontSize: 16.0, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16.0),
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

*/  //=========================================== codigo antigo ==================================


// --- Botões de Ação (Criar/Entrar) ---
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Criacofre())),
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            label: const Text('Novo Cofre', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E90FF),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Entracofre())),
            icon: const Icon(Icons.vpn_key, color: Colors.white), // Ícone de chave/código
            label: const Text('Entrar', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent, // Cor diferente para destacar
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }







  // --- Card de Estatísticas Gerais ---
  Widget _buildStatsCard(List<Cofre> cofres) {
    final int totalViagens = cofres.length;
    // Soma o valor 'despesasTotal' de todos os cofres para saber o total arrecadado geral
    final double totalGuardado = cofres.fold(0.0, (sum, c) => sum + c.despesasTotal);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E90FF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("Viagens", totalViagens.toString()),
          Container(width: 1, height: 40, color: Colors.white24), // Divisória
          _buildStatItem("Total Guardado", _currencyFormat.format(totalGuardado)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
      return Column(
        children: [
          Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(label.toUpperCase(), style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70, letterSpacing: 1)),
        ],
      );
    }

  @override
  Widget build(BuildContext context) {
    // Assistindo os Stores
    final cofreStore = context.watch<CofreStore>();
    final authStore = context.watch<AuthStore>();
    final conviteStore = context.watch<ConviteStore>();

    final user = authStore.usuario;
    final cofres = cofreStore.cofres;
    final convitesCount = conviteStore.convitesRecebidos.length;

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
                  topRight: Radius.circular(50.0)),
              ),
              child: RefreshIndicator(
                onRefresh: () async => _carregarDados(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 80), // Espaço extra em baixo p/ navbar
                  children: [
                    // Saudação
                    Text(
                      "Olá, ${user?.nome ?? 'Viajante'}!",
                      style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Vamos planejar sua próxima aventura?",
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 20),

                    // Alertas
                    _buildInviteAlert(context, convitesCount),

                    // Estatísticas
                    _buildStatsCard(cofres),
                    const SizedBox(height: 25),

                    // Botões de Ação
                    _buildActionButtons(context),
                    const SizedBox(height: 25),

                    // Lista de Cofres
                    Text(
                      "Meus Cofres",
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 10),

                    if (cofreStore.isLoading)
                      const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                    else if (cofres.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Column(
                            children: [
                              Icon(Icons.luggage, size: 60, color: Colors.grey[300]),
                              const SizedBox(height: 10),
                              Text("Nenhum cofre encontrado.\nCrie o seu primeiro!", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500])),
                            ],
                          ),
                        ),
                      )
                    else
                      ...cofres.map((c) => _buildCofreItem(context, c)).toList(),
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

*/