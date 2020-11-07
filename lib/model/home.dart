import 'package:floor/floor.dart';

@entity
class Home {
  @primaryKey
  String _id;
  @ColumnInfo(name: 'iduser', nullable: false)
  String iduser;
  @ColumnInfo(name: 'tennha', nullable: false)
  String tennha;
  @ColumnInfo(name: 'manha', nullable: false)
  String manha;
  @ColumnInfo(name: 'mac', nullable: false)
  String mac;
  @ColumnInfo(name: 'idnha', nullable: false)
  String idnha;
  bool isEnable = false;

  String get id => idnha;

  set id(String id) {
    this._id = id;
    this.idnha = id;
  }

  Home(this._id, this.iduser, this.tennha, this.manha, this.mac);

  String toString() {
    return '$_id - $iduser - $tennha - $manha - $mac';
  }

  Home.fromJson(Map<String, dynamic> json)
      : _id = json['_id'],
        iduser = json['iduser'],
        tennha = json['tennha'],
        manha = json['manha'],
        idnha = json['idnha'],
        mac = json['mac'];

  Map<String, dynamic> toJson() => {
        'id': _id,
        'iduser': iduser,
        'tennha': tennha,
        'manha': manha,
        'mac': mac,
        'idnha': idnha
      };
}
