import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

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
  Map<String, int> monthlyEvents = {};

  @override
  void initState() {
    super.initState();
    loadDashboardData();
    fetchMonthlyApprovedEvents().then((data) {
      setState(() {
        monthlyEvents = data;
      });
    });
  }

  Future<void> loadDashboardData() async {
    final usersSnap =
        await FirebaseFirestore.instance.collection('users').get();
    final eventsSnap =
        await FirebaseFirestore.instance.collection('events').get();

    setState(() {
      totalUsers = usersSnap.docs.length;

      pendingNgos =
          usersSnap.docs.where((doc) {
            final data = doc.data();
            final role = data['role'];
            final isVerified =
                data.containsKey('isVerified') ? data['isVerified'] : false;
            return role == 'NGO' && isVerified == false;
          }).length;

      activeEvents =
          eventsSnap.docs.where((doc) {
            final data = doc.data();
            return data.containsKey('isApproved') && data['isApproved'] == true;
          }).length;
    });
  }

  Future<Map<String, int>> fetchMonthlyApprovedEvents() async {
    final eventsSnap =
        await FirebaseFirestore.instance
            .collection('events')
            .where('isApproved', isEqualTo: true)
            .get();

    final Map<String, int> monthlyCounts = {};

    for (var doc in eventsSnap.docs) {
      final data = doc.data();
      if (data['createdAt'] is Timestamp) {
        final date = (data['createdAt'] as Timestamp).toDate();
        final String month = DateFormat('MMM').format(date);
        monthlyCounts[month] = (monthlyCounts[month] ?? 0) + 1;
      }
    }

    return monthlyCounts;
  }

  Widget buildEventChart(Map<String, int> data) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final barData = months.map((month) => data[month] ?? 0).toList();

    return AspectRatio(
      aspectRatio: 1.6,
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 32),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      months[i],
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: List.generate(months.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: barData[i].toDouble(),
                  color: AdminDashboard.themeColor,
                  width: 14,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            );
          }),
        ),
      ),
    );
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
                  Icon(
                    Icons.admin_panel_settings,
                    size: 40,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Admin Panel',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
            _drawerItem(
              context,
              Icons.supervised_user_circle,
              'Manage Users',
              '/admin/manage-users',
            ),
            _drawerItem(
              context,
              Icons.verified_user,
              'Verify NGOs',
              '/admin/verify-ngos',
            ),
            _drawerItem(
              context,
              Icons.event,
              'Moderate Events',
              '/admin/manage-events',
            ),
            _drawerItem(
              context,
              Icons.analytics,
              'Analytics',
              '/admin/analytics',
            ),
            _drawerItem(context, Icons.settings, 'Settings', '/admin/settings'),
            const Divider(),
            _drawerItem(
              context,
              Icons.logout,
              'Logout',
              '/login',
              replace: true,
            ),
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
                SummaryCard(
                  label: 'Total Users',
                  count: totalUsers,
                  icon: Icons.people,
                ),
                SummaryCard(
                  label: 'Pending NGOs',
                  count: pendingNgos,
                  icon: Icons.hourglass_top,
                ),
                SummaryCard(
                  label: 'Approved Events',
                  count: activeEvents,
                  icon: Icons.event_available,
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              'Monthly Approved Events',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            monthlyEvents.isNotEmpty
                ? buildEventChart(monthlyEvents)
                : const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String label,
    String route, {
    bool replace = false,
  }) {
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
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
