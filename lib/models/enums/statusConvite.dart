enum StatusConvite {
  pendente,
  aceito,
  recusado;

  static StatusConvite fromString(String status) {
    return StatusConvite.values.firstWhere(
      (e) => e.name == status,
      orElse: () => StatusConvite.pendente, //O status de pendente é o padrão.
    );
  }

}