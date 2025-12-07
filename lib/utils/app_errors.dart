class AppErrors {
  /// Recebe um erro (pode ser String, Exception ou null) e retorna uma mensagem amigável.
  static String traduzir(dynamic erro) {
    if (erro == null) return 'Erro desconhecido.';
    
    // Converte para string e para minúsculo para facilitar a busca
    String mensagem = erro.toString().toLowerCase();

    // --- 1. ERROS DE VALIDAÇÃO DO PRÓPRIO APP (Prioridade Alta) ---
    if (mensagem.contains('as senhas não coincidem')) {
      return 'As senhas não coincidem.';
    }
    else if (mensagem.contains('preencha todos os campos')) {
      return 'Por favor, preencha todos os campos obrigatórios.';
    }
    else if (mensagem.contains('requisitos mínimos')) {
      return 'A senha deve ter no mínimo 6 caracteres, uma letra maiúscula e um número.';
    }
    else if (mensagem.contains('valor alvo deve ser um número maior')) {
      return 'O valor da meta deve ser maior que zero.';
    }
    else if (mensagem.contains('insira um valor válido')) {
      return 'Insira um valor monetário válido.';
    }
    else if (mensagem.contains('digite um email válido')) {
      return 'O formato do e-mail parece inválido.';
    }

    // --- 2. ERROS DE AUTENTICAÇÃO (Firebase Auth) ---
    else if (mensagem.contains('user-not-found') || mensagem.contains('user not found')) {
      return 'Usuário não encontrado. Verifique o e-mail.';
    } 
    else if (mensagem.contains('wrong-password')) {
      return 'Senha incorreta. Tente novamente.';
    } 
    else if (mensagem.contains('invalid-credential')) {
      return 'E-mail ou senha incorretos.';
    }
    else if (mensagem.contains('email-already-in-use')) {
      return 'Este e-mail já está sendo usado por outra conta.';
    } 
    else if (mensagem.contains('weak-password')) {
      return 'A senha é muito fraca. Escolha uma senha mais forte.';
    }
    else if (mensagem.contains('invalid-email') || mensagem.contains('badly formatted')) {
      return 'O formato do e-mail é inválido.';
    }
    else if (mensagem.contains('requires-recent-login')) {
      return 'Por segurança, faça login novamente antes de realizar esta ação.';
    }
    else if (mensagem.contains('account-exists-with-different-credential')) {
      return 'Já existe uma conta com este e-mail.';
    }
    else if (mensagem.contains('usuário não logado') || mensagem.contains('erro de sessão')) {
      return 'Sessão expirada. Faça login novamente.';
    }

    // --- 3. ERROS DE NEGÓCIO (Cofres e Convites) ---
    else if (mensagem.contains('código inválido') || mensagem.contains('cofre não encontrado')) {
      return 'Código inválido ou o cofre não existe.';
    }
    else if (mensagem.contains('já participa deste cofre')) {
      return 'Você já é membro deste cofre!';
    }
    else if (mensagem.contains('usuário com email') && mensagem.contains('não encontrado')) {
      return 'Não encontramos nenhum usuário com este e-mail.';
    }
    else if (mensagem.contains('não pode convidar a si mesmo')) {
      return 'Você não pode enviar um convite para você mesmo.';
    }
    else if (mensagem.contains('este e-mail não está cadastrado')) {
      return 'Este e-mail não possui conta no nosso aplicativo.';
    }

    // --- 4. ERROS DE REDE E SISTEMA ---
    else if (mensagem.contains('network-request-failed') || mensagem.contains('unavailable')) {
      return 'Sem conexão com a internet ou servidor indisponível.';
    } 
    else if (mensagem.contains('too-many-requests')) {
      return 'Muitas tentativas falhas. Aguarde alguns minutos e tente novamente.';
    }
    else if (mensagem.contains('permission-denied')) {
      return 'Você não tem permissão para realizar esta ação.';
    } 
    else if (mensagem.contains('not-found')) {
      return 'O item solicitado não foi encontrado.';
    }

    // --- 5. LIMPEZA FINAL ---
    // Remove a palavra "Exception:" se ela aparecer em erros genéricos
    else if (mensagem.contains('exception:')) {
       return mensagem.replaceAll('exception:', '').trim();
    }

    // Padrão final se nada for identificado
    return 'Ocorreu um erro inesperado. Tente novamente.'; 
  }
}