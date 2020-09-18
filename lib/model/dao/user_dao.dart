import 'package:floor/floor.dart';

import '../user.dart';

@dao
abstract class UserDao {
  @Query('SELECT * FROM user')
  Future<List<User>> getAllUsers();

  @insert
  Future<void> insertUser(User user);
}
