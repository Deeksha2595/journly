import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:journly/controllers/theme_controller.dart';

class ThemeSetting extends StatefulWidget {
  final String name;
  final String email;

  const ThemeSetting({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  State<ThemeSetting> createState() => _ThemeSettingState();
}

class _ThemeSettingState extends State<ThemeSetting> {
  static const String _notificationKey = 'notifications_enabled';

  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool(_notificationKey) ?? true;

    if (!mounted) return;

    setState(() {
      _notificationsEnabled = value;
    });
  }

  Future<void> _changeNotificationPreference(bool value) async {
    setState(() {
      _notificationsEnabled = value;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationKey, value);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value ? 'Notifications enabled' : 'Notifications disabled',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            leading: const BackButton(color: Colors.white),
            backgroundColor: const Color.fromARGB(255, 102, 140, 84),
            title: const Text(
              'Settings',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(8),
            children: [
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text(
                  'Dark Mode',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Use a darker appearance for night-time viewing',
                ),
                value: ThemeController.instance.isDarkMode,
                onChanged: ThemeController.instance.setDarkMode,
                secondary: const Icon(
                  Icons.dark_mode,
                  color: Colors.green,
                ),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text(
                  'Notifications',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Enable or disable application notifications',
                ),
                value: _notificationsEnabled,
                onChanged: _changeNotificationPreference,
                secondary: const Icon(
                  Icons.notifications,
                  color: Colors.green,
                ),
              ),
              const Divider(),
              _settingsTile(
                icon: Icons.account_circle,
                title: 'Account Settings',
                subtitle: 'View your account information',
                onTap: _showAccountSettingsDialog,
              ),
              const Divider(),
              _settingsTile(
                icon: Icons.lock,
                title: 'Privacy Settings',
                subtitle: 'View privacy information',
                onTap: _showPrivacySettingsDialog,
              ),
              const Divider(),
              _settingsTile(
                icon: Icons.help,
                title: 'Help',
                subtitle: 'Find solutions to common issues',
                onTap: _showHelpDialog,
              ),
              const Divider(),
              _settingsTile(
                icon: Icons.support_agent_outlined,
                title: 'Support',
                subtitle: 'Contact us for assistance',
                onTap: _showSupportDialog,
              ),
              const Divider(),
            ],
          ),
        );
      },
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 18,
        color: Colors.green,
      ),
      onTap: onTap,
    );
  }

  void _showAccountSettingsDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Account Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${widget.name}'),
              const SizedBox(height: 8),
              Text('Email: ${widget.email}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacySettingsDialog() {
    _showInformationDialog(
      title: 'Privacy Settings',
      message:
          'Your journal entries are stored locally on this device. Keep your device protected to prevent unauthorised access.',
    );
  }

  void _showHelpDialog() {
    _showInformationDialog(
      title: 'Help',
      message:
          'Use Journals to record your thoughts, Mood Tracker to monitor your mood, and Settings to customise the application.',
    );
  }

  void _showSupportDialog() {
    _showInformationDialog(
      title: 'Support',
      message:
          'If you experience a problem, restart the application and check your internet connection. Contact the Journly team if the issue continues.',
    );
  }

  void _showInformationDialog({
    required String title,
    required String message,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
