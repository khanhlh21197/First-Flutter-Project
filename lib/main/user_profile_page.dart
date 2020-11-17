import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health_care/helper/models.dart';
import 'package:health_care/helper/mqttClientWrapper.dart';
import 'package:health_care/helper/shared_prefs_helper.dart';
import 'package:health_care/login/login_page.dart';
import 'package:health_care/model/home.dart';
import 'package:health_care/model/user.dart';
import 'package:health_care/response/user_response.dart';

import '../helper/constants.dart' as Constants;

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  MQTTClientWrapper mqttClientWrapper;
  SharedPrefsHelper sharedPrefsHelper;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  User user;

  @override
  void initState() {
    sharedPrefsHelper = SharedPrefsHelper();
    user = User('', 'Tên đăng nhập', 'Mật khẩu', 'Tên', 'SĐT', 'Địa chỉ');
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

  Widget _editContainer(String title, Color color, Widget icon) {
    return InkWell(
      onTap: () async {
        await showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                //this right here
                child: Container(
                  child: _emailPasswordWidget(),
                ),
              );
            });
        // String iduser = await sharedPrefsHelper.getStringValuesSF('iduser');
        // Home h = Home('', iduser, '', '', Constants.mac);
        // publishMessage('getinfouser', jsonEncode(h));
      },
      child: Column(
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
      ),
    );
  }

  Widget _logoutContainer(String title, Color color, Widget icon) {
    return InkWell(
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: new Text('Bạn muốn đăng xuất ?'),
                // content: new Text('Bạn muốn thoát ứng dụng?'),
                actions: <Widget>[
                  new FlatButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: new Text('Hủy'),
                  ),
                  new FlatButton(
                    onPressed: () {
                      setState(() {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => LoginPage()));
                      });
                    },
                    child: new Text('Đồng ý'),
                  ),
                ],
              );
            });
      },
      child: Column(
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
      ),
    );
  }

  Widget _emailPasswordWidget() {
    _emailController.text = user.email;
    _passwordController.text = user.pass;
    _nameController.text = user.ten;
    _phoneNumberController.text = user.sdt;
    _addressController.text = user.nha;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          _entryField("Tên đăng nhập", _emailController, false),
          _entryField("Mật khẩu", _passwordController, false, isPassword: true),
          _entryField("Tên", _nameController, true),
          _entryField("SĐT", _phoneNumberController, true),
          _entryField("Địa chỉ", _addressController, true),
          SizedBox(height: 10),
          _button('Cập nhật'),
          _button('Hủy')
        ],
      ),
    );
  }

  Widget _entryField(
      String title, TextEditingController _controller, bool isEnable,
      {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
              enabled: isEnable,
              validator: (String value) {
                if (value.isEmpty) {
                  return 'Vui lòng nhập đủ thông tin!';
                }
                return null;
              },
              controller: _controller,
              obscureText: isPassword,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        // padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              // padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
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
                _backButton(),
                SizedBox(
                  height: 10,
                ),
                CircleAvatar(
                    backgroundColor: Colors.brown.shade800,
                    minRadius: 50,
                    child: Text(
                      user.ten[0],
                      style: TextStyle(fontSize: 40),
                    )),
                SizedBox(
                  height: 20,
                ),
                Text(
                  user.ten,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 15,
                ),
                _placeContainer(
                    user.ten != null ? 'Tên: ${user.ten}' : 'Chưa nhập tên',
                    Color(0xff8f48ff),
                    null),
                _placeContainer(
                    user.email != null ? 'Tên ĐN: ${user.email}' : 'Tên ĐN: ',
                    Color(0xff526fff),
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
                _editContainer(
                    'Sửa thông tin', Color(0xffffffff), Icon(Icons.edit)),
                _placeContainer(
                    'Thêm tài khoản', Color(0xffffffff), Icon(Icons.add)),
                _logoutContainer(
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

  Widget _button(String text) {
    return InkWell(
      onTap: () {
        _tryEdit();
        Navigator.of(context).pop(false);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 10),
        margin: EdgeInsets.only(bottom: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.shade200,
                  offset: Offset(2, 4),
                  blurRadius: 5,
                  spreadRadius: 2)
            ],
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xfffbb448), Color(0xfff7892b)])),
        child: Text(
          text,
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  handle(String message) async {
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

  Future<void> _tryEdit() async {
    User user = User(
        Constants.mac,
        _emailController.text,
        _passwordController.text,
        _nameController.text,
        _phoneNumberController.text,
        _addressController.text);
    user.iduser = await sharedPrefsHelper.getStringValuesSF('iduser');
    publishMessage('updateuser', jsonEncode(user));
  }

  Future<void> publishMessage(String topic, String message) async {
    if (mqttClientWrapper.connectionState ==
        MqttCurrentConnectionState.CONNECTED) {
      mqttClientWrapper.publishMessage(topic, message);
    } else {
      await initMqtt();
      mqttClientWrapper.publishMessage(topic, message);
    }
  }
}
