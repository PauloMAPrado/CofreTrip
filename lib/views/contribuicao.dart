import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelbox/views/modules/footbar.dart';
import 'package:travelbox/views/modules/header.dart';
import 'package:travelbox/views/payment.dart';

class Contribuicao extends StatefulWidget {
  const Contribuicao({super.key});

  @override
  _ContribuicaoState createState() => _ContribuicaoState();
}

class _ContribuicaoState extends State<Contribuicao> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E90FF),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Header(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 40.0),
                    Text(
                      'Selecione os dados para fazer sua contribuição ao cofre:',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 20.0,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    // campos de entrada: valor e forma de pagamento
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Valor da Contribuição',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20.0),
                    // Dropdown para forma de pagamento
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Forma de Pagamento',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'cartao',
                          child: Text('Cartão de Crédito'),
                        ),
                        DropdownMenuItem(
                          value: 'boleto',
                          child: Text('Boleto Bancário'),
                        ),
                        DropdownMenuItem(
                          value: 'pix',
                          child: Text('PIX'),
                        ),
                      ],
                      onChanged: (value) {
                        // Lógica para lidar com a seleção
                      },
                    ),
                    SizedBox(height: 40.0),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Pagamento()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 255, 187, 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: Text(
                          'Fazer Contribuição',
                          style: GoogleFonts.poppins(
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Footbarr(),
        ],
      ),
    );
  }
}