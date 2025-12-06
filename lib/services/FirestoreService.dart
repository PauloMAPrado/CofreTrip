// ignore_for_file: unnecessary_cast

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelbox/models/cofre.dart';
import 'package:travelbox/models/contribuicao.dart';
import 'package:travelbox/models/nivelPermissao.dart';
import 'package:travelbox/models/permissao.dart';
import 'package:travelbox/models/usuario.dart';
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
      // Casting seguro
      return Usuario.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
    }
    return null;
  }

  /// Busca perfis de Usuario para uma lista de UIDs (Chunking implementado)
  /// Útil para carregar a lista de membros com nomes e fotos
  Future<List<Usuario>> getUsuariosByIds(List<String> uids) async {
    if (uids.isEmpty) return [];

    final List<Usuario> todosOsUsuarios = [];
    const int chunkSize = 10; 

    for (int i = 0; i < uids.length; i += chunkSize) {
        final List<String> chunk = uids.sublist(
            i, 
            (i + chunkSize > uids.length) ? uids.length : i + chunkSize
        );

        final snapshot = await _db
            .collection('users')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        
        todosOsUsuarios.addAll(
            snapshot.docs.map((doc) => Usuario.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)).toList(),
        );
    }
    return todosOsUsuarios;
  }

  /// Atualiza dados do usuário (Nome, Telefone, etc)
  Future<void> atualizarDadosUsuario(Usuario usuario) async {
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

    Cofre cofreComId = cofre.copyWith(id: docRef.id);
    await docRef.set(cofreComId.toJson());

    // CORREÇÃO: Usando NivelPermissao.admin (Padrão do projeto)
    Permissao adminPerm = Permissao(
      idUsuario: creatorUserId,
      idCofre: cofreComId.id!,
      nivelPermissao: NivelPermissao.coordenador, 
    );
    
    await criarPermissao(adminPerm);
    return cofreComId;
  }

  /// Encontra um cofre pelo seu código de entrada
  Future<Cofre?> findCofreByCode(String code) async {
    final snapshot = await _db
        .collection('cofres')
        .where('joinCode', isEqualTo: code)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first as DocumentSnapshot<Map<String, dynamic>>;
    return Cofre.fromFirestore(doc);
  }

  /// Busca um cofre pelo ID
  Future<Cofre?> getCofreById(String cofreId) async {
    try {
      final doc = await _db.collection('cofres').doc(cofreId).get();
      if (doc.exists) {
        return Cofre.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
      }
      return null;
    } catch (e) {
      print("Erro ao buscar cofre por ID ($cofreId): $e");
      return null;
    }
  }

  /// Busca todos os cofres aos quais um usuário tem permissão.
  Future<List<Cofre>> getCofresDoUsuario(String userId) async {
    try {
      // 1. Busca permissões
      final permissoesSnap = await _db
          .collection('permissoes')
          .where('idUsuario', isEqualTo: userId)
          .get();

      // 2. Extrai IDs (com casting seguro para Map)
      final cofreIds = permissoesSnap.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['idCofre'] as String)
          .toSet()
          .toList();

      if (cofreIds.isEmpty) return [];

      // 3. Chunking para buscar os cofres
      final List<Cofre> todosOsCofres = [];
      const int chunkSize = 10;

      for (int i = 0; i < cofreIds.length; i += chunkSize) {
        int end = (i + chunkSize > cofreIds.length) ? cofreIds.length : i + chunkSize;
        final List<String> chunk = cofreIds.sublist(i, end);

        final cofresSnap = await _db
            .collection('cofres')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        todosOsCofres.addAll(
          cofresSnap.docs.map((doc) => Cofre.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)).toList(),
        );
      }

      return todosOsCofres;
    } catch (e) {
      print("Erro ao buscar cofres: $e");
      return [];
    }
  }

  // ========================== MÉTODOS DE CONTRIBUIÇÃO ========================================

  Future<void> addContribuicao(Contribuicao contribuicao) async {
    await _db.collection('contribuicoes').add(contribuicao.toJson());


    // 2. Incrementa o campo 'totalArrecadado' no Cofre
    await _db.collection('cofres').doc(contribuicao.idCofre).update({
      'totalArrecadado': FieldValue.increment(contribuicao.valor),
    });
  }

  Future<List<Contribuicao>> getContribuicoesDoCofre(String cofreId) async {
    final snapshot = await _db
        .collection('contribuicoes')
        .where('idCofre', isEqualTo: cofreId)
        .orderBy('data', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Contribuicao.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList();
  }

  // ========================== MÉTODOS DE PERMISSÃO ========================================

  Future<void> criarPermissao(Permissao permissao) async {
    final existing = await _db
        .collection('permissoes')
        .where('idUsuario', isEqualTo: permissao.idUsuario)
        .where('idCofre', isEqualTo: permissao.idCofre)
        .limit(1)
        .get();

    if (existing.docs.isEmpty) {
      await _db.collection('permissoes').add(permissao.toJson());
    }
  }

  Future<List<Permissao>> getMembrosCofre(String cofreId) async {
    final snapshot = await _db
        .collection('permissoes')
        .where('idCofre', isEqualTo: cofreId)
        .get();
    return snapshot.docs.map((doc) => Permissao.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)).toList();
  }
  
  // ========================== MÉTODOS DE CONVITES ========================================

  Future<Usuario?> buscarUsuarioPorEmail(String email) async {
    final snapshot = await _db
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return Usuario.fromFirestore(snapshot.docs.first as DocumentSnapshot<Map<String, dynamic>>);
    }
    return null;
  }

  Future<void> criarConvite(Convite convite) async {
    await _db.collection('convites').add(convite.toJson());
  }

  Future<List<Convite>> getConvitesRecebidos(String userId) async {
    final snapshot = await _db
        .collection('convites')
        .where('idUsuarioConvidado', isEqualTo: userId)
        .where('status', isEqualTo: 'pendente')
        .get();
    return snapshot.docs.map((doc) => Convite.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)).toList();
  }

  Future<void> responderConvite(String conviteId, StatusConvite novoStatus) async {
    await _db.collection('convites').doc(conviteId).update({
      'status': novoStatus.name,
    }
    );
//====================== Membros e Convites implementado ===================
  }
}