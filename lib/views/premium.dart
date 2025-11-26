import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelbox/views/modules/footbar.dart';
import 'package:travelbox/views/modules/header.dart';
import 'package:travelbox/views/payment.dart';

class Pro extends StatefulWidget {
  const Pro({super.key});

  @override
  State<Pro> createState() => _ProState();
}

class _ProState extends State<Pro> {
  // Lista de benefícios para construção dinâmica
  final List<Map<String, dynamic>> _benefits = [
    {'icon': Icons.flight_takeoff, 'text': 'Acesso a ofertas exclusivas de passagens e pacotes'},
    {'icon': Icons.notifications_active, 'text': 'Alertas de preços e Notificações antecipadas de promoções'},
    {'icon': Icons.calendar_month, 'text': 'Calendário de voos mais baratos do mês'},
    {'icon': Icons.auto_graph, 'text': 'Relatórios e gráficos de custo automáticos'},
    {'icon': Icons.groups, 'text': 'Cofres para mais de 7 usuários (sem limite de membros)'},
  ];

  @override
  Widget build(BuildContext context) {
    // Definimos a cor principal do Premium
    const Color primaryPremiumColor = Color.fromARGB(255, 255, 187, 0); // Amarelo/Dourado

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
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40.0),
                      
                      // TÍTULO E ÍCONE CENTRAL
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star, color: primaryPremiumColor, size: 30),
                          const SizedBox(width: 8),
                          Text(
                            'CofreTrip Pro',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 28.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Desbloqueie o potencial máximo da sua viagem!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14.0,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 30.0),

                      // --- SEÇÃO DE BENEFÍCIOS ---
                      Text(
                        'Recursos Exclusivos',
                        textAlign: TextAlign.left,
                        style: GoogleFonts.poppins(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10.0),

                      // Lista Dinâmica de Benefícios
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Column(
                          children: _benefits.map((benefit) {
                            return ListTile(
                              leading: Icon(benefit['icon'] as IconData, color: primaryPremiumColor),
                              title: Text(
                                benefit['text'] as String,
                                style: GoogleFonts.poppins(fontSize: 15.0),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 40.0),
                      
                      // --- OPÇÕES DE ASSINATURA ---
                      Text(
                        'Escolha seu Plano',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // 1. Assinatura Anual (OFERTA DESTACADA)
                      ElevatedButton(
                        onPressed: () {
                          // Navegar para a tela de Pagamento
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const Pagamento()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryPremiumColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Assinar Anual R\$119,90',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'Economize 33% | Melhor Custo-Benefício',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 15.0),
                      
                      // 2. Assinatura Mensal (Opção Padrão)
                      ElevatedButton(
                        onPressed: () {
                          // Navegar para a tela de Pagamento
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const Pagamento()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFF1E90FF), width: 2), // Borda azul
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: Text(
                          'Assinar Mensal R\$14,90',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: const Color(0xFF1E90FF),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 50.0),
                    ],
                  ),
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