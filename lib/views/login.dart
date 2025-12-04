import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/authProvider.dart'; 
import 'package:travelbox/utils/feedbackHelper.dart';
import 'package:travelbox/views/modules/header.dart';

import 'register.dart';
import 'recover.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController(); 
  final TextEditingController _passwordController = TextEditingController();

  // Removido _isLoading local, pois será lido do AuthStore.actionStatus

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lê o estado para controlar o loading e ver mensagens de erro
    final authStore = context.watch<AuthStore>();
    final isLoading = authStore.actionStatus == ActionStatus.loading;
    final errorMessage = authStore.errorMessage; // Para o listener

    // Listener para feedback de erro (se o Provider retornar erro após a tentativa)
    // Opcional: Você pode querer usar WidgetsBinding ou um ProviderListener aqui se não quiser o Consumer no build
    WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!isLoading && authStore.actionStatus == ActionStatus.error && errorMessage != null) {
            FeedbackHelper.mostrarErro(context, errorMessage);
            // Limpa o erro após a exibição para evitar repetição
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40.0), 
                      Text('Login de Usuário', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 17.0, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 0, 0, 0))),
                      const SizedBox(height: 180.0), 

                      // EMAIL
                      TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, enabled: !isLoading, decoration: InputDecoration(labelText: 'Email', labelStyle: GoogleFonts.poppins(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)), filled: true, fillColor: Colors.white), style: GoogleFonts.poppins()),
                      const SizedBox(height: 16.0), 

                      // SENHA
                      TextField(controller: _passwordController, obscureText: true, enabled: !isLoading, decoration: InputDecoration(labelText: 'Senha', labelStyle: GoogleFonts.poppins(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)), filled: true, fillColor: Colors.white), style: GoogleFonts.poppins()),
                      const SizedBox(height: 10.0), 

                      // Recuperação de senha
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: isLoading ? null : () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Recover())),
                          child: Text('Recuperação de Senha', style: GoogleFonts.poppins(fontSize: 12, color: const Color.fromARGB(255, 0, 0, 0), decoration: TextDecoration.underline)),
                        ),
                      ),
                      
                      onPressed: isLoading ? null : () async {
                        final authStore = context.read<AuthStore>();

                        bool sucesso = await authStore.signIn(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            );

                        if (!context.mounted) return;

                        if (!sucesso) {
                          String? erroCru = authStore.errorMessage;
                          
                          FeedbackHelper.mostrarErro(context, erroCru);
                        }
                      }, 

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E90FF),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text('Login', style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
                      ),
                      const SizedBox(height: 25),

                      // CADASTRE-SE
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Não tem uma conta?', style: GoogleFonts.poppins(fontSize: 12, color: const Color.fromARGB(255, 0, 0, 0))),
                          TextButton(
                            onPressed: isLoading ? null : () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Register())),
                            child: Text('Cadastre-se', style: GoogleFonts.poppins(fontSize: 12, color: const Color.fromARGB(255, 0, 0, 0), decoration: TextDecoration.underline)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
      ),
    );
  }
}

