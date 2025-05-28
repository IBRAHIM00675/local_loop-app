import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ManageOwnEventsScreen extends StatefulWidget {
  const ManageOwnEventsScreen({super.key});

  @override
  State<ManageOwnEventsScreen> createState() => _ManageOwnEventsScreenState();
}

class _ManageOwnEventsScreenState extends State<ManageOwnEventsScreen> {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  Future<void> _deleteEvent(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('events').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🗑️ Event deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF2193b0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage My Events'),
        backgroundColor: themeColor,
      ),
      body: userId == null
          ? const Center(
              child: Text(
                "⚠️ You must be logged in to view your events.",
                style: TextStyle(color: Colors.white),
              ),
            )
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('events')
                    .where('createdBy', isEqualTo: userId)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "❌ Error: ${snapshot.error}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  final events = snapshot.data!.docs;

                  if (events.isEmpty) {
                    return const Center(
                      child: Text(
                        "You haven't created any events yet.",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      final data = event.data() as Map<String, dynamic>;

                      final date = data['date'] != null
                          ? data['date'].toDate().toLocal().toString().split(' ')[0]
                          : 'No date';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['title'] ?? '',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(data['description'] ?? ''),
                              const SizedBox(height: 8),
                              Text("📍 ${data['location'] ?? 'N/A'}"),
                              const SizedBox(height: 4),
                              Text("📅 $date"),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    data['isApproved'] == true ? '✅ Approved' : '🕒 Pending',
                                    style: TextStyle(
                                      color: data['isApproved'] == true ? Colors.green : Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteEvent(event.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}
