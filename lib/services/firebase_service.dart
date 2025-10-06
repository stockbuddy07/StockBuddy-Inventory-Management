import 'package:firebase_database/firebase_database.dart';
import '../models/pg.dart';
import '../models/item.dart';
import '../models/distribution.dart';
import '../models/order.dart';

class FirebaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // --- PG ---
  Future<void> addPG(PG pg) async {
    await _db.child('pgs').push().set(pg.toMap());
  }

  Stream<List<PG>> getPGs() {
    return _db.child('pgs').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      return data.entries
          .map((e) => PG.fromMap(e.key, Map<String, dynamic>.from(e.value)))
          .toList();
    });
  }

  Future<void> deletePG(String id) async {
    await _db.child('pgs/$id').remove();
  }

  // --- Item ---
  Future<void> addItem(Item item) async {
    await _db.child('items').push().set(item.toMap());
  }

  Stream<List<Item>> getItems() {
    return _db.child('items').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      return data.entries
          .map((e) => Item.fromMap(e.key, Map<String, dynamic>.from(e.value)))
          .toList();
    });
  }

  Future<void> deleteItem(String id) async {
    await _db.child('items/$id').remove();
  }

  // --- Distribution ---
  /// Store **one item per distribution record**
  Future<void> addDistribution(Distribution dist) async {
    await _db.child('distributions').push().set({
      'pgId': dist.pgId,
      'itemId': dist.itemId, // single item
      'quantity': dist.quantity, // single quantity
      'date': dist.date.toIso8601String(),
    });
  }

  Stream<List<Distribution>> getDistributions() {
    return _db.child('distributions').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      final list = data.entries
          .map((e) => Distribution.fromMap(e.key, Map<String, dynamic>.from(e.value)))
          .toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  Future<void> deleteDistribution(String id) async {
    await _db.child('distributions/$id').remove();
  }

  // --- Orders ---
  Future<void> addOrder(Orders order) async {
    // Save order record
    await _db.child('orders').push().set(order.toMap());

    // Increase stock for the ordered item
    await increaseItemStock(order.itemId, order.quantity);
  }


  Stream<List<Orders>> getOrders() {
    return _db.child('orders').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      final list = data.entries
          .map((e) => Orders.fromMap(e.key, Map<String, dynamic>.from(e.value)))
          .toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  Future<void> deleteOrder(String id) async {
    await _db.child('orders/$id').remove();
  }

  // --- Stock Management for Items ---
  /// Reduce item stock when distributing
  Future<void> reduceItemStock(String itemId, int qty) async {
    final ref = _db.child('items/$itemId');
    final snapshot = await ref.get();
    if (!snapshot.exists) return;

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    final currentQty = (data['quantity'] ?? 0) as int;
    final newQty = currentQty - qty;
    await ref.update({'quantity': newQty});
  }

  /// Increase item stock when ordering new items
  Future<void> increaseItemStock(String itemId, int qty) async {
    final ref = _db.child('items/$itemId');
    final snapshot = await ref.get();
    if (!snapshot.exists) return;

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    final currentQty = (data['quantity'] ?? 0) as int;
    final newQty = currentQty + qty;
    await ref.update({'quantity': newQty});
  }

  /// Get current quantity of item
  Future<int> getItemQuantity(String itemId) async {
    final snapshot = await _db.child('items/$itemId').get();
    if (!snapshot.exists) return 0;

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    return (data['quantity'] ?? 0) as int;
  }

  /// Get limit of item
  Future<int> getItemLimit(String itemId) async {
    final snapshot = await _db.child('items/$itemId').get();
    if (!snapshot.exists) return 0;

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    return (data['limit'] ?? 0) as int;
  }
}
