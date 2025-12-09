// Essenciais
import 'package:flutter/material.dart';
import 'package:travelbox/models/enums/categoriaDespesa.dart';
import 'package:travelbox/services/FirestoreService.dart';

//Models
import 'package:travelbox/models/cofre.dart';
import 'package:travelbox/models/contribuicao.dart';
import 'package:travelbox/models/permissao.dart';
import 'package:travelbox/models/usuario.dart';
import 'package:travelbox/models/despesa.dart';
import 'package:travelbox/models/enums/tipoDespesa.dart';


class DetalhesCofreStore extends ChangeNotifier {
  final FirestoreService _firestoreService;

  // --- VARIÁVEIS DE ESTADO ---
  Cofre? _cofreAtivo;
  bool _isLoading = false;
  String? _errorMessage;
  // REMOVIDO: String cite_start = "Fonte:";

  // Listas de dados
  List<Contribuicao> _contribuicoes = [];
  List<Permissao> _membros = [];
  List<Despesa> _despesas = [];

  // Mapa para acesso rápido aos dados do usuário (ex: foto, nome) pelo ID
  Map<String, Usuario> _contribuidoresMap = {};

  // --- GETTERS PÚBLICOS ---
  Cofre? get cofreAtivo => _cofreAtivo;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Contribuicao> get contribuicoes => _contribuicoes;
  List<Permissao> get membros => _membros;
  List<Despesa> get despesas => _despesas;
  Map<String, Usuario> get contribuidoresMap => _contribuidoresMap;

  

  // 🎯 NOVO: Lógica para mapeamento de nomes (adicionada)
  /// Retorna o nome de exibição de um usuário, substituindo pelo pronome "Você" se for o usuário logado.
  String getDisplayName(String userId, String? usuarioLogadoId) {
    if (userId == usuarioLogadoId) {
        return "Você";
    }
    return _contribuidoresMap[userId]?.nome ?? 'Usuário Desconhecido';
  }

  // filtros
  List<Usuario> get participantesDoCofre {
    // Pega os UIDs dos membros com permissão
    final List<String> memberIds = _membros.map((p) => p.idUsuario).toList();

    // Filtra o mapa de contribuidores para retornar apenas os objetos Usuario dos membros
    return memberIds
        .where((id) => _contribuidoresMap.containsKey(id))
        .map((id) => _contribuidoresMap[id]!)
        .toList();
  }

  List<Despesa> get despesasPlanejadas => _despesas.where((d) => d.tipo == TipoDespesa.planejada).toList();
  // CÁLCULOS MATEMÁTICOS

  double get totalArrecadado {
    return _contribuicoes.fold(0.0, (total, atual) => total + atual.valor);
  }

  double get totalPlanejado => despesasPlanejadas.fold(0.0, (sum, d) => sum + d.valor);

  double get sugestaoMensal {
    if (_cofreAtivo == null || _cofreAtivo!.dataViagem == null) return 0.0;
    
    // Meta: Usamos o Total Planejado como meta dinâmica, ou o valorPlano fixo?
    // Vamos usar o maior dos dois para garantir.
    double metaFinal = totalPlanejado > 0 ? totalPlanejado : _cofreAtivo!.valorPlano.toDouble();
    
    double faltaArrecadar = metaFinal - totalArrecadado;
    if (faltaArrecadar <= 0) return 0.0;

    // Calcula meses restantes
    final hoje = DateTime.now();
    final dataViagem = _cofreAtivo!.dataViagem!;
    
    // Diferença em dias convertida para meses aproximados
    int mesesRestantes = (dataViagem.difference(hoje).inDays / 30).ceil();
    if (mesesRestantes <= 0) mesesRestantes = 1; // Evita divisão por zero se for este mês

    // Divide pelo número de membros (para saber a parte de CADA UM)
    int numMembros = _membros.isEmpty ? 1 : _membros.length;
    
    return (faltaArrecadar / mesesRestantes) / numMembros;
  }

  // Cálculo do Total Gasto (Soma das Despesas Reais)
  double get totalGasto {
    return despesasReais.fold(0.0, (total, atual) => total + atual.valor);
  }

  // Cálculo do Saldo Disponível (Dinheiro na mão)
  // Arrecadado (Entradas) - Gasto (Saídas)
  double get saldoDisponivel {
    return totalArrecadado - totalGasto;
  }

  /// Retorna TRUE se a data planejada da viagem (_cofreAtivo.dataViagem) já passou.
  /// Quando TRUE, o cofre deve bloquear novas Despesas (RegistrarGasto) e Contribuições.
  bool get isCofreFinalizado {
    return _cofreAtivo?.isFinalizado ?? false;
  }


  DetalhesCofreStore(this._firestoreService);

  // ----------------------------------------------------
  // CARREGAR DADOS
  // ----------------------------------------------------
  Future<void> carregarDadosCofre(String cofreId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Buscas concorrentes (Cofre, Contribuições, Permissões)
      final results = await Future.wait([
        _firestoreService.getCofreById(cofreId),
        _firestoreService.getContribuicoesDoCofre(cofreId),
        _firestoreService.getMembrosCofre(cofreId),
        _firestoreService.getDespesasDoCofre(cofreId),
      ]);

      _cofreAtivo = results[0] as Cofre?;
      _contribuicoes = results[1] as List<Contribuicao>;
      _membros = results[2] as List<Permissao>;
      _despesas = results[3] as List<Despesa>;

      if (_cofreAtivo == null) {
        throw Exception("Cofre não encontrado ou acesso negado.");
      }

      // 2. Extrai os UIDs únicos das contribuições E dos membros
      // Assim garantimos que temos os dados de todo mundo
      final Set<String> todosIds = {};
      todosIds.addAll(_contribuicoes.map((c) => c.idUsuario));
      todosIds.addAll(_membros.map((m) => m.idUsuario));

      if (todosIds.isNotEmpty) {
        // 3. Busca os perfis de usuário em massa
        final List<Usuario> perfis = await _firestoreService.getUsuariosByIds(
          todosIds.toList(),
        );

        // 4. Cria o mapa
        _contribuidoresMap = {for (var user in perfis) user.id!: user};
      }
    } catch (e) {
      _errorMessage = "Erro ao carregar detalhes: ${e.toString()}";
      _cofreAtivo = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // AÇÃO: Alterar a Meta
  Future<bool> alterarMeta(int novaMeta) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_cofreAtivo == null) throw Exception("Cofre não carregado");

      await _firestoreService.atualizarMetaCofre(_cofreAtivo!.id!, novaMeta);
      
      // Atualiza o objeto local usando copyWith
      _cofreAtivo = _cofreAtivo!.copyWith(valorPlano: novaMeta);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }


  



//===============================================================================
//                          CONTRIBUIÇÃO
//===============================================================================

  Future<bool> adicionarContribuicao({
    required String cofreId,
    required String usuarioId,
    required double valor,
    required DateTime data,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Contribuicao nova = Contribuicao(
        id: null, // Firebase gera
        idCofre: cofreId,
        idUsuario: usuarioId,
        valor: valor,
        data: data,
      );

      // 1. Salva a contribuição no Banco
      await _firestoreService.addContribuicao(nova);

      // NOTA: Não precisamos chamar atualizarSaldoCofre,
      // pois o getter 'totalArrecadado' soma tudo automaticamente.

      // 2. OTIMIZAÇÃO: Atualiza a lista localmente
      // Inserimos no topo da lista para aparecer na hora, sem gastar internet recarregando tudo
      _contribuicoes.insert(0, nova);

      // Se o usuário ainda não estava no mapa (primeira contribuição), buscamos ele
      if (!_contribuidoresMap.containsKey(usuarioId)) {
        final user = await _firestoreService.getUsuario(usuarioId);
        if (user != null) {
          _contribuidoresMap[usuarioId] = user;
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }


//===============================================================================
//                        Despesas
//===============================================================================

  Future<bool> adicionarDespesaPlanejada({
    required String titulo,
    required double valor,
    required CategoriaDespesa categoria,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_cofreAtivo == null) throw Exception("Cofre não carregado");

      Despesa nova = Despesa(
        idCofre: _cofreAtivo!.id!,
        titulo: titulo,
        valor: valor,
        tipo: TipoDespesa.planejada,
        categoria: categoria,
      );

      await _firestoreService.addDespesa(nova);
      _despesas.add(nova); // Atualiza local

      // Opcional: Atualizar a meta do cofre (valorPlano) automaticamente?
      // Se quiser, podemos chamar _firestoreService.atualizarMetaCofre(...) aqui.

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // AÇÃO: Editar Despesa
  Future<bool> editarDespesa(Despesa despesaEditada) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Chama o serviço
      await _firestoreService.updateDespesa(despesaEditada);

      // Atualiza na lista local (Troca a velha pela nova)
      final index = _despesas.indexWhere((d) => d.id == despesaEditada.id);
      if (index != -1) {
        _despesas[index] = despesaEditada;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Erro ao editar: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // AÇÃO: Remover Despesa
  Future<bool> removerDespesa(String despesaId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Chama o serviço
      await _firestoreService.deleteDespesa(despesaId);

      // Remove da lista local
      _despesas.removeWhere((d) => d.id == despesaId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Erro ao remover: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // GETTER: Filtra apenas despesas reais (executadas)
  List<Despesa> get despesasReais => _despesas.where((d) => d.tipo == TipoDespesa.real).toList();

  // CÁLCULO DE BALANÇO (Quem deve quem)
  // Retorna um Mapa: { ID_USUARIO : SALDO }
  // Saldo Positivo = Tem a receber.
  // Saldo Negativo = Tem a pagar.
  // ⚠️ NOTA: ESTE GETTER É REDUNDANTE E INCOMPLETO, O CÁLCULO CORRETO ESTÁ NO DESPESAPROVIDER.
  Map<String, double> get mapaDeSaldos {
    Map<String, double> saldos = {};

    // Inicializa zerado
    for (var membro in _membros) {
      saldos[membro.idUsuario] = 0.0;
    }

    // A. Processa GASTOS REAIS (Gera dívida)
    for (var despesa in despesasReais) {
      if (despesa.pagoPorId == null) continue;

      double valorTotal = despesa.valor;
      
      // Quem pagou ganha crédito (+)
      saldos[despesa.pagoPorId!] = (saldos[despesa.pagoPorId!] ?? 0) + valorTotal;

      // O custo é dividido entre todos (débito -)
      int numMembros = _membros.length;
      if (numMembros > 0) {
        double parteDeCada = valorTotal / numMembros;
        for (var membro in _membros) {
          saldos[membro.idUsuario] = (saldos[membro.idUsuario] ?? 0) - parteDeCada;
        }
      }
    }

    final acertos = _despesas.where((d) => d.tipo == TipoDespesa.acerto).toList();
    
    for (var acerto in acertos) {
       if (acerto.pagoPorId == null) continue;
       
       // Quem pagou o acerto está "quitando" sua parte, então ganha crédito no saldo pessoal
       saldos[acerto.pagoPorId!] = (saldos[acerto.pagoPorId!] ?? 0) + acerto.valor;
       
       // Nota: Não subtraímos de ninguém, pois o dinheiro "entrou" para cobrir o buraco.
    }


    return saldos;
  }
  
//--------------------------------------- despesa real ----------------------------------

  // AÇÃO: Adicionar Gasto Real
  Future<bool> adicionarDespesaReal({
    required String titulo,
    required double valor,
    required CategoriaDespesa categoria,
    required String pagoPorId, // Quem passou o cartão?
    required DateTime data,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_cofreAtivo == null) throw Exception("Cofre não carregado");

      Despesa nova = Despesa(
        idCofre: _cofreAtivo!.id!,
        titulo: titulo,
        valor: valor,
        tipo: TipoDespesa.real, // IMPORTANTE: Tipo Real
        categoria: categoria,
        pagoPorId: pagoPorId,   // Salvamos quem pagou
        data: data,
      );

      await _firestoreService.addDespesa(nova);
      _despesas.add(nova); // Atualiza local

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 3. AÇÃO: FINALIZAR VIAGEM (Apenas Coordenador)
  Future<bool> encerrarViagem() async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_cofreAtivo == null) throw Exception("Cofre inválido");
      
      // Chama o serviço para atualizar no banco
      await _firestoreService.finalizarCofre(_cofreAtivo!.id!);
      
      // Atualiza o estado local imediatamente
      _cofreAtivo = _cofreAtivo!.copyWith(isFinalizado: true);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 4. AÇÃO: QUITAR DÍVIDA (Registrar Acerto)
  Future<bool> quitarDivida(String usuarioDevedorId, double valor) async {
    _isLoading = true;
    notifyListeners();
    try {
       // Cria uma despesa especial do tipo ACERTO
       Despesa acerto = Despesa(
         idCofre: _cofreAtivo!.id!,
         titulo: "Pagamento de Dívida",
         valor: valor,
         tipo: TipoDespesa.acerto, // <--- O Pulo do Gato
         categoria: CategoriaDespesa.outros,
         pagoPorId: usuarioDevedorId,
         data: DateTime.now(),
       );

       await _firestoreService.addDespesa(acerto);
       _despesas.add(acerto);

       _isLoading = false;
       notifyListeners();
       return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }



//===============================================================================
//                            Membros do cofre
//===============================================================================

  Future<bool> expulsarMembro(String idUsuarioAlvo, String idCofre) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Chama o serviço para deletar a permissão do banco
      await _firestoreService.removePermissao(idUsuarioAlvo, idCofre);
      
      // Remove localmente da lista para atualizar a tela na hora
      _membros.removeWhere((m) => m.idUsuario == idUsuarioAlvo);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Erro ao expulsar: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // AÇÃO: Sair do Cofre (Apenas Contribuinte)
  Future<bool> sairDoCofre(String meuId, String idCofre) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestoreService.removePermissao(meuId, idCofre);
      
      // Não precisamos atualizar a lista local, pois vamos fechar a tela
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Erro ao sair: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void limparDados() {
    _cofreAtivo = null;
    _contribuicoes = [];
    _membros = [];
    _contribuidoresMap = {};
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}