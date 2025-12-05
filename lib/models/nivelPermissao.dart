enum NivelPermissao {
  coordenador,
  contribuinte;

  static NivelPermissao fromString(String nivel) {
    return NivelPermissao.values.firstWhere(
      (e) => e.name == nivel,
      orElse: () => NivelPermissao.contribuinte, //Todo novo usuario será definido como contribuinte quando entrar no cofre. Por motivos de segurança :)
    );
  }
}
