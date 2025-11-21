// lib/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:recipe_book/AppBar/app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _receiveEmails = false;
  bool _whatToCookToday = false;
  bool _notifyNewBlogs = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _receiveEmails = prefs.getBool('receiveEmails') ?? false;
      _whatToCookToday = prefs.getBool('whatToCookToday') ?? false;
      _notifyNewBlogs = prefs.getBool('notifyNewBlogs') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    
    // Show confirmation snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Settings updated successfully'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Settings',
        onLanguageChanged: (languageCode) {
          print('Language changed to: $languageCode');
        },
        onFavoriteToggle: (userId, recipeId, isFavorite) {
          print('Favorite updated: $recipeId = $isFavorite');
        },
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notifications & Features',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: Text('Receive Emails for New Recipes'),
                          subtitle: Text('Get email notifications when new recipes are added'),
                          value: _receiveEmails,
                          onChanged: (value) {
                            setState(() {
                              _receiveEmails = value;
                            });
                            _saveSettings('receiveEmails', value);
                          },
                          activeColor: Colors.blue,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        Divider(height: 1),
                        SwitchListTile(
                          title: Text('What to Cook Today'),
                          subtitle: Text('Get daily suggestions for what to cook'),
                          value: _whatToCookToday,
                          onChanged: (value) {
                            setState(() {
                              _whatToCookToday = value;
                            });
                            _saveSettings('whatToCookToday', value);
                          },
                          activeColor: Colors.blue,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        Divider(height: 1),
                        SwitchListTile(
                          title: Text('Get Notify for New Blogs'),
                          subtitle: Text('Receive notifications about new blog posts'),
                          value: _notifyNewBlogs,
                          onChanged: (value) {
                            setState(() {
                              _notifyNewBlogs = value;
                            });
                            _saveSettings('notifyNewBlogs', value);
                          },
                          activeColor: Colors.blue,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Additional Settings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text('Theme'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.brightness_5, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Light'),
                        ],
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Theme setting is managed from the app bar'),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 12),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text('Language'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('English'),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Language setting is managed from the app bar'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}