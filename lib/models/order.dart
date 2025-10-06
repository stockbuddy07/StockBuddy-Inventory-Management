import 'package:cloud_firestore/cloud_firestore.dart';
class Orders {
  final String id;
  final String pgId;
  final List<String> itemIds;
  final List<int> quantity;
  final DateTime date;

  Orders({required this.id, required this.pgId, required this.itemIds, required this.quantity, required this.date});
  factory Orders.fromMap(String id, Map<String, dynamic> map) => Orders(
    id: id,
    pgId: map['pgId'],
    itemIds: List<String>.from(map['itemIds']),
    quantity: List<int>.from(map['quantity']),
    date: (map['date'] as Timestamp).toDate(),
  );
  Map<String, dynamic> toMap() => {
    'pgId': pgId,
    'itemIds': itemIds,
    'quantity': quantity,
    'date': Timestamp.fromDate(date),
  };
}
