import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/pg.dart';
import '../widgets/common_widgets.dart';

class PGPage extends StatefulWidget {
  const PGPage({super.key});

  @override
  _PGPageState createState() => _PGPageState();
}

class _PGPageState extends State<PGPage> {
  final FirebaseService _service = FirebaseService();
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage PGs')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: CommonWidgets.textField(
              controller: _nameController,
              label: 'PG Name',
            ),
          ),
          CommonWidgets.elevatedButton(
            text: 'Add PG',
            onPressed: () {
              final name = _nameController.text.trim();
              if (name.isNotEmpty) {
                final newPG = PG(id: '', name: name);
                _service.addPG(newPG).then((_) {
                  _nameController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PG added successfully')),
                  );
                });
              }
            },
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<List<PG>>(
              stream: _service.getPGs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final pgs = snapshot.data ?? [];
                if (pgs.isEmpty) return const Center(child: Text('No PGs found.'));

                return ListView.builder(
                  itemCount: pgs.length,
                  itemBuilder: (context, index) {
                    final pg = pgs[index];
                    return CommonWidgets.cardTile(
                      title: pg.name,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _service.deletePG(pg.id).then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('PG deleted')),
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
