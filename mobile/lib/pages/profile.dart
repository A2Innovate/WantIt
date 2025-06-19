import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? profileImageUrl;
  String? userName;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Suppose you saved these keys during login:
      userName = prefs.getString('name') ?? 'No Name';
      // If you have a profile image URL saved, load it, else null
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              child: Text(
                (userName?.isNotEmpty ?? false)
                    ? userName![0].toUpperCase()
                    : '?',
                style: const TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              userName ?? '',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
