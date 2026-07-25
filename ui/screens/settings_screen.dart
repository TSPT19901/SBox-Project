import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'landing_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool autoLock = true;

  String get userEmail {
    return FirebaseAuth.instance.currentUser?.email ?? 'No email';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Space',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        children: [
          _title('PROFILE'),
          _tile(Icons.email_outlined, 'Email', userEmail),
          // _tile(Icons.phone_outlined, 'Phone number', '+855 12 345 678'),
          _title('PRIVACY'),
          _tile(
            Icons.lock_outline,
            'Change password',
            null,
            trailing: const Icon(Icons.chevron_right),
          ),
          _tile(
            Icons.timer_outlined,
            'Auto lock',
            'After 15 minutes',
            trailing: Switch(
              value: autoLock,
              onChanged: (v) => setState(() => autoLock = v),
            ),
          ),
          _title('STORAGE'),
          _tile(
            Icons.download_outlined,
            'Download all photos',
            null,
            trailing: const Icon(Icons.chevron_right),
          ),
          _tile(
            Icons.delete_sweep_outlined,
            'Remove all photos',
            null,
            color: Colors.red,
            trailing: const Icon(Icons.chevron_right, color: Colors.red),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LandingScreen()),
                  (route) => false,
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6750E8),
                side: const BorderSide(color: Color(0xFF6750E8), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Log out',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF777789),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _tile(
    IconData icon,
    String title,
    String? subtitle, {
    Widget? trailing,
    Color color = const Color(0xFF1E1E2D),
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: color == Colors.red ? Colors.red : Color(0xFF6750E8),
        ),
        title: Text(
          title,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
        subtitle: subtitle == null ? null : Text(subtitle),
        trailing: trailing,
      ),
    );
  }
}
