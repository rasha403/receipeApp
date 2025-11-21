// lib/pages/users_list_page.dart
import 'package:flutter/material.dart';
import 'package:recipe_book/database/database_helper.dart';

class UsersListPage extends StatefulWidget {
  const UsersListPage({super.key});

  @override
  State<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await DatabaseHelper.instance.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading users: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users List'),
        backgroundColor: Colors.blue, // Changed color for non-admin page
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? const Center(child: Text('No users found.'))
              : RefreshIndicator(
                  onRefresh: _loadUsers,
                  child: ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(user['fullName'] ?? 'N/A'),
                          subtitle: Text(user['email'] ?? 'N/A'),
                          // Remove the delete button since this is now for general users
                          // trailing: IconButton(
                          //   icon: const Icon(Icons.delete, color: Colors.red),
                          //   onPressed: () {
                          //     // This functionality should remain restricted to admin
                          //   },
                          // ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}