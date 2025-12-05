import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../stores/authStore.dart'; // Seu AuthStore
import 'package:travelbox/utils/feedbackHelper.dart';
import 'package:travelbox/views/modules/header.dart';


class Recover extends StatefulWidget {
  const Recover({super.key});

  @override
  _RecoverState createState() => _RecoverState();
}

class _RecoverState extends State<Recover> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // --- Lógica de Disparo e Listener ---
  @override
  Widget build(BuildContext context) {
    final authStore = context.watch<AuthStore>();
    final isLoading = authStore.actionStatus == ActionStatus.loading;
    
    // Listener para feedback
    WidgetsBinding.instance.addPostFrameCallback((_) {
        // Verifica se a operação terminou com SUCESSO
        if (authStore.actionStatus == ActionStatus.success) {
            FeedbackHelper.mostrarSucesso(context, 'Link de recuperação enviado para o seu email!');
            // Volta para a tela anterior (Login)
            if (context.mounted) {
                Navigator.pop(context);
            }
        }
        // Verifica se terminou com ERRO
        else if (authStore.actionStatus == ActionStatus.error && authStore.errorMessage != null) {
            FeedbackHelper.mostrarErro(context, authStore.errorMessage);
        }
        
        // Garante que o status seja resetado após o feedback
        // Garante que o status seja resetado após o feedback
        if (authStore.actionStatus != ActionStatus.initial) {
          authStore.resetActionStatus(); 
        }
    });

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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40.0),

                      Text('Recuperação de Senha', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 17.0, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 0, 0, 0))),
                      const SizedBox(height: 180.0),

                      // Email
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: GoogleFonts.poppins(),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: GoogleFonts.poppins(),
                      ),
                      const SizedBox(height: 16.0),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Insira seu email para receber o link de recuperação', style: GoogleFonts.poppins(fontSize: 12, color: const Color.fromARGB(255, 0, 0, 0))),
                        ],
                      ),

                      const SizedBox(height: 16.0),

                      // BOTÃO ENVIAR
                      ElevatedButton(
                        onPressed: isLoading ? null : () {
                            final email = _emailController.text.trim();
                            if (email.isEmpty) {
                                FeedbackHelper.mostrarErro(context, "Digite um email válido.");
                                return;
                            }
                            // CHAMA O PROVIDER
                            context.read<AuthStore>().recoverPassword(email: email);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E90FF),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        ),
                        child: isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text('Enviar', style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}