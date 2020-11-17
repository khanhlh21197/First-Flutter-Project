import 'dart:convert';

import 'package:floor/floor.dart';

@entity
class Room {
  @primaryKey
  String _id;
  @ColumnInfo(name: 'iduser', nullable: false)
  String iduser;
  @ColumnInfo(name: 'idnha', nullable: false)
  String idnha;
  @ColumnInfo(name: 'idphong', nullable: false)
  String idphong;
  @ColumnInfo(name: 'tenphong', nullable: false)
  String tenphong;
  @ColumnInfo(name: 'maphong', nullable: false)
  String maphong;
  @ColumnInfo(name: 'mac', nullable: false)
  String mac;

  String get tenphongDecode {
    try {
      String s = tenphong;
      List<int> ints = List();
      s = s.replaceAll('[', '');
      s = s.replaceAll(']', '');
      List<String> strings = s.split(',');
      for (int i = 0; i < strings.length; i++) {
        ints.add(int.parse(strings[i]));
      }
      print('Ten phong: $tenphongDecode');
      return utf8.decode(ints);
    } catch (e) {
      return tenphong;
    }
  }

  String get id => idphong;

  set id(String id) {
    this._id = id;
    this.idphong = id;
  }

  Room(
      this._id, this.iduser, this.idnha, this.tenphong, this.maphong, this.mac);

  Room.fromJson(Map<String, dynamic> json)
      : _id = json['_id'],
        iduser = json['iduser'],
        idnha = json['idnha'],
        idphong = json['idphong'],
        tenphong = json['tenphong'],
        maphong = json['maphong'],
        mac = json['mac'];

  Map<String, dynamic> toJson() => {
        'id': _id,
        'iduser': iduser,
        'idnha': idnha,
        'idphong': idphong,
        'tenphong': tenphong,
        'maphong': maphong,
        'mac': mac
      };
}
