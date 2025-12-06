import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TelaSplash extends StatelessWidget {
  const TelaSplash({super.key});

  @override
  Widget build(BuildContext context) {
    // NOTA: Não há navegação aqui (Navigator.push).
    // O main.dart está observando o AuthStore. Assim que o AuthStore
    // decidir se o usuário está logado ou não, o main.dart troca esta tela.

    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FB),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/images/logo.png',
              width: 200,
            ),
            const SizedBox(height: 40),

            // Loading
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E90FF)),
            ),
            
            const SizedBox(height: 20),

            Text(
              'Preparando sua viagem...',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: const Color(0xFF2F2F2F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}