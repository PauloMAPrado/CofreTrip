// ignore_for_file: unnecessary_cast

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelbox/models/cofre.dart';
import 'package:travelbox/models/contribuicao.dart';
import 'package:travelbox/models/enums/nivelPermissao.dart';
import 'package:travelbox/models/permissao.dart';
import 'package:travelbox/models/usuario.dart';
import 'package:travelbox/models/convite.dart';
import 'package:travelbox/models/despesa.dart';
import 'package:travelbox/models/enums/statusConvite.dart';
//import 'package:travelbox/models/acerto.dart';

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

  /// Busca usuários cujo nome começa com o termo digitado.
  /// Retorna uma lista de sugestões.
  Future<List<Usuario>> pesquisarUsuariosPorNome(String termo) async {
    if (termo.isEmpty) return [];

    // O truque do Firestore para "começa com":
    // Busca de 'João' até 'João' + caractere final unicode (\uf8ff)
    final snapshot = await _db
        .collection('users')
        .orderBy('nome') // Precisa ordenar por nome para funcionar
        .startAt([termo])
        .endAt([termo + '\uf8ff'])
        .limit(10) // Limita a 10 resultados para não pesar
        .get();

    return snapshot.docs
        .map((doc) => Usuario.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList();
  }



  /// Deleta o documento do perfil do usuário
  Future<void> deleteUserData(String uid) async {
    await _db.collection('users').doc(uid).delete();
    // Nota: Por enquanto mantemos os cofres/contribuições para não quebrar 
    // os grupos dos amigos, mas o perfil pessoal some.
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
          .where('id_usuario', isEqualTo: userId)
          .get();
//espião
//      print("✅ Permissões encontradas: ${permissoesSnap.docs.length}");
//espião
      // 2. Extrai IDs (com casting seguro para Map)
      final cofreIds = permissoesSnap.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['id_cofre'] as String)
          .toSet()
          .toList();
//espião (teste improvisado apara achar inconsistencia)
//      print("🆔 IDs de cofres encontrados: $cofreIds");
//espião
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


/* espião (teste improvisado apara achar inconsistencia)
        print("📦 Documentos baixados no chunk $i: ${cofresSnap.docs.length}");
// espião 
*/
        // Tenta converter um por um para achar o "Cofre Podre"
        for (var doc in cofresSnap.docs) {
          try {
            final cofre = Cofre.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
            todosOsCofres.add(cofre);
          } catch (e) {
            print("🚨 ERRO AO CONVERTER COFRE (ID: ${doc.id}): $e");
            print("Dados do documento: ${doc.data()}");
          }
        }



      }

/* espião (teste improvisado apara achar inconsistencia)
      print("🏁 Total de cofres válidos retornados: ${todosOsCofres.length}");
*/

      return todosOsCofres;
    } catch (e) {
      print("Erro ao buscar cofres: $e");
      return [];
    }
  }

  Future<void> atualizarMetaCofre(String cofreId, int novaMeta) async {
    await _db.collection('cofres').doc(cofreId).update({
      'valor_plano': novaMeta,
    });
  }

  Future<void> updateDespesa(Despesa despesa) async {
    if (despesa.id == null) return;
    // .update() mistura os dados novos com os antigos
    await _db.collection('despesas').doc(despesa.id).update(despesa.toJson());
  }

  Future<void> finalizarCofre(String cofreId) async {
    await _db.collection('cofres').doc(cofreId).update({
      'isFinalizado': true,
    });
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
        .where('id_cofre', isEqualTo: cofreId)
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
        .where('id_usuario', isEqualTo: permissao.idUsuario)
        .where('id_cofre', isEqualTo: permissao.idCofre)
        .limit(1)
        .get();

    if (existing.docs.isEmpty) {
      await _db.collection('permissoes').add(permissao.toJson());
    }
  }

  Future<List<Permissao>> getMembrosCofre(String cofreId) async {
    final snapshot = await _db
        .collection('permissoes')
        .where('id_cofre', isEqualTo: cofreId)
        .get();
    return snapshot.docs.map((doc) => Permissao.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)).toList();
  }

  /// Remove a permissão de um usuário para um cofre específico.
  /// Usado tanto para 'Sair do Grupo' quanto para 'Expulsar Membro'.
  Future<void> removePermissao(String idUsuario, String idCofre) async {
    // 1. Busca o documento da permissão exata
    final snapshot = await _db
        .collection('permissoes')
        .where('id_usuario', isEqualTo: idUsuario) // <--- Use com underline!
        .where('id_cofre', isEqualTo: idCofre)     // <--- Use com underline!
        .limit(1)
        .get();

    // 2. Se encontrar, deleta o documento
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
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
        .where('id_usuario_convidado', isEqualTo: userId)
        .where('status', isEqualTo: 'pendente')
        .get();
    return snapshot.docs.map((doc) => Convite.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)).toList();
  }

  Future<void> responderConvite(String conviteId, StatusConvite novoStatus) async {
    await _db.collection('convites').doc(conviteId).update({
      'status': novoStatus.name,
      }
    );
  }
//====================== Membros e Convites implementado ===================

  // ========================== MÉTODOS DE DESPESAS ========================================
  /// Adiciona uma despesa (Planejada ou Real)
  Future<void> addDespesa(Despesa despesa) async {
    await _db.collection('despesas').add(despesa.toJson());
    
    // LÓGICA DE ATUALIZAÇÃO DA META (Só se for planejada)
    // Se adicionamos um planejamento novo, a meta do cofre deve subir automaticamente?
    // Por enquanto, vamos deixar o usuário atualizar a meta manualmente ou 
    // faremos isso no Store para ter mais controle.
  }

  /// Busca todas as despesas de um cofre
  Future<List<Despesa>> getDespesasDoCofre(String cofreId) async {
    final snapshot = await _db
        .collection('despesas')
        .where('id_cofre', isEqualTo: cofreId)
        .get();

    return snapshot.docs
        .map((doc) => Despesa.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList();
  }

  /// Remove uma despesa
  Future<void> deleteDespesa(String despesaId) async {
    await _db.collection('despesas').doc(despesaId).delete();
  }
}