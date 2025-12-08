enum CategoriaDespesa {
  transporte,
  hospedagem,
  alimentacao,
  lazer,
  outros;

  String get nome {
    switch (this) {
      case CategoriaDespesa.transporte: return 'Transporte';
      case CategoriaDespesa.hospedagem: return 'Hospedagem';
      case CategoriaDespesa.alimentacao: return 'Alimentação';
      case CategoriaDespesa.lazer: return 'Lazer';
      case CategoriaDespesa.outros: return 'Outros';
    }
  }
}