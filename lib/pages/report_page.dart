import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/distribution.dart';
import '../models/item.dart';
import '../models/pg.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirebaseService();

    return Scaffold(
      appBar: AppBar(title: const Text('Distribution Reports')),
      body: StreamBuilder<List<Distribution>>(
        stream: service.getDistributions(),
        builder: (context, distSnapshot) {
          if (!distSnapshot.hasData) return const Center(child: CircularProgressIndicator());
          final distributions = distSnapshot.data!;
          if (distributions.isEmpty) return const Center(child: Text('No distributions yet.'));

          // Fetch PGs and Items simultaneously
          return StreamBuilder<List<PG>>(
            stream: service.getPGs(),
            builder: (context, pgSnapshot) {
              if (!pgSnapshot.hasData) return const Center(child: CircularProgressIndicator());
              final pgs = pgSnapshot.data!;
              final pgMap = {for (var pg in pgs) pg.id: pg.name};

              return StreamBuilder<List<Item>>(
                stream: service.getItems(),
                builder: (context, itemSnapshot) {
                  if (!itemSnapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final items = itemSnapshot.data!;
                  final itemMap = {for (var item in items) item.id: item.name};

                  return ListView.builder(
                    itemCount: distributions.length,
                    itemBuilder: (context, index) {
                      final dist = distributions[index];
                      final pgName = pgMap[dist.pgId] ?? dist.pgId;
                      final itemName = itemMap[dist.itemId] ?? dist.itemId;

                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text('PG: $pgName'),
                          subtitle: Text(
                            'Item: $itemName\nQuantity: ${dist.quantity}\nDate: ${dist.date.toLocal()}',
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
