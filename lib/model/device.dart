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

  String get id => _id;

  Device(
      this._id, this.iduser, this.tenthietbi, this.mathietbi, this.trangthai);

  Device.fromJson(Map<String, dynamic> json)
      : _id = json['_id'],
        iduser = json['iduser'],
        tenthietbi = json['tenthietbi'],
        mathietbi = json['mathietbi'],
        trangthai = json['trangthai'];

  Map<String, dynamic> toJson() => {
        'id': _id,
        'iduser': iduser,
        'tenthietbi': tenthietbi,
        'mathietbi': mathietbi,
        'status': trangthai
      };
}
