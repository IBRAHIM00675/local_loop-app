import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NgoDashboard extends StatelessWidget {
  const NgoDashboard({super.key});

  static const Color themeColor = Color(0xFF2193b0);

  @override
  Widget build(BuildContext context) {
    final String ngoId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NGO Dashboard'),
        backgroundColor: themeColor,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.account_balance, size: 40, color: Colors.white),
                  SizedBox(height: 10),
                  Text('Welcome, NGO!', style: TextStyle(color: Colors.white, fontSize: 20)),
                ],
              ),
            ),

            // 🔥 Real-time NGO summary card
            _ngoDrawerSummary(ngoId),

            const Divider(),
            _drawerItem(context, Icons.add, 'Create Event', '/ngo/create-event'),
            _drawerItem(context, Icons.edit_calendar, 'Manage Events', '/ngo/manage-events'),
            _drawerItem(context, Icons.edit, 'Create Profile', '/ngo/profile'),
            _drawerItem(context, Icons.visibility, 'View Profile', '/ngo/view-profile'),
            _drawerItem(context, Icons.group, 'Manage Volunteers', '/ngo/manage-volunteers'),
            _drawerItem(context, Icons.assignment, 'Track Attendance', '/ngo/attendance/select-event'),

            const Divider(),
            _drawerItem(context, Icons.logout, 'Logout', '/login', replace: true),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard Overview',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _realtimeCounterCard('events', Icons.event, 'Total Events'),
                  _volunteerCountCard(),
                  _ngoStatusCard(ngoId),
                  _profileStatusCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _ngoDrawerSummary(String ngoId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('ngos').doc(ngoId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox(); 
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final String name = data['name'] ?? 'NGO';
        final String status = data['status'] ?? 'Pending';
        final String email = data['email'] ?? 'No Email';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.verified_user, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text("Status: $status", style: const TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.email, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(email, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String label, String route, {bool replace = false}) {
    return ListTile(
      leading: Icon(icon, color: themeColor),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        if (replace) {
          Navigator.pushReplacementNamed(context, route);
        } else {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }

  Widget _realtimeCounterCard(String collection, IconData icon, String title) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        int count = 0;
        if (snapshot.hasData) {
          count = snapshot.data!.docs.length;
        }
        return _dashboardCard(icon, title, count.toString(), themeColor);
      },
    );
  }

  Widget _volunteerCountCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Volunteer')
          .snapshots(),
      builder: (context, snapshot) {
        int count = 0;
        if (snapshot.hasData) {
          count = snapshot.data!.docs.length;
        }
        return _dashboardCard(Icons.group, 'Volunteers', count.toString(), themeColor);
      },
    );
  }

  Widget _ngoStatusCard(String ngoId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('ngos').doc(ngoId).snapshots(),
      builder: (context, snapshot) {
        String status = 'Loading...';
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          status = data['status'] ?? 'Pending';
        }
        return _dashboardCard(Icons.verified_user, 'NGO Status', status, themeColor);
      },
    );
  }

  Widget _profileStatusCard() {
    return _dashboardCard(Icons.person, 'Profile Status', 'Complete', themeColor);
  }

  Widget _dashboardCard(IconData icon, String title, String value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
