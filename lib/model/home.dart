import 'dart:convert';

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

  String get tennhaDecode {
    try {
      String s = tennha;
      List<int> ints = List();
      s = s.replaceAll('[', '');
      s = s.replaceAll(']', '');
      List<String> strings = s.split(',');
      for (int i = 0; i < strings.length; i++) {
        ints.add(int.parse(strings[i]));
      }
      return utf8.decode(ints);
    } catch (e) {
      return tennha;
    }
  }

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
