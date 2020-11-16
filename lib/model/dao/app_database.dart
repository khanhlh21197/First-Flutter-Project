import 'package:floor/floor.dart';
import 'package:health_care/model/dao/user_dao.dart';
import 'package:health_care/model/device.dart';
import 'package:health_care/model/user.dart';

import 'device_dao.dart';

@Database(version: 1, entities: [User, Device])
abstract class AppDatabase extends FloorDatabase {
  UserDao get userDao;

  DeviceDao get deviceDao;
}
