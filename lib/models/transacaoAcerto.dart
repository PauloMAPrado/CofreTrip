// lib/models/transacao_acerto.dart

class TransacaoAcerto {
  final String pagadorId;    // Quem deve
  final String recebedorId;  // Quem recebe
  final double valor;        // Quanto

  TransacaoAcerto({
    required this.pagadorId,
    required this.recebedorId,
    required this.valor,
  });
}