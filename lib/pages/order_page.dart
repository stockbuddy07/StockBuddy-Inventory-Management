import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/item.dart';
import '../models/order.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final FirebaseService _service = FirebaseService();
  Item? _selectedItem;
  final TextEditingController _quantityController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _placeOrder() async {
    if (_selectedItem == null || _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an item and enter quantity')),
      );
      return;
    }

    final qty = int.tryParse(_quantityController.text);
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid quantity')),
      );
      return;
    }

    final order = Orders(
      id: '',
      itemId: _selectedItem!.id,
      quantity: qty,
      date: DateTime.now(),
    );

    await _service.addOrder(order);

    _quantityController.clear();
    setState(() => _selectedItem = null);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order placed successfully — stock updated!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Stock')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            StreamBuilder<List<Item>>(
              stream: _service.getItems(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = snapshot.data!;

                // Ensure selected item still exists in updated list
                final validSelectedItem = _selectedItem == null
                    ? null
                    : items.firstWhere(
                      (item) => item.id == _selectedItem!.id,
                  orElse: () => _selectedItem = null as Item,
                );

                return DropdownButtonFormField<Item>(
                  value: validSelectedItem,
                  hint: const Text('Select Item'),
                  onChanged: (item) => setState(() => _selectedItem = item),
                  items: items
                      .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item.name),
                  ))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter Quantity',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _placeOrder,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Place Order'),
            ),
          ],
        ),
      ),
    );
  }
}
