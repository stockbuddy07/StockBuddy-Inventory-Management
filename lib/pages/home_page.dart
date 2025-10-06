import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:inventory/pages/PG_page.dart';
import 'package:inventory/pages/distribute_page.dart';
import 'package:inventory/pages/item_page.dart';
import 'package:inventory/pages/order_page.dart';
import 'package:inventory/pages/report_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (user != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Logged in as: ${user.email ?? user.uid}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const PGPage())),
              child: const Text('Manage PGs'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const ItemPage())),
              child: const Text('Manage Items'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const DistributePage())),
              child: const Text('Distribute Items'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const OrderPage())),
              child: const Text('Order Items'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const ReportPage())),
              child: const Text('Distribution Reports'),
            ),
          ],
        ),
      ),
    );
  }
}
