import 'package:floor/floor.dart';

@entity
class Device {
  @primaryKey
  String _id;
  @ColumnInfo(name: 'iduser', nullable: false)
  String iduser;
  @ColumnInfo(name: 'tenthietbi', nullable: false)
  String tenthietbi;
  @ColumnInfo(name: 'mathietbi', nullable: false)
  String mathietbi;
  @ColumnInfo(name: 'trangthai', nullable: false)
  String trangthai;
  @ColumnInfo(name: 'mac', nullable: false)
  String mac;
  @ColumnInfo(name: 'nhietdo', nullable: false)
  String nhietdo;
  bool isEnable = false;

  String get id => _id;

  Device(this._id, this.iduser, this.tenthietbi, this.mathietbi, this.trangthai,
      this.mac);

  String toString() {
    return '$_id - $iduser - $tenthietbi - $mathietbi - $trangthai - $mac';
  }

  Device.fromJson(Map<String, dynamic> json)
      : _id = json['_id'],
        iduser = json['iduser'],
        tenthietbi = json['tenthietbi'],
        mathietbi = json['mathietbi'],
        trangthai = json['trangthai'],
        mac = json['mac'];

  Map<String, dynamic> toJson() => {
        'id': _id,
        'iduser': iduser,
        'tenthietbi': tenthietbi,
        'mathietbi': mathietbi,
        'status': trangthai,
        'mac': mac
      };
}
