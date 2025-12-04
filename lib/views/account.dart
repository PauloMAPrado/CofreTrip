import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/authProvider.dart';
import 'login.dart'; 
import 'package:travelbox/views/modules/footbar.dart';
import 'package:travelbox/views/modules/header.dart';
import 'package:travelbox/views/premium.dart';
import 'package:travelbox/views/home.dart'; 

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  // --- Controladores e Estado Local ---
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  
  // NOVO ESTADO: Controla se a edição está ativa
  bool _isEditing = false; 

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  // --- Funções de Ação ---
  void _handleSave(AuthStore authStore) {
    if (!_isEditing) {
      // Se não estiver editando, entra no modo de edição
      setState(() {
        _isEditing = true;
      });
      return;
    }
    
    // Se estiver editando, SALVA (Lógica de Backend)
    // Todo: Chamar o método de atualização do Firestore aqui, usando os controllers
    
    setState(() {
      _isEditing = false; // Sai do modo de edição após salvar
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dados prontos para salvar.')),
    );
  }

  void _handleLogout(AuthStore authStore) async {
    await authStore.signOut(); // O main.dart cuida do redirecionamento
  }

  // --- Widgets de Visualização ---

  // Componente reutilizável para exibir dados no modo de visualização ou edição
  Widget _buildProfileField({
    required String label, 
    required TextEditingController controller, 
    bool editable = true, 
    TextInputType keyboardType = TextInputType.text,
  }) {
    // Determina o estado de edição
    bool readOnly = !_isEditing || !editable;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: readOnly ? Colors.black54 : Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            // Muda a borda se estiver editável
            borderSide: BorderSide(color: readOnly ? Colors.grey.shade300 : const Color(0xFF1E90FF), width: 1.5),
          ),
          filled: true,
          fillColor: readOnly ? Colors.grey[50] : Colors.white, // Cor diferente para 'read-only'
        ),
        style: GoogleFonts.poppins(color: Colors.black),
      ),
    );
  }

  // Widget para a tela de Acesso Rápido/Deslogado (Mantido)
  Widget _buildLoggedOutView(BuildContext context) {
    // ... (Mantido o código de LoggedOutView) ...
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Acesse sua conta para gerenciar seu perfil e cofres.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E90FF),
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30),
              ),
              child: Text(
                'Entrar / Cadastrar',
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para a tela de Perfil Logado (Refatorado)
  Widget _buildLoggedInView(BuildContext context, AuthStore authStore) {
    // Carrega dados iniciais do Store para os Controladores (se ainda não carregou)
    final usuario = authStore.usuario;
    if (_nomeController.text.isEmpty && usuario != null) {
  
  // CORREÇÃO: Removemos o operador ?? '' onde a propriedade é String (não nula)
      _nomeController.text = usuario.nome;       
      _cpfController.text = usuario.cpf;         
      _emailController.text = usuario.email;     
  
  // MANTEMOS ?? '' APENAS ONDE A PROPRIEDADE É String? (Anulável)
      _telefoneController.text = usuario.telefone ?? ''; 
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40.0),
            Text(
              'Dados do Usuário',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 17.0,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            const SizedBox(height: 20.0),

            // CAMPOS DE PERFIL (usando o novo componente)
            _buildProfileField(label: 'Nome', controller: _nomeController),
            _buildProfileField(label: 'CPF', controller: _cpfController, keyboardType: TextInputType.number),
            _buildProfileField(label: 'Email', controller: _emailController, editable: false, keyboardType: TextInputType.emailAddress),
            _buildProfileField(label: 'Telefone', controller: _telefoneController, keyboardType: TextInputType.phone),
            
            const SizedBox(height: 30.0), 

            // 1. Botão Salvar/Editar
            ElevatedButton(
              onPressed: () => _handleSave(authStore), // LÓGICA DE MUDANÇA DE MODO
              style: ElevatedButton.styleFrom(
                backgroundColor: _isEditing ? const Color.fromARGB(255, 0, 218, 11) : const Color(0xFF1E90FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: Text(
                _isEditing ? 'Salvar Alterações' : 'Editar Perfil', // TEXTO DINÂMICO
                style: GoogleFonts.poppins(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),

            const SizedBox(height: 50.0),

            // 2. Botão Seja Pro
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const Pro()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 187, 0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: Text(
                'Seja Pro',
                style: GoogleFonts.poppins(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),

            // 3. Meus Cofres
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const Home())); 
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E90FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: Text(
                'Meus Cofres',
                style: GoogleFonts.poppins(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),

            // 4. Sair da Conta
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _handleLogout(authStore), // CHAMA A LÓGICA DE LOGOUT
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: Text(
                'Sair da Conta',
                style: GoogleFonts.poppins(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 50.0),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. OBTÉM O AUTHSTORE
    return Consumer<AuthStore>(
      builder: (context, authStore, child) {
        final isLoggedIn = authStore.isLoggedIn;

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
                  // 2. CONDIÇÃO: Mostra a UI de Login ou a UI de Perfil
                  child: isLoggedIn
                      ? _buildLoggedInView(context, authStore)
                      : _buildLoggedOutView(context),
                ),
              ),
              const Footbarr(),
            ],
          ),
        );
      },
    );
  }
}
