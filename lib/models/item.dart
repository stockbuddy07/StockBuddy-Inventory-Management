class Item {
  final String id;
  final String name;
  final int quantity;
  final String quantityType;
  final int limit;

  Item({required this.id, required this.name, required this.quantity, required this.quantityType, required this.limit});
  factory Item.fromMap(String id, Map<String, dynamic> map) => Item(
    id: id,
    name: map['name'],
    quantity: map['quantity'],
    quantityType: map['quantityType'],
    limit: map['limit'],
  );
  Map<String, dynamic> toMap() => {
    'name': name,
    'quantity': quantity,
    'quantityType': quantityType,
    'limit': limit,
  };
}
