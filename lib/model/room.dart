import 'package:floor/floor.dart';

@entity
class Room {
  @primaryKey
  @ColumnInfo(name: 'tenphong', nullable: false)
  final String name;
  @ColumnInfo(name: 'maphong', nullable: false)
  final String id;
  @ColumnInfo(name: 'slthietbi', nullable: false)
  final String numberOfDevices;
  @ColumnInfo(name: 'isEnable', nullable: false)
  bool isEnable;

  Room(this.name, this.id, this.numberOfDevices, this.isEnable);

// Room.fromJson(Map<String, dynamic> json)
//     : email = json['email'],
//       pass = json['pass'],
//       ten = json['ten'],
//       sdt = json['sdt'],
//       nha = json['nha'],
//       mac = json['mac'];
//
// Map<String, dynamic> toJson() => {
//   'email': email,
//   'pass': pass,
//   'ten': ten,
//   'sdt': sdt,
//   'nha': nha,
//   'mac': mac,
// };
}
