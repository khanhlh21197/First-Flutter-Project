import 'package:floor/floor.dart';

@entity
class Department {
  @primaryKey
  @ColumnInfo(name: 'tenkhoa', nullable: false)
  final String name;
  @ColumnInfo(name: 'makhoa', nullable: false)
  final String id;
  @ColumnInfo(name: 'slphong', nullable: false)
  final String numberOfRooms;
  @ColumnInfo(name: 'isEnable', nullable: false)
  bool isEnable;

  Department(this.name, this.id, this.numberOfRooms, this.isEnable);

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
