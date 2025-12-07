import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.currency(
    locale: 'pt_BR', 
    symbol: 'R\$', 
    decimalDigits: 2
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, 
    TextEditingValue newValue
  ) {
    // 1. Se o usuário apagou tudo, reseta para zero
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: 'R\$ 0,00', selection: const TextSelection.collapsed(offset: 7));
    }

    // 2. Limpa tudo que não é número
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // 3. Se ficou vazio após limpar, reseta
    if (newText.isEmpty) {
      return newValue.copyWith(text: 'R\$ 0,00', selection: const TextSelection.collapsed(offset: 7));
    }

    // 4. Converte para inteiro (centavos) e divide por 100 para virar decimal
    double value = double.parse(newText) / 100;

    // 5. Formata como moeda brasileira
    String newString = _formatter.format(value);

    // 6. Retorna o novo texto e mantém o cursor no final
    return newValue.copyWith(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}