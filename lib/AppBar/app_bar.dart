// lib/widgets/app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:recipe_book/database/database_helper.dart';
import 'package:recipe_book/pages/home_page.dart';
import 'package:recipe_book/providers/theme_provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final Function(String)? onLanguageChanged;
  final int? currentRecipeId;
  final int? currentUserId;
  final Function(int?, int, bool)? onFavoriteToggle;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.onLanguageChanged,
    this.currentRecipeId,
    this.currentUserId,
    this.onFavoriteToggle,
  }) : super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class _CustomAppBarState extends State<CustomAppBar> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  @override
  void didUpdateWidget(CustomAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRecipeId != widget.currentRecipeId ||
        oldWidget.currentUserId != widget.currentUserId) {
      _checkFavoriteStatus();
    }
  }

  Future<void> _checkFavoriteStatus() async {
    if (widget.currentRecipeId != null && widget.currentUserId != null) {
      try {
        bool isFavorite = await _dbHelper.isRecipeFavorite(
          widget.currentRecipeId!,
          {'id': widget.currentRecipeId!}, 
        );
        if (mounted) {
          setState(() {
            _isFavorite = isFavorite;
          });
        }
      } catch (e) {
        print('Error checking favorite status: $e');
        if (mounted) {
          setState(() {
            _isFavorite = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isFavorite = false;
        });
      }
    }
  }

  void _toggleFavorite() async {
    if (widget.currentRecipeId == null) {
      print("Recipe ID is null, cannot toggle favorite.");
      return;
    }

    final recipe = await _dbHelper.getRecipe(widget.currentRecipeId!);
    if (recipe == null) {
      print("Recipe not found, cannot toggle favorite.");
      return;
    }

    bool newFavoriteStatus = !_isFavorite;
    try {
      if (newFavoriteStatus) {
        await _dbHelper.addFavorite(
          widget.currentRecipeId!,
          recipe,
        );
      } else {
        await _dbHelper.removeFavorite(
          widget.currentRecipeId!,
          recipe,
        );
      }
      
      if (mounted) {
        setState(() {
          _isFavorite = newFavoriteStatus;
        });
      }
      
      if (widget.onFavoriteToggle != null) {
        widget.onFavoriteToggle!(widget.currentUserId, widget.currentRecipeId!, newFavoriteStatus);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating favorite: $e')),
      );
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Required'),
          content: const Text('Please log in to add favorites.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Login'),
            ),
          ],
        );
      },
    );
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Share Recipe',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Copy Link'),
                onTap: () async {
                  if (widget.currentRecipeId != null) {
                    String link = 'https://recipe-app.com/recipe/${widget.currentRecipeId}';
                    await Clipboard.setData(ClipboardData(text: link));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copied to clipboard!')),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('English'),
                value: 'en',
                groupValue: 'en',
                onChanged: (value) {
                  if (widget.onLanguageChanged != null) {
                    widget.onLanguageChanged!('en');
                  }
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('العربية'),
                value: 'ar',
                groupValue: 'en',
                onChanged: (value) {
                  if (widget.onLanguageChanged != null) {
                    widget.onLanguageChanged!('ar');
                  }
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Français'),
                value: 'fr',
                groupValue: 'en',
                onChanged: (value) {
                  if (widget.onLanguageChanged != null) {
                    widget.onLanguageChanged!('fr');
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      backgroundColor: theme.appBarTheme.backgroundColor,
      elevation: 0,
      title: Text(
        widget.title,
        style: theme.appBarTheme.titleTextStyle,
      ),
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: Icon(
              Icons.menu,
              color: theme.appBarTheme.iconTheme?.color,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          );
        },
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.home,
            color: theme.appBarTheme.iconTheme?.color,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DashboardPage()),
            );
          },
        ),
        
        IconButton(
          icon: Icon(
            Icons.language,
            color: theme.appBarTheme.iconTheme?.color,
          ),
          onPressed: _showLanguageDialog,
        ),
        
        if (widget.currentRecipeId != null)
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : theme.appBarTheme.iconTheme?.color,
            ),
            onPressed: _toggleFavorite,
            tooltip: 'Toggle Favorite',
          ),
        
        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode,
            color: theme.appBarTheme.iconTheme?.color,
          ),
          onPressed: () {
            themeProvider.toggleTheme();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  themeProvider.isDarkMode 
                      ? 'Switched to Dark Mode' 
                      : 'Switched to Light Mode'
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          tooltip: isDark ? 'Light Mode' : 'Dark Mode',
        ),
      ],
    );
  }
}