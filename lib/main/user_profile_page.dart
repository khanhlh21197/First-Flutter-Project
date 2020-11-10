import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_first_flutter_project/helper/mqttClientWrapper.dart';
import 'package:my_first_flutter_project/helper/shared_prefs_helper.dart';
import 'package:my_first_flutter_project/model/home.dart';
import 'package:my_first_flutter_project/model/user.dart';
import 'package:my_first_flutter_project/response/user_response.dart';

import '../helper/constants.dart' as Constants;

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  MQTTClientWrapper mqttClientWrapper;
  SharedPrefsHelper sharedPrefsHelper;
  User user;

  @override
  void initState() {
    sharedPrefsHelper = SharedPrefsHelper();
    initMqtt();
    super.initState();
  }

  Future<void> initMqtt() async {
    String iduser = await sharedPrefsHelper.getStringValuesSF('iduser');
    Home h = Home('', iduser, '', '', Constants.mac);

    mqttClientWrapper =
        MQTTClientWrapper(() => print('Success'), (message) => handle(message));
    await mqttClientWrapper.prepareMqttClient(Constants.mac);

    mqttClientWrapper.publishMessage('getinfouser', jsonEncode(h));
  }

  Widget _placeContainer(String title, Color color, Widget icon) {
    return Column(
      children: <Widget>[
        Container(
            height: 60,
            width: MediaQuery.of(context).size.width - 40,
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15), color: color),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
                icon != null ? icon : Spacer(),
              ],
            ))
      ],
    );
  }

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            // Text('Back',
            //     style: TextStyle(
            //         fontSize: 16,
            //         fontWeight: FontWeight.w500,
            //         color: Colors.white))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        Positioned(top: 40, left: 0, child: _backButton()),
        SingleChildScrollView(
          child: Container(
            color: Color(0xffe7eaf2),
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(40.0, 40, 40, 70),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                CircleAvatar(
                    backgroundColor: Colors.brown.shade800,
                    minRadius: 50,
                    child: Text(
                      'Khanh Le'[0],
                      style: TextStyle(fontSize: 40),
                    )),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Khanh Le',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 15,
                ),
                _placeContainer(
                    user.email != null ? 'Email: ${user.email}' : 'Email: ',
                    Color(0xff526fff),
                    null),
                _placeContainer(
                    user.ten != null ? 'Tên: ${user.ten}' : 'Chưa nhập tên',
                    Color(0xff8f48ff),
                    null),
                _placeContainer(
                    user.nha != null
                        ? 'Địa chỉ: ${user.nha}'
                        : 'Chưa nhập địa chỉ',
                    Color(0xff8f48ff),
                    null),
                _placeContainer(
                    user.sdt != null ? 'SĐT: ${user.sdt}' : 'Chưa nhập SĐT',
                    Color(0xff8f48ff),
                    null),
                _placeContainer(
                    'Thêm tài khoản', Color(0xffffffff), Icon(Icons.add)),
                _placeContainer(
                    'Đăng xuất',
                    Color(0xffffffff),
                    Icon(
                      Icons.power_settings_new,
                      color: Colors.red,
                    )),
              ],
            ),
          ),
        )
      ],
    ));
  }

  handle(String message) {
    String json =
        '{"errorCode":"0","message":"","id":"{"_id":"5fa65ea3ab3edc4949a831d8","email":"techno","pass":"techno123","ten":"TECHNO","sdt":"0999999999","nha":"TSQ"}","result":"true"}';
    String json2 =
        '{"errorCode":"0","message":"5faa008f761fc3b861b37b01","id":[{"_id":"5faa009b761fc3b861b37b05","matb":"IVNR1000001","tentb":"GIUONG 1","trangthai":"0"}],"result":"true"}';
    Map decode = jsonDecode(message);
    print('Decode: $decode');
    // Map responseMap = jsonDecode(message);
    UserResponse response = UserResponse.fromJson(jsonDecode(message));
    //
    print('Response: ${response.id}');
    setState(() {
      user = User.fromJson(response.id);
    });
    print(user.toString());
  }
}
