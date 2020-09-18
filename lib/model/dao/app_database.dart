import 'package:floor/floor.dart';
import 'package:my_first_flutter_project/model/dao/user_dao.dart';
import 'package:my_first_flutter_project/model/device.dart';
import 'package:my_first_flutter_project/model/user.dart';

import 'device_dao.dart';

@Database(version: 1, entities: [User, Device])
abstract class AppDatabase extends FloorDatabase {
  UserDao get userDao;

  DeviceDao get deviceDao;
}
