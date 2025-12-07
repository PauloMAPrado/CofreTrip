// Imports essenciais
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


//Imports das Views
import 'package:travelbox/views/modules/footbar.dart';
import 'package:travelbox/views/modules/header.dart';

// Imports dos Stores
import 'package:travelbox/stores/cofreStore.dart';
import 'package:travelbox/stores/authStore.dart';

// Import do utils
import 'package:travelbox/utils/feedbackHelper.dart';
import 'package:travelbox/utils/currency_input_formatter.dart';



class Criacofre extends StatefulWidget {
  const Criacofre({super.key});

  @override
  _CriacofreState createState() => _CriacofreState();
}

class _CriacofreState extends State<Criacofre> {
  // --- Controladores (Estado local da UI) ---
  final _nomeController = TextEditingController();
  final _dataInicioController = TextEditingController();
  final _valorAlvoController = TextEditingController(text: "R\$ 0,00");
  
  // --- Formatadores ---
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

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
      _dataInicioController.text = _dateFormat.format(picked);
    }
  }

/*         se tiver dando Erro tira esse codigo do comentario
  @override
  void dispose() {
    _nomeController.dispose();
    _dataInicioController.dispose();
    _valorAlvoController.dispose();
    super.dispose();
  }
*/

@override
  Widget build(BuildContext context) {
    // 1. OUVINDO O STORE (Para Loading)
    final cofreStore = context.watch<CofreStore>();
    final isLoading = cofreStore.isLoading;

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
                child: SingleChildScrollView(
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

                      // NOME
                      TextField(
                        controller: _nomeController,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          labelText: 'Nome do Cofre (Ex: Tailândia 2026)',
                          prefixIcon: const Icon(Icons.flight_takeoff, color: Color(0xFF1E90FF)),
                          labelStyle: GoogleFonts.poppins(),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        style: GoogleFonts.poppins(),
                      ),
                      const SizedBox(height: 20.0),

                      // DATA
                      GestureDetector(
                        onTap: isLoading ? null : () => _selectDate(context),
                        child: AbsorbPointer(
                          child: TextField(
                            controller: _dataInicioController,
                            decoration: InputDecoration(
                              labelText: 'Data de Início da Viagem',
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

                      // VALOR
                      TextField(
                        controller: _valorAlvoController,
                        // Mudei para number (sem decimal) porque tratamos como inteiros internamente
                        keyboardType: TextInputType.number, 
                        enabled: !isLoading,
                        
                        // USA O NOVO FORMATADOR MÁGICO
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly, // Aceita só números
                          CurrencyInputFormatter(), // Formata como banco
                        ],
                        
                        decoration: InputDecoration(
                          labelText: 'Valor Alvo',
                          // Removemos o prefixText: 'R$ ' porque o formatador já coloca o R$ dentro do texto
                          prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF1E90FF)),
                          labelStyle: GoogleFonts.poppins(),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        style: GoogleFonts.poppins(),
                      ),
                      const SizedBox(height: 25.0),

                      // BOTÃO CONFIRMAR
                      ElevatedButton(
                        onPressed: isLoading ? null : () async {
                          // Ação do Botão
                          FocusScope.of(context).unfocus();

                          // 1. Validação simples de vazio
                          if (_nomeController.text.isEmpty || 
                              _dataInicioController.text.isEmpty || 
                              _valorAlvoController.text.isEmpty) {
                            FeedbackHelper.mostrarErro(context, "Preencha todos os campos.");
                            return;
                          }

                          // 2. Pegar usuário e Store
                          final authStore = context.read<AuthStore>();
                          final cofreStore = context.read<CofreStore>();
                          
                          if (authStore.usuario?.id == null) {
                             FeedbackHelper.mostrarErro(context, "Erro de sessão. Faça login novamente.");
                             return;
                          }

                          // 3. Chamar o Store (Passando strings brutas, ele que se vire!)
                          bool sucesso = await cofreStore.criarCofre(
                            nome: _nomeController.text,
                            valorPlanoRaw: _valorAlvoController.text, // "10.000,00"
                            dataInicioRaw: _dataInicioController.text, // "2025-01-01"
                            userId: authStore.usuario!.id!,
                          );

                          if (!mounted) return;

                          if (sucesso) {
                            FeedbackHelper.mostrarSucesso(context, "Cofre criado com sucesso!");
                            Navigator.pop(context); // Volta para a Home
                          } else {
                            FeedbackHelper.mostrarErro(context, cofreStore.errorMessage);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E90FF),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        ),
                        child: isLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                            : Text('Confirmar', style: GoogleFonts.poppins(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                      const SizedBox(height: 25.0),
                    ],
                  ),
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