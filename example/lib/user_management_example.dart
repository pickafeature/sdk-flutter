import 'package:flutter/material.dart';
import 'package:pickafeature/pickafeature.dart';

/// Optional example: identify the current user so feedback submissions are
/// attributed to their email in the dashboard. Call after sign-in, call
/// [PickAFeature.clearUserData] on sign-out.
class UserManagementExample extends StatefulWidget {
  const UserManagementExample({super.key});

  @override
  State<UserManagementExample> createState() => _UserManagementExampleState();
}

class _UserManagementExampleState extends State<UserManagementExample> {
  PickAFeatureUser? _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    setState(() => _isLoading = true);
    try {
      final user = await PickAFeature.getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateUserInfo() async {
    await PickAFeature.updateUser(
      email: 'user@example.com',
      name: 'John Doe',
    );
    await _loadCurrentUser();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User information updated')),
      );
    }
  }

  Future<void> _clearUserData() async {
    await PickAFeature.clearUserData();
    await _loadCurrentUser();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User data cleared')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User identity')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current user',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_currentUser == null)
                      const Text('Anonymous (no identity set)')
                    else ...[
                      _row('Email', _currentUser!.email ?? '-'),
                      _row('Name', _currentUser!.name ?? '-'),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _updateUserInfo,
              child: const Text('Identify as test user'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _clearUserData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear identity'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
