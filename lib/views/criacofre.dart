import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelbox/views/modules/footbar.dart';
import 'package:travelbox/views/modules/header.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart'; 
import 'package:provider/provider.dart';
import 'home.dart'; 
import 'package:travelbox/controllers/cofreProvider.dart';
import 'package:travelbox/services/authProvider.dart';

class Criacofre extends StatefulWidget {
  const Criacofre({super.key});

  @override
  _CriacofreState createState() => _CriacofreState();
}

class _CriacofreState extends State<Criacofre> {
  // --- Controladores (Estado local da UI) ---
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _dataInicioController = TextEditingController();
  final TextEditingController _valorAlvoController = TextEditingController();
  
  // --- Formatadores ---
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final _currencyMask = MaskTextInputFormatter(
    mask: '#.###.###,00', 
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
  

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

  // --- Seletor de Data ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
      helpText: 'Selecione a Data de Início',
    );
    if (picked != null) {
      _dataInicioController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  // --- Lógica Principal: Dispara o evento (SÍNCRONA) ---
  void _handleCreateCofre() async {
    
    // 1. Pega os dados BRUTOS da UI
    final nome = _nomeController.text.trim();
    final dataInicioRaw = _dataInicioController.text.trim(); 
    final valorAlvoRaw = _valorAlvoController.text.trim(); 

    // 2. Validação básica de preenchimento (apenas Strings vazias)
    if (nome.isEmpty || dataInicioRaw.isEmpty || valorAlvoRaw.isEmpty) {
      _showSnackBar('Preencha todos os campos.', isError: true);
      return;
    }

    // 3. Validação e Limpeza do Valor Alvo
    final cleanValorAlvo = valorAlvoRaw
        .replaceAll('R\$', '')
        .replaceAll('.', '') // Remove ponto de milhar
        .replaceAll(',', '.') // Converte vírgula para ponto decimal
        .trim(); 

    final double? parsedValorAlvo = double.tryParse(cleanValorAlvo);

    if (parsedValorAlvo == null || parsedValorAlvo <= 0) {
      _showSnackBar('O Valor Alvo deve ser um número maior que R\$ 0,00.', isError: true);
      return;
    }

    // --- ACESSA PROVIDERS E VERIFICAÇÃO DE SEGURANÇA ---
    final cofreProvider = Provider.of<CofreProvider>(context, listen: false);
    final authStore = Provider.of<AuthStore>(context, listen: false);

    // 4. VERIFICAÇÃO DE USUÁRIO (Corrigido para usar a checagem completa de ID)
    if (authStore.usuario?.id?.isNotEmpty != true) {
        _showSnackBar('O perfil não foi carregado. Tente novamente.', isError: true);
        return;
    }
    
    final String userId = authStore.usuario!.id!; // Agora é seguro usar '!'
    final int valorPlanoInt = parsedValorAlvo.toInt(); 
    
    // 5. DISPARA A CRIAÇÃO NO PROVIDER
    bool sucesso = await cofreProvider.criarCofre(
        nome: nome, 
        valorPlanoRaw: valorAlvoRaw, 
        dataInicioRaw: dataInicioRaw, 
        userId: userId,
    );
    
    // 6. AVALIA O RESULTADO E NAVEGA
    if (sucesso && mounted) {
        _showSnackBar('Cofre criado com sucesso!', isError: false);
        // NAVEGAÇÃO FINAL PARA A HOME/LISTA DE VIAGENS
        Navigator.of(context).pop(
            MaterialPageRoute(builder: (context) => const Home()), 
        );
    } else {
        _showSnackBar(cofreProvider.errorMessage ?? 'Falha desconhecida ao criar cofre.', isError: true);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _dataInicioController.dispose();
    _valorAlvoController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    
    // Observa o estado de carregamento do CofreProvider
    final bool isLoading = context.watch<CofreProvider>().isLoading; 

    return Scaffold(
      backgroundColor: const Color(0xFF1E90FF), 
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Header(), // A chamada do widget
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
                child: SingleChildScrollView( // Para evitar overflow do teclado
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40.0),
                      Text(
                        'Crie sua meta de viagem',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      
                      // NOME DO COFRE
                      TextField(
                        controller: _nomeController, 
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText: 'Nome do Cofre (Ex: Tailândia 2026)',
                          prefixIcon: const Icon(Icons.flight_takeoff, color: Color(0xFF1E90FF)),
                          labelStyle: GoogleFonts.poppins(),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        style: GoogleFonts.poppins(
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // DATA DE INÍCIO (Seletor)
                      GestureDetector(
                        onTap: isLoading ? null : () => _selectDate(context), // Desabilita no loading
                        child: AbsorbPointer( // Impede a edição direta do campo
                          child: TextField(
                            controller: _dataInicioController, 
                            keyboardType: TextInputType.datetime,
                            decoration: InputDecoration(
                              labelText: _dataInicioController.text.isEmpty
                                  ? 'Data de Início da Viagem'
                                  : _dateFormat.format(DateTime.parse(_dataInicioController.text)), 
                              prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF1E90FF)),
                              suffixIcon: const Icon(Icons.arrow_drop_down),
                              labelStyle: GoogleFonts.poppins(),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // VALOR ALVO
                      TextField(
                        controller: _valorAlvoController, 
                        keyboardType: const TextInputType.numberWithOptions(decimal: true), 
                        decoration: InputDecoration(
                          labelText: 'Valor Alvo',
                          prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF1E90FF)),
                          prefixText: 'R\$ ', 
                          labelStyle: GoogleFonts.poppins(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: GoogleFonts.poppins(),
                      
                        // Aplicação da Máscara de Moeda
                        inputFormatters: [_currencyMask],    
                      ),
                      const SizedBox(height: 25.0),

                      // BOTÃO CONFIRMAR
                      ElevatedButton(
                        onPressed: isLoading ? null : _handleCreateCofre, // Dispara a função síncrona
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E90FF),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: isLoading 
                            ? const SizedBox( 
                                width: 24, height: 24, 
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                              )
                            : Text(
                                'Confirmar',
                                style: GoogleFonts.poppins(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      const SizedBox(height: 25.0), 
                    ],
                  ), 
                ),
              ), 
            ), 
          ), 
          Footbarr(), 
        ],
      ),
    );
  }
}