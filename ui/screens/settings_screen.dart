import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'landing_screen.dart';
import '../../data/repository/image_repo.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool autoLock = true;
  final ImageRepo imageRepo = ImageRepo();
  bool _isRemovingPhotos = false;

  String get userEmail {
    return FirebaseAuth.instance.currentUser?.email ?? 'No email';
  }

  Future<void> _removeAllPhotos() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remove all photos?'),
          content: const Text(
            'All photos in your private vault will be permanently removed. '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Remove all'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    setState(() {
      _isRemovingPhotos = true;
    });

    try {
      await imageRepo.deleteAllPhotos();

      if (!mounted) return;

      setState(() {
        _isRemovingPhotos = false;
      });

      await showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Photos removed'),
            content: const Text(
              'All photos have been removed from your vault.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      // Return true to tell HomeScreen that its photo list changed.
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isRemovingPhotos = false;
      });

      showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Unable to remove photos'),
            content: const Text('Something went wrong. Please try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      debugPrint('Remove all photos error: $e');
    }
  }

  Future<void> _changePassword() async {
    final email = FirebaseAuth.instance.currentUser?.email;

    if (email == null) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Email not found'),
            content: const Text('There is no logged-in user email.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      return;
    }

    // Ask the user before sending the email.
    final shouldSend = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change password'),
          content: Text('Send a password reset link to:\n\n$email'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );

    if (shouldSend != true) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Email sent'),
            content: Text(
              'A password reset link was sent to:\n\n$email\n\n'
              'Please check your inbox and spam folder.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Unable to send email'),
            content: Text(e.message ?? 'An unknown Firebase error occurred.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Something went wrong. Please try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
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
          _title('PRIVACY'),
          _tile(
            Icons.lock_outline,
            'Change password',
            null,
            onTap: _changePassword,
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
            Icons.delete_sweep_outlined,
            'Remove all photos',
            _isRemovingPhotos ? 'Removing photos...' : null,
            color: Colors.red,
            onTap: _isRemovingPhotos ? null : _removeAllPhotos,
            trailing: _isRemovingPhotos
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.red,
                    ),
                  )
                : const Icon(Icons.chevron_right, color: Colors.red),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();

                if (!mounted) return;

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
    VoidCallback? onTap,
    Color color = const Color(0xFF1E1E2D),
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        onTap: onTap,
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
