// Imports essenciais
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

//Imports das Views
import 'package:travelbox/views/modules/footbar.dart';
import 'package:travelbox/views/modules/header.dart';

// Imports dos Stores
import 'package:travelbox/stores/cofreStore.dart';
import 'package:travelbox/stores/authStore.dart';

// Import do utils
import 'package:travelbox/utils/feedbackHelper.dart';


class Entracofre extends StatefulWidget {
  const Entracofre({super.key});

  @override
  _EntracofreState createState() => _EntracofreState();
}

class _EntracofreState extends State<Entracofre> {
  // --- Controladores e Serviços ---
  final TextEditingController _codigoController = TextEditingController();

/*         se tiver dando Erro tira esse codigo do comentario 
  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }
*/

  @override
  Widget build(BuildContext context) {

    final cofreStore = context.watch<CofreStore>();
    final isLoading = cofreStore.isLoading;


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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40.0),
                    Text(
                      'Insira o código para entrar no cofre',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 17.0,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),

                    const SizedBox(height: 20.0),


                    // CAMPO PARA CÓDIGO
                    TextField(
                      controller: _codigoController, 
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.characters,
                      enabled: !isLoading, 
                      decoration: InputDecoration(
                        labelText: 'Código do Cofre',
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        filled: true,
                        fillColor: Colors.white,

                      ),
                      // NOVO: Restringe a entrada a caracteres alfanuméricos
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')), 
                        LengthLimitingTextInputFormatter(6),// Limita o código a 6 caracteres
                      ],
                    ),

                    const SizedBox(height: 20.0),

                    // BOTÃO DE CONFIRMAR
                    ElevatedButton(
                    onPressed: isLoading ? null : () async {
                      FocusScope.of(context).unfocus();
                        final codigo = _codigoController.text.trim();

                        if (codigo.isEmpty) {
                          FeedbackHelper.mostrarErro(context, "Digite o código.");
                          return;
                        }

                        // Lógica com Stores
                        final authStore = context.read<AuthStore>();
                        final store = context.read<CofreStore>();

                        if (authStore.usuario?.id == null) return;

                        // Chama a ação
                        String? erro = await store.entrarComCodigo(
                          codigo, 
                          authStore.usuario!.id!
                        );

                        if (!mounted) return;

                        if (erro == null) {
                          // Sucesso
                          FeedbackHelper.mostrarSucesso(context, "Você entrou no cofre!");
                          Navigator.pop(context); // Volta para a Home atualizada
                        } else {
                          // Erro
                          FeedbackHelper.mostrarErro(context, erro);
                        }
                    },
                    
                     // LIGADO À LÓGICA
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E90FF),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                      'Entrar no Cofre',
                      style: GoogleFonts.poppins(
                          fontSize: 18, color: Colors.white),
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