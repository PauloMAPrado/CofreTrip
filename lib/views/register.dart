import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:travelbox/services/authProvider.dart';
import 'package:travelbox/utils/feedbackHelper.dart';
import 'package:travelbox/views/login.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:travelbox/views/modules/header.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  final _phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  final cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  Widget build(BuildContext context) {
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
                      Text(
                        'Cadastro de Usuário',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      const SizedBox(height: 50.0),

                      //--- Campos de Texto ---
                      _buildTextField(
                        controller: _nomeController,
                        label: 'Nome completo',
                        icon: Icons.person,
                        isLoading: isLoading,
                      ),

                      _buildTextField(
                        controller: _cpfController,
                        label: 'CPF',
                        icon: Icons.badge,
                        inputType: TextInputType.number,
                        isLoading: isLoading,
                        inputFormatters: [cpfFormatter],
                      ),

                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email,
                        inputType: TextInputType.emailAddress,
                        isLoading: isLoading,
                      ),

                      _buildTextField(
                        controller: _telefoneController,
                        label: 'Telefone',
                        icon: Icons.phone_android,
                        isLoading: isLoading,
                        inputFormatters: [_phoneMask],
                      ),

                      _buildTextField(
                        controller: _senhaController,
                        label: 'Senha',
                        icon: Icons.person,
                        isLoading: isLoading,
                      ),

                      /*
                      TextField(
                        controller: _nomeController, 
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText: 'Nome',
                          labelStyle: GoogleFonts.poppins(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: GoogleFonts.poppins(),
                      ),
                      const SizedBox(height: 16.0), // Adicionado 'const'
                      //CPF
                      TextField(
                        controller: _cpfController, // NOVO: Controlador
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'CPF',
                          labelStyle: GoogleFonts.poppins(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: GoogleFonts.poppins(),
                      ),
                      const SizedBox(height: 16.0), // Adicionado 'const'
                      //Email
                      TextField(
                        controller: _emailController, // NOVO: Controlador
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: GoogleFonts.poppins(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: GoogleFonts.poppins(),
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s|,|;')),
                        ],
                      ),
                      const SizedBox(height: 16.0), // Adicionado 'const'
                      //Telefone
                      TextField(
                        controller: _telefoneController, // NOVO: Controlador
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Telefone',
                          labelStyle: GoogleFonts.poppins(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: GoogleFonts.poppins(),
                        inputFormatters: [_phoneMask],
                      ),
                      const SizedBox(height: 16.0), // Adicionado 'const'
                      //Senha
                      TextField(
                        controller: _senhaController, // NOVO: Controlador
                        obscureText: true,
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
                      const SizedBox(height: 16.0), // Adicionado 'const'
                      //Confirmar Senha
                      TextField(
                        controller:
                            _confirmarSenhaController, // NOVO: Controlador
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Confirmar Senha',
                          labelStyle: GoogleFonts.poppins(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: GoogleFonts.poppins(),
                      ),

*/
                      const SizedBox(height: 45.0), // Adicionado 'const'
                      //Botão de Cadastro
                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                FocusScope.of(context).unfocus();

                                final authStore = context.read<AuthStore>();

                                bool sucesso = await authStore.signUp(
                                  nome: _nomeController.text.trim(),
                                  email: _emailController.text.trim(),
                                  telefone: _telefoneController.text.trim(),
                                  password: _senhaController.text.trim(),
                                  cpf: _cpfController.text.trim(),
                                );

                                if (!context.mounted) return;

                                // FEEDBACK
                                if (sucesso) {
                                  FeedbackHelper.mostrarSucesso(
                                    context,
                                    "Conta criada com sucesso! Bem-vindo.",
                                  );

                                  Navigator.of(context).pop();
                                } else {
                                  FeedbackHelper.mostrarErro(
                                    context,
                                    authStore.errorMessage,
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF1E90FF,
                          ), // Adicionado 'const'
                          padding: const EdgeInsets.symmetric(
                            vertical: 16.0,
                          ), // Adicionado 'const'
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
                                'Cadastrar',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      const SizedBox(height: 25), // Adicionado 'const'

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Já possui uma conta?',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),

                          //Botão Login
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Login(),
                                ), // Adicionado 'const'
                              );
                            },
                            child: Text(
                              'Logue agora',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color.fromARGB(
                                  255,
                                  0,
                                  0,
                                  0,
                                ), // Adicionado 'const'
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 30.0,
                      ), // Adicionado 'const' para espaçamento inferior
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

  // Widget auxiliar para não repetir código dos TextFields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isObscure = false,
    bool isLoading = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: inputType,
      enabled: !isLoading,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(),
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        filled: true,
        fillColor: Colors.white,
      ),
      style: GoogleFonts.poppins(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
