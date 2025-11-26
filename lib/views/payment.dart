import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelbox/views/modules/footbar.dart';
import 'package:travelbox/views/modules/header.dart';

class Pagamento extends StatefulWidget {
  const Pagamento({super.key});

  @override
  _PagamentoState createState() => _PagamentoState();
}

class _PagamentoState extends State<Pagamento> {
  
  
  @override
  Widget build(BuildContext context) {
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
                child: Center( 
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.construction,
                        color: const Color.fromARGB(255, 255, 187, 0), // Amarelo de aviso
                        size: 100,
                      ),
                      const SizedBox(height: 30.0),

                      // TÍTULO DE AVISO
                      Text(
                        'Pagamento em Construção',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      
                      Text(
                        'A funcionalidade de pagamento via Pix/Cartão está sendo integrada. Pedimos desculpas pelo inconveniente.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 16.0,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); 
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E90FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: Text(
                          'Voltar para o Premium',
                          style: GoogleFonts.poppins(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20.0),

                      Text(
                        'Dúvidas: (62) 99520-4949',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14.0,
                          color: Colors.grey[600],
                        ),
                      ),
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