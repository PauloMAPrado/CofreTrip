import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart'; // Para Input Formatters
// Importe o helper de feedback e o provider
import 'package:travelbox/utils/feedbackHelper.dart'; 
import '../stores/ConviteStore.dart';
import '../stores/authStore.dart'; 
import 'modules/header.dart';
import 'modules/footbar.dart';

class Convidar extends StatefulWidget {
  // CRÍTICO: O ID do Cofre é a chave para o convite
  final String cofreId; 

  const Convidar({super.key, required this.cofreId});

  @override 
  _ConvidarState createState() => _ConvidarState();
}

class _ConvidarState extends State<Convidar> {
  final TextEditingController _emailController = TextEditingController();
  
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleEnviarConvite() async {
    final emailDestino = _emailController.text.trim();
    
    if (emailDestino.isEmpty) {
      FeedbackHelper.mostrarErro(context, "Por favor, insira o e-mail do convidado.");
      return;
    }
    
    // 1. Acessa Providers
    final conviteProvider = Provider.of<ConviteStore>(context, listen: false);
    final authStore = Provider.of<AuthStore>(context, listen: false);
    
    // 2. Verifica segurança
    if (authStore.usuario?.id == null) {
      FeedbackHelper.mostrarErro(context, "Sua sessão é inválida. Faça login novamente.");
      return;
    }
    
    final String convidadorId = authStore.usuario!.id!;
    
    // 3. Dispara a lógica de convite
    // Assume que a lógica no Conviteprovider irá buscar o ID do convidado pelo email.
    final String? errorMessage = await conviteProvider.enviarConvite(
      emailDestino: emailDestino,
      cofreId: widget.cofreId, // Usa o ID recebido no construtor
      idUsuarioConvidador: convidadorId,
    );

    // 4. Feedback e Ação
    if (errorMessage == null) {
      FeedbackHelper.mostrarSucesso(context, "Convite enviado com sucesso para $emailDestino!");
      if (mounted) {
        Navigator.pop(context); // Volta para a tela anterior (ListaUser ou Cofre)
      }
    } else {
      FeedbackHelper.mostrarErro(context, errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuta o Provider apenas para o estado de Loading
    final conviteProvider = context.watch<ConviteStore>();
    final isLoading = conviteProvider.isLoading;

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
                borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40.0),
                      Text('Convidar Membro', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.black)),
                      const SizedBox(height: 10.0),
                      Text('Insira o e-mail da pessoa que você deseja convidar para esta viagem.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14.0, color: Colors.black54)),
                      const SizedBox(height: 50.0),
                      
                      // CAMPO E-MAIL
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !isLoading,
                        // Restrição de entrada para emails (remove espaços, vírgulas, etc.)
                        inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s|,|;')),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Email do Convidado',
                          prefixIcon: const Icon(Icons.email, color: Color(0xFF1E90FF)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      
                      // BOTÃO ENVIAR
                      ElevatedButton(
                        onPressed: isLoading ? null : _handleEnviarConvite,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E90FF),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                        ),
                        child: isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text('Enviar Convite', style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Footbarr(), // Mantendo o Footbarr para consistência
        ],
      ),
    );
  }
}