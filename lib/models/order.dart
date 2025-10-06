import 'package:cloud_firestore/cloud_firestore.dart';
class Orders {
  final String id;
  // final String pgId;
  final String itemId;
  final int quantity;
  final DateTime date;

  Orders({
    required this.id,
    // required this.pgId,
    required this.itemId,
    required this.quantity,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      // 'pgId': pgId,
      'itemId': itemId,
      'quantity': quantity,
      'date': date.toIso8601String(),
    };
  }

  factory Orders.fromMap(String id, Map<String, dynamic> map) {
    return Orders(
      id: id,
      // pgId: map['pgId'] ?? '',
      itemId: map['itemId'] ?? '',
      quantity: map['quantity'] ?? 0,
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    );
  }

}
