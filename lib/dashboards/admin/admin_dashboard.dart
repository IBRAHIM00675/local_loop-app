import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  static const Color themeColor = Color(0xFF2193b0);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int totalUsers = 0;
  int pendingNgos = 0;
  int activeEvents = 0;


  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    final usersSnap = await FirebaseFirestore.instance.collection('users').get();
    final eventsSnap = await FirebaseFirestore.instance.collection('events').get();

    setState(() {
      totalUsers = usersSnap.docs.length;

      pendingNgos = usersSnap.docs.where((doc) {
        final data = doc.data();
        final role = data['role'];
        final isVerified = data.containsKey('isVerified') ? data['isVerified'] : false;
        return role == 'NGO' && isVerified == false;
      }).length;

      activeEvents = eventsSnap.docs.where((doc) {
        final data = doc.data();
        return data.containsKey('isApproved') && data['isApproved'] == true;
      }).length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AdminDashboard.themeColor,
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
                  Icon(Icons.admin_panel_settings, size: 40, color: Colors.white),
                  SizedBox(height: 10),
                  Text('Admin Panel', style: TextStyle(color: Colors.white, fontSize: 20)),
                ],
              ),
            ),
            _drawerItem(context, Icons.supervised_user_circle, 'Manage Users', '/admin/manage-users'),
            _drawerItem(context, Icons.verified_user, 'Verify NGOs', '/admin/verify-ngos'),
            _drawerItem(context, Icons.event, 'Moderate Events', '/admin/manage-events'),
            _drawerItem(context, Icons.analytics, 'Analytics', '/admin/analytics'),
            _drawerItem(context, Icons.settings, 'Settings', '/admin/settings'),
            const Divider(),
            _drawerItem(context, Icons.logout, 'Logout', '/login', replace: true),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome, Admin 👋',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SummaryCard(label: 'Total Users', count: totalUsers, icon: Icons.people),
                SummaryCard(label: 'Pending NGOs', count: pendingNgos, icon: Icons.hourglass_top),
                SummaryCard(label: 'Approved Events', count: activeEvents, icon: Icons.event_available),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String label, String route, {bool replace = false}) {
    return ListTile(
      leading: Icon(icon, color: AdminDashboard.themeColor),
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
}

class SummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;

  const SummaryCard({
    super.key,
    required this.label,
    required this.count,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: AdminDashboard.themeColor),
              const SizedBox(height: 10),
              Text(label, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 6),
              Text(
                count.toString(),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
