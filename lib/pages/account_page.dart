// lib/pages/account_page.dart
import 'package:flutter/material.dart';
import 'package:recipe_book/AppBar/app_bar.dart';
import 'package:recipe_book/css/app_theme.dart';
import 'package:recipe_book/database/database_helper.dart';
import 'package:recipe_book/pages/admin_page.dart'; // Import AdminPage
import 'package:shared_preferences/shared_preferences.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isSignedIn = false;
  bool _isCreatingAccount = true; // Toggle between create account and sign in
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Check if user is already logged in
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final isAdmin = prefs.getBool('isAdmin') ?? false;

    if (isLoggedIn) {
      setState(() {
        _isSignedIn = true;
        _isAdmin = isAdmin;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TEMPORARY: Using hardcoded strings instead of localization
    String createAccountText = 'Create Account';
    String signInText = 'Sign In';
    String fullNameText = 'Full Name';
    String phoneNumberText = 'Phone Number';
    String emailText = 'Email';
    String passwordText = 'Password';
    String nameRequiredText = 'Please enter your name';
    String invalidPhoneText = 'Please enter a valid Lebanese phone number';
    String emailRequiredText = 'Please enter your email';
    String invalidEmailText = 'Please enter a valid email address';
    String passwordRequiredText = 'Please enter your password';
    String passwordTooShortText = 'Password must be at least 8 characters';
    String createAccountButtonText = 'Create Account';
    String signInButtonText = 'Sign In';
    String signedInText = 'Signed In';
    String logoutText = 'Logout';
    String signedOutText = 'You have been signed out';
    String accountCreatedText = 'Account created successfully!';
    String signInSuccessText = 'Sign in successful!';
    String invalidCredentialsText = 'Invalid email or password';
    String errorAddingAccountText = 'Error adding account';
    String adminPanelText = 'Admin Panel'; // Text for admin button

    return Scaffold(
      appBar: CustomAppBar(
        title: _isCreatingAccount ? createAccountText : signInText,
        onLanguageChanged: (languageCode) {
          print('Language changed to: $languageCode');
        },
        onFavoriteToggle: (userId, recipeId, isFavorite) {
          print('Favorite updated: $recipeId = $isFavorite');
        },
      ),
      backgroundColor: AppTheme.lightBeige, // Light cream background
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth * 0.04,
              vertical: constraints.maxWidth * 0.02,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Centered Image
                Padding(
                  padding: EdgeInsets.only(bottom: constraints.maxWidth * 0.04),
                  child: Container(
                    width: constraints.maxWidth * 0.6,
                    height: constraints.maxWidth * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        'assets/images/Account.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: constraints.maxWidth * 0.3,
                            color: AppTheme.primaryGreen,
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Toggle between Create Account and Sign In
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isCreatingAccount = true;
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: _isCreatingAccount
                            ? AppTheme.primaryGreen
                            : Colors.grey[200],
                      ),
                      child: Text(
                        createAccountText,
                        style: TextStyle(
                          color: _isCreatingAccount ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isCreatingAccount = false;
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: !_isCreatingAccount
                            ? AppTheme.primaryGreen
                            : Colors.grey[200],
                      ),
                      child: Text(
                        signInText,
                        style: TextStyle(
                          color: !_isCreatingAccount ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (_isCreatingAccount) ...[
                        // Full Name Field (Only for create account)
                        TextFormField(
                          controller: _fullNameController,
                          decoration: InputDecoration(
                            labelText: fullNameText,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return nameRequiredText;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Phone Number Field (Optional)
                        TextFormField(
                          controller: _phoneNumberController,
                          decoration: InputDecoration(
                            labelText: phoneNumberText,
                            hintText: '+961 XXX XXXXX',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (!value.startsWith('+961') && !value.startsWith('00961')) {
                                return invalidPhoneText;
                              }
                              if (value.length < 12) {
                                return invalidPhoneText;
                              }
                            }
                            return null; // Optional field, so no validation required if empty
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Email Field (Required)
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: emailText,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return emailRequiredText;
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return invalidEmailText;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Field (8 characters minimum, Required)
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: passwordText,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return passwordRequiredText;
                          }
                          if (value.length < 8) {
                            return passwordTooShortText;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Create Account / Sign In Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _isCreatingAccount ? _createAccount : _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                _isCreatingAccount
                                    ? createAccountButtonText
                                    : signInButtonText,
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),
                      ),

                      // Admin Panel Button - Only show if signed in and is admin
                      if (_isSignedIn && _isAdmin) ...[
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AdminPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            adminPanelText,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],

                      // Sign In Status
                      if (_isSignedIn)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                signedInText,
                                style: const TextStyle(color: AppTheme.darkText),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: _signOut,
                                child: Text(
                                  logoutText,
                                  style: TextStyle(color: AppTheme.primaryGreen),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Add some bottom padding to prevent content from being hidden by FAB
                SizedBox(height: constraints.maxWidth * 0.2),
              ],
            ),
          );
        },
      ),
    );
  }

  // Create account method
  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user map with encrypted password
      Map<String, dynamic> user = {
        'fullName': _fullNameController.text,
        'phoneNumber': _phoneNumberController.text,
        'email': _emailController.text,
        'password': _passwordController.text, // In a real app, hash the password
      };

      // Insert user into database - this will return the new user's ID
      int userId = await DatabaseHelper.instance.insertUser(user);

      // Store the user ID in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', userId);

      // Mark user as signed in
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userEmail', user['email']);
      await prefs.setString('userFullName', user['fullName']);

      // Check if this is an admin account based on email
      bool isAdmin = user['email'] == 'rachaalhajhassan@gmail.com'; // Admin email check
      await prefs.setBool('isAdmin', isAdmin);

      setState(() {
        _isSignedIn = true;
        _isAdmin = isAdmin;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account created successfully!'),
        ),
      );

      // Clear form fields
      _fullNameController.clear();
      _phoneNumberController.clear();
      _emailController.clear();
      _passwordController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding account: $e'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Sign in method
  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final email = _emailController.text;
      final password = _passwordController.text;

      // Validate user credentials against database
      bool isValidUser = await DatabaseHelper.instance.validateUser(email, password);

      if (isValidUser) {
        // Get user details to retrieve the ID
        Map<String, dynamic>? user = await DatabaseHelper.instance.getUserByEmail(email);

        if (user != null) {
          // Store the user ID in SharedPreferences
          await prefs.setInt('userId', user['id']);

          // Mark user as signed in
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userEmail', email);
          await prefs.setString('userFullName', user['fullName']);

          // Check if this is an admin account based on email
          bool isAdmin = email == 'admin@gmail.com'; // Admin email check
          await prefs.setBool('isAdmin', isAdmin);

          setState(() {
            _isSignedIn = true;
            _isAdmin = isAdmin;
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sign in successful!'),
            ),
          );

          // Clear form fields
          _emailController.clear();
          _passwordController.clear();
        } else {
          throw Exception('Invalid credentials');
        }
      } else {
        throw Exception('Invalid credentials');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid email or password'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Sign out method
  Future<void> _signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userEmail');
    await prefs.remove('userFullName');
    await prefs.remove('userId'); // Remove userId on sign out
    await prefs.remove('isAdmin'); // Also remove admin status

    setState(() {
      _isSignedIn = false;
      _isAdmin = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You have been signed out'),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}