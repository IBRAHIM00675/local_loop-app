import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyFeedbackScreen extends StatefulWidget {
  const MyFeedbackScreen({super.key});

  @override
  State<MyFeedbackScreen> createState() => _MyFeedbackScreenState();
}

class _MyFeedbackScreenState extends State<MyFeedbackScreen> {
  static const Color themeColor = Color(0xFF2193b0);

  Future<List<Map<String, dynamic>>> fetchMyFeedback() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      throw Exception("User not logged in");
    }

    // Removed orderBy to avoid needing Firestore index
    final feedbackSnapshot = await FirebaseFirestore.instance
        .collection('event_feedback')
        .where('userId', isEqualTo: userId)
        .get();

    List<Map<String, dynamic>> feedbackList = [];

    for (var doc in feedbackSnapshot.docs) {
      final data = doc.data();
      final eventId = data['eventId'];
      final eventDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .get();

      final eventTitle = eventDoc.exists ? eventDoc['title'] : 'Unknown Event';

      feedbackList.add({
        'eventTitle': eventTitle,
        'rating': data['rating'],
        'feedback': data['feedback'],
        'submittedAt': (data['submittedAt'] as Timestamp).toDate(),
      });
    }

    // Sort locally by submittedAt descending
    feedbackList.sort((a, b) => b['submittedAt'].compareTo(a['submittedAt']));

    return feedbackList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Feedback History'),
        backgroundColor: themeColor,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchMyFeedback(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  '❌ Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            final feedbackList = snapshot.data ?? [];

            if (feedbackList.isEmpty) {
              return const Center(
                child: Text(
                  '📝 You haven’t submitted any feedback yet.',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: feedbackList.length,
              itemBuilder: (context, index) {
                final item = feedbackList[index];
                return Card(
                  color: Colors.white.withOpacity(0.95),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['eventTitle'] ?? 'Unknown Event',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              Icons.star,
                              size: 20,
                              color: i < item['rating']
                                  ? Colors.amber
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(item['feedback']),
                        const SizedBox(height: 8),
                        Text(
                          'Submitted on: ${item['submittedAt'].toString().substring(0, 16)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
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
