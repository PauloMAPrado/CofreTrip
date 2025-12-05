import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../stores/PerfilProvider.dart'; // Seu PerfilProvider
import 'package:travelbox/utils/feedbackHelper.dart';
import 'package:travelbox/views/modules/header.dart';

class Remake extends StatefulWidget {
  const Remake({super.key});

  @override
  _RemakeState createState() => _RemakeState();
}

class _RemakeState extends State<Remake> {
  final TextEditingController _novaSenhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();

  @override
  void dispose() {
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }
  
  void _handleChangePassword(PerfilProvider perfilProvider) async {
    final novaSenha = _novaSenhaController.text.trim();
    final confirmarSenha = _confirmarSenhaController.text.trim();

    if (novaSenha.isEmpty || confirmarSenha.isEmpty) {
      FeedbackHelper.mostrarErro(context, "Preencha ambos os campos de senha.");
      return;
    }
    if (novaSenha != confirmarSenha) {
      FeedbackHelper.mostrarErro(context, "As senhas não coincidem.");
      return;
    }
    if (novaSenha.length < 6) {
      FeedbackHelper.mostrarErro(context, "A senha deve ter no mínimo 6 caracteres.");
      return;
    }

    // Chama o método no PerfilProvider
    bool sucesso = await perfilProvider.alterarSenha(novaSenha);
    
    if (sucesso && mounted) {
      FeedbackHelper.mostrarSucesso(context, perfilProvider.successMensage ?? "Senha alterada com sucesso!");
      Navigator.pop(context); // Volta para a tela Account
    } else if (!sucesso && perfilProvider.errorMensage != null) {
      FeedbackHelper.mostrarErro(context, perfilProvider.errorMensage);
    }
  }


  @override
  Widget build(BuildContext context) {
    // Lemos o PerfilProvider para controle de loading
    final perfilProvider = context.watch<PerfilProvider>();
    final isLoading = perfilProvider.isloading;

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

                      //Título
                      Text('Alterar Senha', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 17.0, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 0, 0, 0))),
                      const SizedBox(height: 180.0),

                      //Nova Senha
                      TextField(
                        controller: _novaSenhaController,
                        obscureText: true,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          labelText: 'Nova senha',
                          labelStyle: GoogleFonts.poppins(),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: GoogleFonts.poppins(),
                      ),
                      const SizedBox(height: 16.0),

                      //Confirmar Senha
                      TextField(
                        controller: _confirmarSenhaController,
                        obscureText: true,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          labelText: 'Confirmar nova senha',
                          labelStyle: GoogleFonts.poppins(),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: GoogleFonts.poppins(),
                      ),
                      const SizedBox(height: 45.0),

                      ElevatedButton(
                        onPressed: isLoading ? null : () => _handleChangePassword(perfilProvider), // CHAMA A FUNÇÃO DE MUDANÇA
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E90FF),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        ),
                        child: isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text('Confirmar Senha', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      const SizedBox(height: 30.0),
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