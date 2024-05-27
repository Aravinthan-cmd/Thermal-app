import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:thermal/pages/graph.dart';
import 'package:thermal/theme/theme_provider.dart';

import 'pages/home.dart';
import 'pages/report.dart';
import 'pages/settings.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).currentThemeData,
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    const Home(),
    const Graph(),
    const Report(),
    const Settings(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15),
        child: GNav(
          // backgroundColor: Theme.of(context).colorScheme.shadow,
          activeColor: Theme.of(context).colorScheme.tertiary,
          iconSize: 20,
          color: Theme.of(context).colorScheme.shadow,
          tabBackgroundColor: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          gap: 15,
          tabs: const [
            GButton(
              icon: Icons.home,
              text: 'Dashboard',
            ),
            GButton(
              icon: Icons.add_chart_outlined,
              text: 'Graph',
            ),
            GButton(
              icon: Icons.adf_scanner,
              text: 'Report',
            ),
            GButton(
              icon: Icons.settings,
              text: 'Settings',
            ),
          ],
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}
