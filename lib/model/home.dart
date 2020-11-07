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
  bool isEnable = false;

  String get id => _id;

  Home(this._id, this.iduser, this.tennha, this.manha, this.mac);

  String toString() {
    return '$_id - $iduser - $tennha - $manha - $mac';
  }

  Home.fromJson(Map<String, dynamic> json)
      : _id = json['_id'],
        iduser = json['iduser'],
        tennha = json['tennha'],
        manha = json['manha'],
        mac = json['mac'];

  Map<String, dynamic> toJson() => {
        'id': _id,
        'iduser': iduser,
        'tennha': tennha,
        'manha': manha,
        'mac': mac
      };
}
