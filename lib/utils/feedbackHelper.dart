import 'package:travelbox/utils/app_errors.dart';
import 'package:flutter/material.dart';

class FeedbackHelper {

  static void mostrarErro(BuildContext context, String? erroCru) {
    // 1. REMOVI O 'if (erroCru == null) { ... }' que estava bloqueando tudo.
    
  //espião 

  print("🚨 ERRO CRU RECEBIDO: $erroCru");



    // O AppErrors.traduzir já cuida se for nulo, retornando uma mensagem genérica.
    final mensagemTraduzida = AppErrors.traduzir(erroCru);

    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensagemTraduzida,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void mostrarSucesso(BuildContext context, String mensagem){
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(mensagem, style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}