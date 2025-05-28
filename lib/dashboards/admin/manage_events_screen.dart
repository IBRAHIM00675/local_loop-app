import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageEventsScreen extends StatelessWidget {
  const ManageEventsScreen({super.key});

  static const Color themeColor = Color(0xFF2193b0);

  Stream<QuerySnapshot> getPendingEvents() {
    return FirebaseFirestore.instance
        .collection('events')
        .where('isApproved', isEqualTo: false)
        .snapshots();
  }

  Future<void> approveEvent(String eventId) async {
    await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .update({'isApproved': true});
  }

  Future<void> rejectEvent(String eventId) async {
    await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moderate Events'),
        backgroundColor: themeColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getPendingEvents(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('❌ Error loading events.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('🎉 No events pending approval.'));
          }

          final events = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final eventId = event.id;
              final title = event['title'] ?? 'Untitled';
              final description = event['description'] ?? 'No description';

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(title),
                  subtitle: Text(description),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () => approveEvent(eventId),
                        tooltip: 'Approve',
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => rejectEvent(eventId),
                        tooltip: 'Reject',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
