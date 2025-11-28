class AppErrors {
  /// Recebe um erro (pode ser String, Exception ou null) e retorna uma mensagem amigável.
  static String traduzir(dynamic erro) {
    if (erro == null) return 'Erro desconhecido.';
    
    // Converte para string e para minúsculo para facilitar a busca
    String mensagem = erro.toString().toLowerCase();

    // --- ERROS DE AUTENTICAÇÃO (Auth) ---
    if (mensagem.contains('user-not-found') || mensagem.contains('user not found')) {
      return 'Usuário não encontrado. Verifique o e-mail.';
    } 
    else if (mensagem.contains('wrong-password')) {
      return 'Senha incorreta.';
    } 
    else if (mensagem.contains('invalid-credential')) {
      return 'E-mail ou senha incorretos.';
    }
    else if (mensagem.contains('email-already-in-use')) {
      return 'Este e-mail já está sendo usado.';
    } 
    else if (mensagem.contains('weak-password')) {
      return 'A senha é muito fraca. Escolha uma senha com pelo menos 8 caracteres.';
    } 
    else if (mensagem.contains('invalid-email') || mensagem.contains('badly formatted')) {
      return 'O formato do e-mail é inválido.';
    }
    else if (mensagem.contains('account-exists-with-different-credential')) {
      return 'Já existe uma conta com este e-mail associada a outro método de login.';
    }

    // --- ERROS DE REDE / GERAIS ---
    else if (mensagem.contains('network-request-failed')) {
      return 'Sem conexão com a internet. Verifique seu Wifi/Dados.';
    } 
    else if (mensagem.contains('too-many-requests')) {
      return 'Muitas tentativas falhas. Aguarde alguns minutos e tente novamente.';
    }

    // --- ERROS DO FIRESTORE (Banco de Dados) ---
    else if (mensagem.contains('permission-denied')) {
      return 'Você não tem permissão para realizar esta ação.';
    } 
    else if (mensagem.contains('unavailable')) {
      return 'O serviço está temporariamente indisponível.';
    } 
    else if (mensagem.contains('not-found')) {
      return 'O item solicitado não foi encontrado.';
    }

    else if (mensagem.contains('usuário não logado')) {
      return 'Sessão expirada. Faça login novamente.';
    }

    return 'Ocorreu um erro inesperado. Tente novamente.'; 
  }
}