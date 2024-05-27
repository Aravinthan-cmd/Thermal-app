import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Text('Settings', style: TextStyle(fontWeight: FontWeight.w300, fontSize: 30, color: Theme.of(context).colorScheme.tertiary),),
          ],
        ),
      ),
    );
  }
}
