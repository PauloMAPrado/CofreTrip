import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:travelbox/services/authProvider.dart';
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

  @override
  Widget build(BuildContext context) {
    final authStore = context.watch<AuthStore>();

    final isLoading = authStore.actionStatus == ActionStatus.loading;

    return Scaffold(
      backgroundColor: const Color(0xFF1E90FF),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          //header azul
          const Header(),

          //container
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

                    //Título
                    Text(
                      'Login de Usuário',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    const SizedBox(height: 180.0),

                    //CPF -> USADO COMO EMAIL PARA FIREBASE
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        labelText: 'Email', // MUDANÇA
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(height: 16.0),

                    //Senha
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(height: 10.0),

                    //Recuperação de senha
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Recover(),
                                  ),
                                );
                              },
                        child: Text(
                          'Recuperação de Senha',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color.fromARGB(255, 0, 0, 0),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    //Login
                    ElevatedButton(
                      
                      
                      // LIGAÇÃO DA FUNÇÃO CORRIGIDA
                      onPressed: isLoading ? null : () async {
                        // 1. CAPTURAR O STORE ANTES (Técnica "Capture Before")
                        // Pegamos a referência do "Garçom" enquanto é seguro usar o context.
                        final authStore = context.read<AuthStore>();

                        // 2. Executa a ação usando a variável capturada (authStore)
                        // Note que não usamos 'context.read' aqui, usamos a variável 'authStore' direto.
                        bool sucesso = await authStore.signIn(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            );

                        // 3. Verificação de segurança moderna
                        // Tente usar '!context.mounted' se seu Flutter for recente, é mais preciso.
                        if (!context.mounted) return;

                        // 4. Lidar com o erro
                        if (!sucesso) {
                          // AGORA O PULO DO GATO:
                          // Lemos o erro da variável 'authStore' que capturamos lá em cima.
                          // Não precisamos fazer 'context.read' de novo! Isso elimina o erro do linter.
                          String? erroCru = authStore.errorMessage;
                          
                          // Aqui usamos o context apenas para mostrar o visual, o que é permitido após a checagem
                          FeedbackHelper.mostrarErro(context, erroCru);
                        }
                      }, 

//====================================TESTE===========================================

/*

                      onPressed: isLoading ? null : () async {
                        // Debug 1: Avisa que clicou
                        print("--- INICIANDO LOGIN ---");
                        
                        final authStore = context.read<AuthStore>();

                        bool sucesso = await authStore.signIn(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            );

                        // Debug 2: Vê o resultado do Store
                        print("--- LOGIN FINALIZADO ---");
                        print("Sucesso: $sucesso");
                        print("Mensagem de erro no Store: ${authStore.errorMessage}");

                        if (!context.mounted) return;

                        if (!sucesso) {
                          print("--- ENTRANDO NO BLOCO DE ERRO ---");
                          
                          String? erroCru = authStore.errorMessage;
                          
                          // Debug 3: Vê o que está sendo enviado para o Helper
                          print("Enviando para FeedbackHelper: $erroCru");
                          
                          FeedbackHelper.mostrarErro(context, erroCru);
                        } else {
                          print("--- LOGIN FOI UM SUCESSO (Não deve mostrar erro) ---");
                        }
                      },


*/



//====================================TESTE===========================================

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
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Login',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Não tem uma conta?',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),

                        //Botão
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Register(),
                                    ),
                                  );
                                },
                          child: Text(
                            'Cadastre-se',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color.fromARGB(255, 0, 0, 0),
                              decoration: TextDecoration.underline,
                            ),
                          ),
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
