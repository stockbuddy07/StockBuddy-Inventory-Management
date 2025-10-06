class Distribution {
  final String id;
  final String pgId;
  final String itemId;
  final int quantity;
  final DateTime date;

  Distribution({
    required this.id,
    required this.pgId,
    required this.itemId,
    required this.quantity,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'pgId': pgId,
      'itemId': itemId,
      'quantity': quantity,
      'date': date.toIso8601String(),
    };
  }

  factory Distribution.fromMap(String id, Map<String, dynamic> map) {
    return Distribution(
      id: id,
      pgId: map['pgId'] ?? '',
      itemId: map['itemId'] ?? '',
      quantity: map['quantity'] ?? 0,
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
    );
  }
}
