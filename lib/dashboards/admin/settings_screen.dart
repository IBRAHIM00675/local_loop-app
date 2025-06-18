import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF2193b0),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Account Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _settingItem(context, Icons.person, 'Update Profile', onTap: () {
            // Navigate to profile update screen
          }),
          _settingItem(context, Icons.email, 'Change Email', onTap: () {
            // Email change logic
          }),
          _settingItem(context, Icons.lock, 'Change Password', onTap: () {
            // Password change logic
          }),
          const Divider(height: 30),

          const Text('Preferences', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _settingItem(context, Icons.dark_mode, 'Dark Mode', trailing: Switch(value: false, onChanged: (_) {})),
          _settingItem(context, Icons.notifications, 'Push Notifications', trailing: Switch(value: true, onChanged: (_) {})),
          const Divider(height: 30),

          const Text('System', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _settingItem(context, Icons.info, 'App Version: 1.0.0'),
          _settingItem(context, Icons.logout, 'Logout', onTap: () {
            Navigator.pushReplacementNamed(context, '/login');
          }),
        ],
      ),
    );
  }

  Widget _settingItem(BuildContext context, IconData icon, String title,
      {Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2193b0)),
      title: Text(title),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
