import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditVolunteerProfile extends StatefulWidget {
  const EditVolunteerProfile({super.key});

  @override
  State<EditVolunteerProfile> createState() => _EditVolunteerProfileState();
}

class _EditVolunteerProfileState extends State<EditVolunteerProfile> {
  final user = FirebaseAuth.instance.currentUser;
  final nameController = TextEditingController();
  final contactController = TextEditingController();
  final bioController = TextEditingController();
  bool isLoading = false;

  Future<void> _loadProfile() async {
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
    final data = doc.data();
    if (data != null) {
      nameController.text = data['name'] ?? '';
      contactController.text = data['contact'] ?? '';
      bioController.text = data['bio'] ?? '';
    }
  }

  Future<void> _saveChanges() async {
    if (user == null) return;
    setState(() => isLoading = true);
    await FirebaseFirestore.instance.collection('users').doc(user?.uid).update({
      'name': nameController.text.trim(),
      'contact': contactController.text.trim(),
      'bio': bioController.text.trim(),
    });
    setState(() => isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Profile updated!')),
      );
      Navigator.pop(context); // Go back to the profile view
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF2193b0);
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile"), backgroundColor: themeColor),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contactController,
              decoration: const InputDecoration(labelText: 'Contact', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bioController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Bio', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  minimumSize: const Size.fromHeight(45),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
