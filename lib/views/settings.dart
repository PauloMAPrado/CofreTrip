import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelbox/views/modules/footbar.dart';
import 'package:travelbox/views/modules/header.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E90FF),
      body: Column(
        children: [
          const Header(),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text('Configurações', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 30),
                    
                    ListTile(
                      leading: const Icon(Icons.info_outline, color: Color(0xFF1E90FF)),
                      title: Text('Sobre o CofreTrip', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      subtitle: Text('Versão 1.0.0', style: GoogleFonts.poppins(fontSize: 12)),
                      onTap: () {
                        // Mostrar diálogo sobre
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined, color: Color(0xFF1E90FF)),
                      title: Text('Termos e Privacidade', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {},
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