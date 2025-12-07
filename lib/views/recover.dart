import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../stores/authStore.dart';
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

  @override
  Widget build(BuildContext context) {
    // Assistimos o store APENAS para loading
    final authStore = context.watch<AuthStore>();
    final isLoading = authStore.actionStatus == ActionStatus.loading;

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
                borderRadius: BorderRadius.only(topLeft: Radius.circular(50.0), topRight: Radius.circular(50.0)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40.0),
                      Text('Recuperação de Senha', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 18.0, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 100.0),

                      // Email
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: GoogleFonts.poppins(),
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: GoogleFonts.poppins(),
                      ),
                      const SizedBox(height: 16.0),

                      Text('Insira seu email para receber o link.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 30.0),

                      // BOTÃO ENVIAR
                      ElevatedButton(
                        onPressed: isLoading ? null : () async {
                            final email = _emailController.text.trim();
                            if (email.isEmpty) {
                                FeedbackHelper.mostrarErro(context, "Digite um email válido.");
                                return;
                            }
                            
                            // Chama o Store (sem await pois recoverPassword é void na sua implementação atual, mas podemos tratar o status)
                            // Melhor prática: Vamos confiar no estado do Store
                            final store = context.read<AuthStore>();
                            await store.recoverPassword(email: email);

                            if (!mounted) return;

                            // Verificamos o resultado
                            if (store.actionStatus == ActionStatus.success) {
                                FeedbackHelper.mostrarSucesso(context, 
                                    'Se o e-mail estiver cadastrado, você receberá um link em instantes.'
                                );
                                Navigator.pop(context);
                            } else {
                                FeedbackHelper.mostrarErro(context, store.errorMessage);
                            }
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