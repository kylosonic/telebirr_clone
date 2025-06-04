// lib/models/transaction.dart
class TransactionRecord {
  final int? id;
  final String type; // e.g. “Transfer Money” / “Buy Goods”
  final double amount; // base or total as you prefer
  final String currency; // “ETB”
  final String counterparty; // name or merchant
  final String timestamp; // yyyy/MM/dd HH:mm:ss
  final String pdfPath; // local file path
  final String transactionNo; // Added for transaction number
  final double fee; // Added for service charge

  TransactionRecord({
    this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.counterparty,
    required this.timestamp,
    required this.pdfPath,
    required this.transactionNo,
    required this.fee,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type,
    'amount': amount,
    'currency': currency,
    'counterparty': counterparty,
    'timestamp': timestamp,
    'pdfPath': pdfPath,
    'transactionNo': transactionNo,
    'fee': fee,
  };

  factory TransactionRecord.fromMap(Map<String, dynamic> m) =>
      TransactionRecord(
        id: m['id'] as int?,
        type: m['type'],
        amount: m['amount'],
        currency: m['currency'],
        counterparty: m['counterparty'],
        timestamp: m['timestamp'],
        pdfPath: m['pdfPath'],
        transactionNo: m['transactionNo'],
        fee: m['fee'],
      );
}
