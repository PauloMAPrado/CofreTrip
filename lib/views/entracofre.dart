import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para FilteringTextInputFormatter
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:travelbox/views/modules/footbar.dart';
import 'package:travelbox/views/modules/header.dart';
import '../stores/cofreStore.dart'; // Seu CofreProvider
import '../services/authProvider.dart'; // Seu AuthStore
import 'home.dart';
class Entracofre extends StatefulWidget {
  const Entracofre({super.key});

  @override
  _EntracofreState createState() => _EntracofreState();
}

class _EntracofreState extends State<Entracofre> {
  // --- Controladores e Serviços ---
  final TextEditingController _codigoController = TextEditingController();
  bool _isLoading = false;

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // --- Lógica de Entrar no Cofre ---
  Future<void> _handleJoinCofre() async {
    // 1. Inicia o Loading
    setState(() {
      _isLoading = true;
    });

    final codigoAcesso = _codigoController.text.trim().toUpperCase();

    if (codigoAcesso.isEmpty) {
      _showSnackBar('Insira um código de acesso.', isError: true);
      setState(() {
        _isLoading = false;
      });
      return;
    }
    
    // --- ACESSA PROVIDERS E VERIFICAÇÃO DE SEGURANÇA ---
    final cofreProvider = Provider.of<CofreStore>(context, listen: false);
    final authStore = Provider.of<AuthStore>( context, listen: false);

    // 2. Verifica se o usuário está logado
    if (authStore.usuario?.id == null) {
        _showSnackBar('Você precisa estar logado para entrar em um cofre.', isError: true);
        setState(() { _isLoading = false; });
        return;
    }
    
    final String userId = authStore.usuario!.id!;

    // 3. Chama o Provider para buscar e se juntar ao cofre
    final String? errorMessage = await cofreProvider.entrarComCodigo(
      codigoAcesso,
      userId,
    );

    setState(() {
      _isLoading = false;
    });

    if (errorMessage == null) {
      // SUCESSO! Agora, navegamos para a tela de lista (Home) para que o novo cofre apareça
      _showSnackBar('Cofre acessado com sucesso! Redirecionando...', isError: false);

      // 4. NAVEGAÇÃO FINAL para a lista (Home), pois o cofreProvider já atualizou a lista
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const Home(),
          ),
        );
      }
    } else {
      // FALHA!
      _showSnackBar(errorMessage, isError: true);
    }
  }
  
  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
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
                      controller: _codigoController, // LIGADO AO CONTROLADOR
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.characters, // Garante que o input é maiúsculo
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
                    onPressed: _isLoading ? null : _handleJoinCofre, // LIGADO À LÓGICA
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E90FF),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: _isLoading
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