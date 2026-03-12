import 'package:flutter/material.dart';

import 'projects_grouped_view.dart';
import 'users_analytics_view.dart';
import 'heat_view.dart';
import 'activity_dashboard_view.dart';
import 'monthly_heatmap_view.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _views = [
    const ProjectsGroupedView(),
    const UsersAnalyticsView(),
    const MonthlyHeatmapView(),
    const HeatView(),
    const ActivityDashboardView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _views[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed, // Ensure icons and labels show correctly for > 3 items
        selectedItemColor: const Color(0xFF7AA2F7),
        unselectedItemColor: const Color(0xFFA9B1D6),
        backgroundColor: const Color(0xFF1F2335), // Match app theme if not globally set
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_shared_outlined),
            activeIcon: Icon(Icons.folder_shared),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Team',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Heatmap',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_fire_department_outlined),
            activeIcon: Icon(Icons.local_fire_department),
            label: 'Activity Heat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Feed',
          ),
        ],
      ),
    );
  }
}

