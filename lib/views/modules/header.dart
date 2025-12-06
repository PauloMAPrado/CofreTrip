import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120, // Altura fixa para o cabeçalho
      color: const Color(0xFF1E90FF),
      child: Stack(
        children: [
          // Logo (Esquerda)
          Positioned(
            top: 40, // Ajuste fino para status bar
            left: 20,
            child: Image.asset(
              'assets/images/logosemletra.png',
              height: 60, // Tamanho ajustado
            ),
          ),
          
          // Texto (Direita)
          Positioned(
            top: 55, // Alinhado visualmente com a logo
            right: 30,
            child: Text(
              'CofreTrip',
              style: GoogleFonts.poppins(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}