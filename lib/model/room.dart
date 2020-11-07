import 'package:floor/floor.dart';

@entity
class Room {
  @primaryKey
  String _id;
  @ColumnInfo(name: 'iduser', nullable: false)
  String iduser;
  @ColumnInfo(name: 'tenphong', nullable: false)
  final String tenphong;
  @ColumnInfo(name: 'maphong', nullable: false)
  final String maphong;
  @ColumnInfo(name: 'isEnable', nullable: false)
  bool isEnable;
  @ColumnInfo(name: 'mac', nullable: false)
  String mac;

  Room(this._id, this.iduser, this.tenphong, this.maphong, this.mac);

  Room.fromJson(Map<String, dynamic> json)
      : _id = json['_id'],
        iduser = json['iduser'],
        tenphong = json['tenphong'],
        maphong = json['maphong'],
        mac = json['mac'];

  Map<String, dynamic> toJson() => {
        'id': _id,
        'iduser': iduser,
        'tenphong': tenphong,
        'maphong': maphong,
        'mac': mac
      };
}
