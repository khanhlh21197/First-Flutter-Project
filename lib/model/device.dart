import 'package:floor/floor.dart';

@entity
class Device {
  @primaryKey
  String _id;
  @ColumnInfo(name: 'iduser', nullable: false)
  String iduser;
  @ColumnInfo(name: 'idnha', nullable: false)
  String idnha;
  @ColumnInfo(name: 'idphong', nullable: false)
  String idphong;
  @ColumnInfo(name: 'tentb', nullable: false)
  String tentb;
  @ColumnInfo(name: 'matb', nullable: false)
  String matb;
  @ColumnInfo(name: 'loaitb', nullable: false)
  String loaitb;
  @ColumnInfo(name: 'trangthai', nullable: false)
  String trangthai;
  @ColumnInfo(name: 'mac', nullable: false)
  String mac;
  @ColumnInfo(name: 'nhietdo', nullable: false)
  String nhietdo;
  bool isEnable = false;

  String get id => _id;

  set id(String id) {
    this._id = id;
  }

  Device(this._id, this.iduser, this.idnha, this.idphong, this.tentb, this.matb,
      this.loaitb, this.trangthai, this.mac);

  String toString() {
    return '$_id - $idphong - $tentb - $matb - $trangthai - $mac';
  }

  Device.fromJson(Map<String, dynamic> json)
      : _id = json['_id'],
        iduser = json['iduser'],
        idnha = json['idnha'],
        idphong = json['idphong'],
        tentb = json['tentb'],
        matb = json['matb'],
        loaitb = json['loaitb'],
        trangthai = json['trangthai'],
        mac = json['mac'];

  Map<String, dynamic> toJson() => {
        'id': _id,
        'iduser': iduser,
        'idnha': idnha,
        'idphong': idphong,
        'tentb': tentb,
        'matb': matb,
        'loaitb': loaitb,
        'status': trangthai,
        'mac': mac
      };
}
