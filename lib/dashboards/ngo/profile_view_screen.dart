import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileViewScreen extends StatelessWidget {
  const ProfileViewScreen({super.key});

  static const Color themeColor = Color(0xFF2193b0);

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: themeColor,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: _fetchProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                child: Text("❌ Profile not found.", style: TextStyle(color: Colors.white)),
              );
            }

            final data = snapshot.data!.data()!;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  elevation: 12,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.account_circle, size: 40, color: themeColor),
                            SizedBox(width: 12),
                            Text(
                              'NGO Profile',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(height: 32, thickness: 1),
                        _profileItem('🏢 Organization', data['orgName']),
                        _profileItem('📞 Contact Info', data['contact']),
                        _profileItem('📍 Location', data['location']),
                        _profileItem('📝 Description', data['description']),
                      ],
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _profileItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value?.isNotEmpty == true ? value! : 'Not provided',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
