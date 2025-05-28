import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  Future<Map<String, dynamic>> getCounts() async {
    final users = await FirebaseFirestore.instance.collection('users').get();
    final events = await FirebaseFirestore.instance.collection('events').get();

    int totalUsers = users.docs.length;
    int ngoCount = users.docs.where((doc) => doc['role'] == 'NGO').length;
    int volunteerCount =
        users.docs.where((doc) => doc['role'] == 'Volunteer').length;

    return {
      'users': totalUsers,
      'ngos': ngoCount,
      'volunteers': volunteerCount,
      'events': events.docs.length,
    };
  }

  static const Color themeColor = Color(0xFF2193b0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: themeColor,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getCounts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Failed to load analytics.'));
          }

          final data = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24.0),
                  children: [
                    StatCard(label: 'Total Users', value: data['users'].toString()),
                    StatCard(label: 'NGOs', value: data['ngos'].toString()),
                    StatCard(label: 'Volunteers', value: data['volunteers'].toString()),
                    StatCard(label: 'Events', value: data['events'].toString()),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Dashboard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;

  const StatCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: const Icon(Icons.analytics, color: Color(0xFF2193b0)),
        title: Text(label),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
