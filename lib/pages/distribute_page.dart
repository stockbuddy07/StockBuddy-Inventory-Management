import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/pg.dart';
import '../models/item.dart';
import '../models/distribution.dart';
import '../widgets/common_widgets.dart';

class DistributePage extends StatefulWidget {
  const DistributePage({super.key});

  @override
  _DistributePageState createState() => _DistributePageState();
}

class _DistributePageState extends State<DistributePage> {
  final FirebaseService _service = FirebaseService();

  PG? _selectedPG;
  final List<Map<String, dynamic>> _selectedItemEntries = []; // [{item: Item, qty: int}]
  final List<TextEditingController> _controllers = [];

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addNewItemRow(List<Item> items) {
    if (items.isEmpty) return;

    final controller = TextEditingController();
    _controllers.add(controller);
    _selectedItemEntries.add({'item': items.first, 'qty': 0});
    setState(() {});
  }

  void _removeItemRow(int index) {
    _controllers[index].dispose();
    _controllers.removeAt(index);
    _selectedItemEntries.removeAt(index);
    setState(() {});
  }
  Future<void> _distributeItems() async {
    if (_selectedPG == null || _selectedItemEntries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select PG and add at least one item')),
      );
      return;
    }

    final validItems = _selectedItemEntries.where((e) => e['qty'] > 0).toList();
    if (validItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid quantity for at least one item')),
      );
      return;
    }

    for (var entry in validItems) {
      final Item item = entry['item'];
      final int qty = entry['qty'];
      final int stock = await _service.getItemQuantity(item.id);

      if (qty > stock) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Not enough stock for ${item.name}. Available: $stock')),
        );
        return;
      }
    }

    // Add each item as a separate distribution record
    for (var entry in validItems) {
      final Item item = entry['item'];
      final int qty = entry['qty'];

      // Reduce stock
      await _service.reduceItemStock(item.id, qty);

      // Low stock alert
      final int stock = await _service.getItemQuantity(item.id);
      final int limit = await _service.getItemLimit(item.id);
      if (stock <= limit) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Low stock alert: ${item.name} has $stock left')),
        );
      }

      // Add distribution
      final dist = Distribution(
        id: '',
        pgId: _selectedPG!.id,
        itemId: item.id,
        quantity: qty,
        date: DateTime.now(),
      );

      await _service.addDistribution(dist);
    }

    // Clear inputs
    for (var controller in _controllers) {
      controller.clear();
    }
    _controllers.clear();
    _selectedItemEntries.clear();
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Distribution added successfully')),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Distribute Items')),
      body: Column(
        children: [
          // --- Select PG ---
          StreamBuilder<List<PG>>(
            stream: _service.getPGs(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final pgs = snapshot.data!;
              if (pgs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("No PGs found. Please add PGs first."),
                );
              }

              // Match PG by ID to avoid Dropdown error
              if (_selectedPG != null) {
                _selectedPG = pgs.firstWhere(
                      (pg) => pg.id == _selectedPG!.id,
                  orElse: () => pgs.first,
                );
              }

              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: CommonWidgets.dropdown<PG>(
                  value: _selectedPG,
                  hint: 'Select PG',
                  items: pgs,
                  onChanged: (pg) => setState(() => _selectedPG = pg),
                  itemLabel: (pg) => pg.name,
                ),
              );
            },
          ),

          // --- Items Section ---
          Expanded(
            child: StreamBuilder<List<Item>>(
              stream: _service.getItems(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snapshot.data!;
                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      'No items found. Please add items first.',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    ...List.generate(_selectedItemEntries.length, (index) {
                      final entry = _selectedItemEntries[index];
                      final controller = _controllers[index];

                      // Match item by ID for Dropdown
                      final selectedItem = items.firstWhere(
                            (it) => it.id == (entry['item'] as Item).id,
                        orElse: () => items.first,
                      );

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: DropdownButton<Item>(
                                  value: selectedItem,
                                  items: items.map((item) {
                                    return DropdownMenuItem<Item>(
                                      value: item,
                                      child: Text(item.name),
                                    );
                                  }).toList(),
                                  onChanged: (newItem) {
                                    setState(() {
                                      entry['item'] = newItem!;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 1,
                                child: TextField(
                                  controller: controller,
                                  decoration: const InputDecoration(
                                    labelText: 'Qty',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                    entry['qty'] = int.tryParse(val) ?? 0;
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeItemRow(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Item'),
                      onPressed: () => _addNewItemRow(items),
                    ),
                  ],
                );
              },
            ),
          ),

          // --- Submit Button ---
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: CommonWidgets.elevatedButton(
              text: 'Distribute',
              onPressed: _distributeItems,
            ),
          ),
        ],
      ),
    );
  }
}
