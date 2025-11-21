// import 'package:sqflite/sqflite.dart';

// class UserDao {
//   final Database db;

//   UserDao(this.db);

//   // User management methods
//   Future<int> insertUser(Map<String, dynamic> user) async {
//     user['createdAt'] = DateTime.now().toIso8601String();
//     user['updatedAt'] = DateTime.now().toIso8601String();
//     return await db.insert('users', user);
//   }

//   Future<Map<String, dynamic>?> getUserByEmail(String email) async {
//     final maps = await db.query(
//       'users',
//       where: 'email = ?',
//       whereArgs: [email],
//     );
//     return maps.isNotEmpty ? maps.first : null;
//   }

//   Future<Map<String, dynamic>?> getUserByPhoneNumber(String phoneNumber) async {
//     final maps = await db.query(
//       'users',
//       where: 'phoneNumber = ?',
//       whereArgs: [phoneNumber],
//     );
//     return maps.isNotEmpty ? maps.first : null;
//   }

//   Future<bool> validateUser(String email, String password) async {
//     final maps = await db.query(
//       'users',
//       where: 'email = ? AND password = ?',
//       // whereArgs: [email, password],
//     );
//     return maps.isNotEmpty;
//   }

//   Future<void> deleteUser(int userId) async {}

//   Future<List<Map<String, dynamic>>> getAllUsers() async {}

//   // If you keep user-specific favorites in the database (for potential sync later)
//   // Future<int> addFavorite(int userId, int recipeId) async { ... }
//   // Future<int> removeFavorite(int userId, int recipeId) async { ... }
//   // Future<List<Map<String, dynamic>>> getUserFavorites(int userId) async { ... }
//   // Future<bool> isRecipeFavorite(int userId, int recipeId) async { ... }
// }