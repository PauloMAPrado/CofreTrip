import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Primeira tela (Splash Screen)
class TelaSplash extends StatelessWidget {
  const TelaSplash({super.key});

  @override
  Widget build(BuildContext context) {
    // REMOVIDO O GESTURE DETECTOR / ONTAP
    // A navegação é automática pelo main.dart (AuthStore)
    
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FB),
      body: Center( // Centraliza tudo
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 250,
            ),
            const SizedBox(height: 20),

            const CircularProgressIndicator(
               valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E90FF)),
            ),
            
            const SizedBox(height: 16),

            Text(
              'Carregando...',
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