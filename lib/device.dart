import 'package:firebase_database/firebase_database.dart';

class Device {
  String _id;
  String _name;
  String _email;
  String _age;
  String _mobile;

  Device(this._id, this._name, this._email, this._age, this._mobile);

  String get name => _name;

  String get email => _email;

  String get age => _age;

  String get mobile => _mobile;

  String get id => _id;

  Device.fromSnapshot(DataSnapshot snapshot) {
    _id = snapshot.key;
    _name = snapshot.value['NCL'];
    _email = snapshot.value['ND'];
    _age = snapshot.value['NO'];
    _mobile = snapshot.value['name'];
  }
}
