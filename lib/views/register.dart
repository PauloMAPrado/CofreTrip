import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // NOVO: Provider
import '../services/authProvider.dart'; // NOVO: AuthStore

import 'login.dart';
import 'package:travelbox/views/modules/header.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';


// ⚠️ REMOVIDA A EXTENSÃO: A lógica saveNewUser deve estar no FirestoreService
// A função _handleRegister será ligada ao AuthStore

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();

  // Removida a instância do FirestoreService local (a View não precisa dela)
  bool _isLoading = false;
  
  final _phoneMask = MaskTextInputFormatter(
      mask: '(##) #####-####', 
      filter: {"#": RegExp(r'[0-9]')});

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return; 
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // --- Lógica Principal de Cadastro (Agora chama o AuthStore) ---
  void _handleRegister() async {
    // 1. Pega os dados brutos e faz validações básicas
    final String email = _emailController.text.trim();
    final String password = _senhaController.text;
    final String confirmPassword = _confirmarSenhaController.text;
    final String nome = _nomeController.text.trim();
    final String cpf = _cpfController.text.trim();
    final String telefone = _telefoneController.text.trim();


    if (email.isEmpty || password.isEmpty || nome.isEmpty || cpf.isEmpty) {
      _showSnackBar('Preencha todos os campos obrigatórios.', isError: true);
      return;
    }
    if (password != confirmPassword) {
      _showSnackBar('As senhas não coincidem.', isError: true);
      return;
    }
    if (password.length < 6) { 
      _showSnackBar('A senha deve ter pelo menos 6 caracteres.', isError: true);
      return;
    }
    
    // 2. CHAMA O AUTHSTORE E DEIXA ELE FAZER O TRABALHO ASSÍNCRONO
    setState(() { _isLoading = true; });

    final authStore = context.read<AuthStore>();

    bool sucesso = await authStore.signUp(
      email: email,
      password: password,
      nome: nome,
      cpf: cpf,
      telefone: telefone,
    );
    
    setState(() { _isLoading = false; });

    // 3. AVALIA O RESULTADO DO STORE
    if (sucesso) {
        _showSnackBar('Cadastro concluído com sucesso!', isError: false);
        // Navega de volta para o Login (o Store já atualizou o estado)
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Login()),
            (Route<dynamic> route) => false, 
          );
        }
    } else {
        // Exibe o erro retornado pelo AuthStore (que veio do Firebase)
        _showSnackBar(authStore.errorMessage ?? 'Falha no cadastro. Tente novamente.', isError: true);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  final isLoading = _isLoading; // Mantemos o isLoading local para o build

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
                        Text('Cadastro de Usuário', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 17.0, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 0, 0, 0))),
                        const SizedBox(height: 50.0),

                        //Nome
                        TextField(controller: _nomeController, keyboardType: TextInputType.name, decoration: InputDecoration(labelText: 'Nome', labelStyle: GoogleFonts.poppins(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)), filled: true, fillColor: Colors.white), style: GoogleFonts.poppins(), enabled: !isLoading,),
                        const SizedBox(height: 16.0),

                        //CPF
                        TextField(controller: _cpfController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'CPF', labelStyle: GoogleFonts.poppins(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)), filled: true, fillColor: Colors.white), style: GoogleFonts.poppins(), enabled: !isLoading,),
                        const SizedBox(height: 16.0),

                        //Email
                        TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: 'Email', labelStyle: GoogleFonts.poppins(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)), filled: true, fillColor: Colors.white), style: GoogleFonts.poppins(), inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s|,|;')),], enabled: !isLoading,),
                        const SizedBox(height: 16.0),

                        //Telefone
                        TextField(controller: _telefoneController, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: 'Telefone', labelStyle: GoogleFonts.poppins(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)), filled: true, fillColor: Colors.white), style: GoogleFonts.poppins(), inputFormatters: [_phoneMask], enabled: !isLoading,),
                        const SizedBox(height: 16.0),

                        //Senha
                        TextField(controller: _senhaController, obscureText: true, decoration: InputDecoration(labelText: 'Senha', labelStyle: GoogleFonts.poppins(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)), filled: true, fillColor: Colors.white), style: GoogleFonts.poppins(), enabled: !isLoading,),
                        const SizedBox(height: 16.0),

                        //Confirmar Senha
                        TextField(controller: _confirmarSenhaController, obscureText: true, decoration: InputDecoration(labelText: 'Confirmar Senha', labelStyle: GoogleFonts.poppins(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)), filled: true, fillColor: Colors.white), style: GoogleFonts.poppins(), enabled: !isLoading,),
                        const SizedBox(height: 45.0),

                        //Botão de Cadastro
                        ElevatedButton(
                          onPressed: isLoading ? null : _handleRegister, 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E90FF),
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                          ),
                          child: isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text('Confirmar Cadastro', style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
                        ),
                        const SizedBox(height: 25),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Já possui uma conta?', style: GoogleFonts.poppins(fontSize: 12, color: const Color.fromARGB(255, 0, 0, 0))),
                            TextButton(onPressed: isLoading ? null : () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Login())), child: Text('Logue agora', style: GoogleFonts.poppins(fontSize: 12, color: const Color.fromARGB(255, 0, 0, 0), decoration: TextDecoration.underline))),
                          ],
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