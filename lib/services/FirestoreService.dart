// ignore_for_file: unnecessary_cast

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelbox/models/cofre.dart';
import 'package:travelbox/models/contribuicao.dart';
import 'package:travelbox/models/nivelPermissao.dart';
import 'package:travelbox/models/permissao.dart';
import 'package:travelbox/models/Usuario.dart';
import 'package:travelbox/models/convite.dart';
import 'package:travelbox/models/statusConvite.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ========================== MÉTODOS DE USUÁRIO ========================================

  /// Cria o documento de um usuário na coleção 'users'.
  Future<void> criarUsuario(Usuario usuario) async {
    await _db.collection('users').doc(usuario.id).set(usuario.toJson());
  }

  /// Busca um usuário pelo seu ID (uid).
  Future<Usuario?> getUsuario(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return Usuario.fromFirestore(doc);
    }
    return null;
  }

  /// Atualiza dados do usuário (Nome, Telefone, etc)
  Future<void> atualizarDadosUsuario(Usuario usuario) async {
    // .update() só muda os campos enviados, não sobrescreve o doc todo
    await _db.collection('users').doc(usuario.id).update({
      'nome': usuario.nome,
      'telefone': usuario.telefone,
      'cpf': usuario.cpf, 
    });
  }

  

  // ========================== MÉTODOS DE COFRE ========================================

  /// Cria um novo cofre E JÁ ADICIONA O CRIADOR COMO ADMIN
  Future<Cofre> criarCofre(Cofre cofre, String creatorUserId) async {
    final docRef = _db.collection('cofres').doc();

    // Usa o copyWith para adicionar o ID gerado
    Cofre cofreComId = cofre.copyWith(id: docRef.id);
    await docRef.set(cofreComId.toJson());

    // !! IMPORTANTE: Adiciona o criador como Admin
    Permissao adminPerm = Permissao(
      id: null, // O Firestore vai gerar o ID
      idUsuario: creatorUserId,
      idCofre: cofreComId.id!,
      nivelPermissao: NivelPermissao.coordenador,
    );
    // Chama o método para criar a permissão
    await criarPermissao(adminPerm);

    return cofreComId;
  }

  /// MÉTODO CORRIGIDO: Encontra um cofre pelo seu código de entrada
  Future<Cofre?> findCofreByCode(String code) async {
    // Busca na coleção 'cofres' onde o 'joinCode' é igual ao código
    final snapshot = await _db
        .collection('cofres')
        .where('joinCode', isEqualTo: code)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null; // Nenhum cofre encontrado
    }

    // 🎯 CORREÇÃO: Fazemos o casting explícito para DocumentSnapshot<Map<String, dynamic>>
    // para garantir que o tipo de entrada corresponda ao construtor fromFirestore.
    final doc = snapshot.docs.first as DocumentSnapshot<Map<String, dynamic>>;

    // Retorna o primeiro cofre encontrado
    return Cofre.fromFirestore(doc);
  }

  /// MÉTODO NOVO (ou atualizado): Adiciona uma permissão
  /// (Usado tanto pelo criador quanto por quem entra)
  Future<void> criarPermissao(Permissao permissao) async {
    // Primeiro, verifica se a permissão já existe
    final existing = await _db
        .collection('permissoes')
        .where('idUsuario', isEqualTo: permissao.idUsuario)
        .where('idCofre', isEqualTo: permissao.idCofre)
        .limit(1)
        .get();

    // Se não existir, cria a nova permissão
    if (existing.docs.isEmpty) {
      await _db.collection('permissoes').add(permissao.toJson());
    }
    // Se já existir, não faz nada (usuário já está no cofre)
  }

  /// Busca todos os cofres aos quais um usuário tem permissão.
  Future<List<Cofre>> getCofresDoUsuario(String userId) async {
    try {
      // 1. Busca todas as permissões desse usuário (igual a antes)
      final permissoesSnap = await _db
          .collection('permissoes')
          .where('idUsuario', isEqualTo: userId)
          .get();

      // 2. Extrai os IDs dos cofres (igual a antes)
      final cofreIds = permissoesSnap.docs
          .map((doc) => (doc.data())['idCofre'] as String)
          .toSet()
          .toList();

      if (cofreIds.isEmpty) {
        return []; // Usuário não tem permissão em nenhum cofre
      }

      // ----- NOVA LÓGICA DE FATIAMENTO (CHUNKING) -----

      // 3. Prepara a lista final onde todos os resultados serão combinados
      final List<Cofre> todosOsCofres = [];

      // 4. Define o tamanho do "fatiador"
      const int chunkSize = 10;

      // 5. Loop que avança de 10 em 10 (i = 0, i = 10, i = 20, ...)
      for (int i = 0; i < cofreIds.length; i += chunkSize) {
        // 6. Calcula o índice final do pedaço (chunk)
        // Cuidado para não ultrapassar o final da lista
        int end = (i + chunkSize > cofreIds.length)
            ? cofreIds.length
            : i + chunkSize;

        // 7. Pega a sub-lista (o "pedaço" de no máximo 10 IDs)
        final List<String> chunk = cofreIds.sublist(i, end);

        // 8. Executa a consulta APENAS para esse pedaço
        final cofresSnap = await _db
            .collection('cofres')
            .where(
              FieldPath.documentId,
              whereIn: chunk,
            ) // 'chunk' tem no máx. 10 itens
            .get();

        // 9. Converte os documentos e adiciona na lista final
        todosOsCofres.addAll(
          cofresSnap.docs.map((doc) => Cofre.fromFirestore(doc)).toList(),
        );
      }

      // 10. Retorna a lista combinada de todas as consultas
      return todosOsCofres;
    } catch (e) {
      print("Erro ao buscar cofres: $e");
      return [];
    }
  }

  //========================= Cofre Finalizado ======================================

  // ----- MÉTODOS DE CONTRIBUIÇÃO -----

  /// Adiciona uma nova contribuição a um cofre.
  Future<void> addContribuicao(Contribuicao contribuicao) async {
    await _db.collection('contribuicoes').add(contribuicao.toJson());
  }

  /// Busca todas as contribuições de um cofre específico.
  Future<List<Contribuicao>> getContribuicoesDoCofre(String cofreId) async {
    final snapshot = await _db
        .collection('contribuicoes')
        .where('idCofre', isEqualTo: cofreId)
        .orderBy('data', descending: true)
        .get();

    return snapshot.docs
        .map(
          (doc) => Contribuicao.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>,
          ),
        )
        .toList();
  }
  Future<void> atualizarSaldoCofre(String cofreId, double valorContribuido) async {
    await _db.collection('cofres').doc(cofreId).update({
    // 🎯 CRÍTICO: FieldValue.increment() garante que a soma ocorra no servidor
    // sem risco de sobreposição de dados.
      'despesasTotal': FieldValue.increment(valorContribuido), 
  });
  }

  // ----- MÉTODOS DE PERMISSÃO -----

  /// Adiciona uma permissão para um usuário em um cofre.
  Future<void> addPermissao(Permissao permissao) async {
    await _db.collection('permissoes').add(permissao.toJson());
  }

  /// Remove a permissão de um usuário para um cofre específico.
  Future<void> removePermissao(String idUsuario, String idCofre) async {
    final snapshot = await _db
        .collection('permissoes')
        .where('idUsuario', isEqualTo: idUsuario)
        .where('idCofre', isEqualTo: idCofre)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.delete();
    }
  }

  /// Busca todas as permissões de um cofre específico.
  Future<List<Permissao>> getPermissoesDoCofre(String cofreId) async {
    final snapshot = await _db
        .collection('permissoes')
        .where('idCofre', isEqualTo: cofreId)
        .get();

    return snapshot.docs
        .map(
          (doc) => Permissao.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>,
          ),
        )
        .toList();
  }

  //====================== Membros e Convites ====================================

  // --- NOVOS MÉTODOS PARA MEMBROS E CONVITES ---

  /// Busca todos os membros (usuários) de um cofre específico
  Future<List<Permissao>> getMembrosCofre(String cofreId) async {
    final snapshot = await _db
        .collection('permissoes')
        .where('idCofre', isEqualTo: cofreId)
        .get();
    return snapshot.docs.map((doc) => Permissao.fromFirestore(doc)).toList();
  }

  /// Busca um usuário pelo E-mail (usado para enviar convites)
  Future<Usuario?> buscarUsuarioPorEmail(String email) async {
    final snapshot = await _db
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return Usuario.fromFirestore(snapshot.docs.first);
    }
    return null;
  }

  /// Envia (cria) um convite no banco
  Future<void> criarConvite(Convite convite) async {
    await _db.collection('convites').add(convite.toJson());
  }

  /// Busca convites que o usuário recebeu e ainda estão pendentes
  Future<List<Convite>> getConvitesRecebidos(String userId) async {
    final snapshot = await _db
        .collection('convites')
        .where('idUsuarioConvidado', isEqualTo: userId)
        .where('status', isEqualTo: 'pendente') // Filtra só os pendentes
        .get();
    return snapshot.docs.map((doc) => Convite.fromFirestore(doc)).toList();
  }

  /// Atualiza o status de um convite (Aceitar/Recusar)
  Future<void> responderConvite(
    String conviteId,
    StatusConvite novoStatus,
  ) async {
    await _db.collection('convites').doc(conviteId).update({
      'status': novoStatus.name,
    });
  }

  Future<Cofre?> getCofreById(String cofreId) async {
    try {
      // 1. Busca o documento (doc é DocumentSnapshot<Object?> por padrão)
      final doc = await _db.collection('cofres').doc(cofreId).get();
      
      if (doc.exists) {
        // 2. Faz o casting explícito e seguro, necessário para o construtor do Model
        final typedDoc = doc as DocumentSnapshot<Map<String, dynamic>>;
        
        // 3. Passa o documento tipado para o construtor de fábrica
        return Cofre.fromFirestore(typedDoc);
      }
      return null;
    } catch (e) {
      print("Erro ao buscar cofre por ID ($cofreId): $e");
      return null;
    }
  }

//====================== Membros e Convites implementado ===================

}