import 'package:flutter/material.dart';
import 'package:travelbox/models/cofre.dart';
import 'package:travelbox/models/permissao.dart';
import 'package:travelbox/models/nivelPermissao.dart';
import 'package:travelbox/services/FirestoreService.dart';


class CofreStore extends ChangeNotifier {
  // 2. DEPENDÊNCIA DO SERVICE (A "COZINHA")
  // Ele "conhece" o service, mas a UI não.
  final FirestoreService _firestoreService;

  List<Cofre> _cofres = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Cofre> get cofres => _cofres;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  CofreStore(this._firestoreService);

  Future<void> carregarCofres(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Notifica a Home que o carregamento começou

    try {
      _cofres = await _firestoreService.getCofresDoUsuario(userId);
    } catch (e) {
      _errorMessage = 'Falha ao carregar cofres: ${e.toString()}';
      print('ERRO NO PROVIDER: $_errorMessage'); // Log para debug
    } finally {
      _isLoading = false;
      notifyListeners(); // Notifica a Home que o carregamento terminou
    }
  }

  // ATUALIZAÇÃO: salvarCofre agora precisa saber QUEM está criando

  Future<bool> criarCofre({
    required String nome, 
    required String valorPlanoRaw,  // CORREÇÃO: Aceita a String bruta do valor
    required String dataInicioRaw,  // CORREÇÃO: Aceita a String bruta da data
    required String userId,
}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
        
        if (nome.trim().isEmpty || dataInicioRaw.isEmpty || valorPlanoRaw.isEmpty) {
             throw Exception("Por favor, preencha todos os campos.");
        }
  
        final cleanValorAlvo = valorPlanoRaw
            .replaceAll('R\$', '')
            .replaceAll('.', '') // Remove ponto de milhar
            .replaceAll(',', '.') // Converte vírgula para ponto decimal
            .trim(); 

        final double? parsedValorAlvo = double.tryParse(cleanValorAlvo);

        if (parsedValorAlvo == null || parsedValorAlvo <= 0) {
             throw Exception("O Valor Alvo deve ser um número maior que R\$ 0,00.");
        }
        
        // 2. Conversão da Data
        // ATENÇÃO: O DateTime.parse espera formato "YYYY-MM-DD".
        // Se sua UI manda "DD/MM/YYYY", precisaremos ajustar aqui depois.
        final DateTime parsedDataInicio = DateTime.parse(dataInicioRaw); 
        final int valorAlvoInt = parsedValorAlvo.round();
        
        
        
        // CORREÇÃO: O Cofre.novo deve aceitar o DOUBLE e o DateTime
        Cofre novoCofre = Cofre.novo(
          nome: nome.trim(), // String limpa
          valorPlano: valorAlvoInt, // O valor convertido
          dataViagem: parsedDataInicio, // A data convertida
        );
      

        Cofre cofreSalvo = await _firestoreService.criarCofre(novoCofre, userId);

        _cofres.add(cofreSalvo); // Adiciona o novo cofre à lista local

        _isLoading = false;
        notifyListeners();
        return true;
        
    } catch (e) {
        _isLoading = false;
        _errorMessage = e.toString().contains("Exception:") 
                        ? e.toString().split(":").last.trim() 
                        : "Erro interno: ${e.toString()}";
        notifyListeners();
        return false;
    }
  }

// --- ENTRAR COM CÓDIGO ---
  Future<String?> entrarComCodigo(String codigo, String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Acha o cofre pelo código (Normalizado uppercase)
      final cofre = await _firestoreService.findCofreByCode(
        codigo.toUpperCase().trim(),
      );

      if (cofre == null) {
        _isLoading = false;
        notifyListeners();
        return "Código inválido. Verifique e tente novamente.";
      }

      // 2. Verifica duplicidade
      bool jaParticipa = _cofres.any((c) => c.id == cofre.id);
      if (jaParticipa) {
        _isLoading = false;
        notifyListeners();
        return "Você já participa deste cofre!";
      }

      // 3. Cria a permissão de CONTRIBUINTE
      Permissao novaPermissao = Permissao(
        idUsuario: userId,
        idCofre: cofre.id!,
        nivelPermissao: NivelPermissao.contribuinte, 
      );

      await _firestoreService.criarPermissao(novaPermissao);

      // 4. Adiciona à lista local se não existir
      if (!_cofres.any((c) => c.id == cofre.id)) {
        _cofres.add(cofre);
      }

      _isLoading = false;
      notifyListeners();
      return null; // Sucesso (null = sem erro)
      
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return "Erro ao tentar entrar no cofre: ${e.toString()}";
    }
  }

  void limparDados() {
    _cofres = [];
    notifyListeners();
  }
}