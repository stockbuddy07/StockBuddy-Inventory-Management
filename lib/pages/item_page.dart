import 'package:flutter/material.dart';
import 'package:inventory/services/firebase_service.dart';
import '../models/item.dart';
import '../widgets/common_widgets.dart';

class ItemPage extends StatefulWidget {
  const ItemPage({super.key});

  @override
  _ItemPageState createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  final FirebaseService _service = FirebaseService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _limitController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Items')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                CommonWidgets.textField(controller: _nameController, label: 'Item Name'),
                const SizedBox(height: 8),
                CommonWidgets.textField(
                  controller: _qtyController,
                  label: 'Quantity',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                CommonWidgets.textField(controller: _typeController, label: 'Quantity Type'),
                const SizedBox(height: 8),
                CommonWidgets.textField(
                  controller: _limitController,
                  label: 'Limit',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                CommonWidgets.elevatedButton(
                  text: 'Add Item',
                  onPressed: () {
                    final name = _nameController.text.trim();
                    final qty = int.tryParse(_qtyController.text) ?? 0;
                    final limit = int.tryParse(_limitController.text) ?? 0;
                    final type = _typeController.text.trim();
                    if (name.isNotEmpty && type.isNotEmpty) {
                      final newItem = Item(
                        id: '',
                        name: name,
                        quantity: qty,
                        quantityType: type,
                        limit: limit,
                      );
                      _service.addItem(newItem).then((_) {
                        _nameController.clear();
                        _qtyController.clear();
                        _limitController.clear();
                        _typeController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Item added successfully')),
                        );
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<List<Item>>(
              stream: _service.getItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final items = snapshot.data ?? [];
                if (items.isEmpty) return const Center(child: Text('No items found.'));

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return CommonWidgets.cardTile(
                      title: item.name,
                      subtitle: 'Stock: ${item.quantity} ${item.quantityType}, Limit: ${item.limit}',
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _service.deleteItem(item.id).then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Item deleted')),
                            );
                          });
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
