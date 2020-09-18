import 'package:floor/floor.dart';
import 'package:my_first_flutter_project/model/device.dart';

@dao
abstract class DeviceDao {
  @Query('SELECT * FROM device')
  Future<List<Device>> getAllDevices();

  @Query('DELETE FROM device')
  Future<void> deleteAllDevices();

  @insert
  Future<void> insertDevice(Device device);

  @insert
  Future<void> insertAllDevices(List<Device> devices) async {
    await deleteAllDevices();
    devices.forEach((element) {
      insertDevice(element);
    });
  }
}
