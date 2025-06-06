import 'package:flutter/material.dart';

class NgoDashboard extends StatelessWidget {
  const NgoDashboard({super.key});

  static const Color themeColor = Color(0xFF2193b0);

  @override
  Widget build(BuildContext context) {
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
                  Text('Welcome NGO', style: TextStyle(color: Colors.white, fontSize: 20)),
                ],
              ),
            ),
            _drawerItem(context, Icons.add, 'Create Event', '/ngo/create-event'),
            _drawerItem(context, Icons.edit_calendar, 'Manage Events', '/ngo/manage-events'),
             _drawerItem(context, Icons.edit, 'create Profile', '/ngo/profile'),
            _drawerItem(context, Icons.visibility, 'View Profile', '/ngo/view-profile'),
           
            const Divider(),
            _drawerItem(context, Icons.logout, 'Logout', '/login', replace: true),
          ],
        ),
      ),
      body: const Center(
        child: Text(
          'Welcome to your NGO Dashboard 👋',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String label, String route,
      {bool replace = false}) {
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
}
