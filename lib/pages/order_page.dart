import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/pg.dart';
import '../models/item.dart';
import '../models/order.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final FirebaseService _service = FirebaseService();
  PG? _selectedPG;
  final Map<Item, int> _selectedItems = {};
  final Map<Item, TextEditingController> _controllers = {};

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Items')),
      body: Column(
        children: [
          StreamBuilder<List<PG>>(
            stream: _service.getPGs(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final pgs = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: DropdownButton<PG>(
                  value: _selectedPG,
                  hint: const Text('Select PG'),
                  onChanged: (pg) => setState(() => _selectedPG = pg),
                  items: pgs
                      .map((pg) => DropdownMenuItem(
                    value: pg,
                    child: Text(pg.name),
                  ))
                      .toList(),
                ),
              );
            },
          ),
          Expanded(
            child: StreamBuilder<List<Item>>(
              stream: _service.getItems(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final items = snapshot.data!;
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    _controllers.putIfAbsent(item, () => TextEditingController());
                    return ListTile(
                      title: Text(item.name),
                      trailing: SizedBox(
                        width: 60,
                        child: TextField(
                          controller: _controllers[item],
                          decoration: const InputDecoration(hintText: 'Qty'),
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            int qty = int.tryParse(val) ?? 0;
                            setState(() {
                              if (qty > 0) {
                                _selectedItems[item] = qty;
                              } else {
                                _selectedItems.remove(item);
                              }
                            });
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              onPressed: () {
                if (_selectedPG == null || _selectedItems.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Select PG and at least one item')),
                  );
                  return;
                }

                final order = Orders(
                  id: '',
                  pgId: _selectedPG!.id,
                  itemIds: _selectedItems.keys.map((e) => e.id).toList(),
                  quantity: _selectedItems.values.toList(),
                  date: DateTime.now(),
                );

                _service.addOrder(order).then((_) {
                  // Clear all input fields
                  for (var controller in _controllers.values) {
                    controller.clear();
                  }
                  _selectedItems.clear();
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order placed successfully')),
                  );
                });
              },
              child: const Text('Place Order'),
            ),
          ),
        ],
      ),
    );
  }
}
