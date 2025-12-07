import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// Stores e Models
import 'package:travelbox/stores/authStore.dart';
import 'package:travelbox/stores/PerfilStore.dart';
import 'package:travelbox/models/usuario.dart';


// Views e Utils
import 'package:travelbox/views/login.dart';
import 'package:travelbox/views/modules/footbar.dart';
import 'package:travelbox/views/modules/header.dart';
import 'package:travelbox/views/premium.dart';
import 'package:travelbox/views/home.dart';
import 'package:travelbox/utils/feedbackHelper.dart';

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

  final _phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####', 
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##', 
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void initState(){
    super.initState();
    final user = context.read<AuthStore>().usuario;
    if(user != null) {
      _nomeController.text = user.nome;
      _cpfController.text = user.cpf;
      _emailController.text = user.email;
      _telefoneController.text = user.telefone ?? '';
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  // --- logica de salvar ---
  void _handleSave() async {
    if (!_isEditing) {
      setState(() => _isEditing = true);
      return;
    }
    
    FocusScope.of(context).unfocus();

    final perfilStore = context.read<PerfilStore>();
    final authStore = context.read<AuthStore>();
    final currentUser = authStore.usuario;

    if (currentUser == null) return;

    // 2. Cria o objeto atualizado (Mantém ID e Email, atualiza o resto)
    Usuario usuarioAtualizado = currentUser.copyWith(
      nome: _nomeController.text.trim(),
      cpf: _cpfController.text.trim(),
      telefone: _telefoneController.text.trim(),
    );
    
    bool sucesso = await perfilStore.atualizarPerfil(usuarioAtualizado);

    if (!mounted) return;

    if (sucesso) {
      // 4. Importante: Atualiza o cache local do AuthStore
      await authStore.recarregarUsuario();
      
      setState(() => _isEditing = false);
      FeedbackHelper.mostrarSucesso(context, "Perfil atualizado com sucesso!");
    } else {
      FeedbackHelper.mostrarErro(context, perfilStore.errorMensage);
    }
  }

  void _handleLogout() async {
    // Buscamos o store aqui dentro
    final authStore = context.read<AuthStore>();
    
    // 1. Fecha todas as telas e volta para a raiz (Login)
    Navigator.of(context).popUntil((route) => route.isFirst);
    
    // 2. Faz o logout no Firebase
    await authStore.signOut();
  }

  // --- Widgets de Visualização ---

  // Componente reutilizável para exibir dados no modo de visualização ou edição
  Widget _buildProfileField({
    required String label, 
    required TextEditingController controller, 
    bool editable = true, 
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    // Determina o estado de edição
    bool isReadOnly = !_isEditing || !editable;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        readOnly: isReadOnly,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: isReadOnly ? Colors.black54 : Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: isReadOnly ? Colors.grey.shade300 : const Color(0xFF1E90FF), 
              width: 1.5
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: isReadOnly ? Colors.grey.shade300 : const Color(0xFF1E90FF), 
            ),
          ),
          filled: true,
          fillColor: isReadOnly ? Colors.grey[100] : Colors.white,
        ),
        style: GoogleFonts.poppins(color: Colors.black87),
      ),
    );
  }

  

  // Widget para a tela de Perfil Logado (Refatorado)
  Widget _buildLoggedInView(BuildContext context, bool isLoading) {
    
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
            _buildProfileField(label: 'CPF', controller: _cpfController, keyboardType: TextInputType.number, inputFormatters: [_cpfMask]),
            
            _buildProfileField(label: 'Email', controller: _emailController, editable: false),
            _buildProfileField(label: 'Telefone',controller: _telefoneController, keyboardType: TextInputType.phone, inputFormatters: [_phoneMask], // Aplica máscara
            ),
            
            const SizedBox(height: 30.0), 

            // 1. Botão Salvar/Editar
            ElevatedButton(
              onPressed: isLoading ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isEditing ? Colors.green : const Color(0xFF1E90FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
                : Text(
                    _isEditing ? 'Salvar Alterações' : 'Editar Perfil',
                    style: GoogleFonts.poppins(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
            ),

            const SizedBox(height: 30.0),
            const Divider(),
            const SizedBox(height: 10.0),

            // 2. Botão Seja Pro
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const Pro()));
              },
              icon: const Icon(Icons.star, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                padding: const EdgeInsets.symmetric(vertical: 14.0),
              ),
              label: Text('Seja Pro', style: GoogleFonts.poppins(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white)),
            ),

            const SizedBox(height: 30.0),


            // // 3. Meus Cofres
            // const SizedBox(height: 16.0),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(context, MaterialPageRoute(builder: (context) => const Home())); 
            //   },
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: const Color(0xFF1E90FF),
            //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            //     padding: const EdgeInsets.symmetric(vertical: 16.0),
            //   ),
            //   child: Text(
            //     'Meus Cofres',
            //     style: GoogleFonts.poppins(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
            //   ),
            // ),

            // Botão Sair
            OutlinedButton(
              onPressed: _handleLogout,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                padding: const EdgeInsets.symmetric(vertical: 14.0),
              ),
              child: Text('Sair da Conta', style: GoogleFonts.poppins(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.red)),
            ),
            const SizedBox(height: 50.0),
          ],
        ),
      ),
    );
  }



// --- View Deslogado ---
  Widget _buildLoggedOutView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 60, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              'Acesse sua conta.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const Login()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E90FF), padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30)),
              child: Text('Entrar', style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    // Escuta os dois stores
    final authStore = context.watch<AuthStore>();
    final perfilStore = context.watch<PerfilStore>(); // Para saber o loading do salvamento

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
                borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
              ),
              child: authStore.isLoggedIn
                  ? _buildLoggedInView(context, perfilStore.isloading)
                  : _buildLoggedOutView(context),
            ),
          ),
          const Footbarr(),
        ],
      ),
    );
  }
}
