import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_care/helper/models.dart';
import 'package:health_care/model/device.dart';
import 'package:health_care/model/home.dart';
import 'package:health_care/model/room.dart';
import 'package:qrscan/qrscan.dart' as scanner;

import '../helper/constants.dart' as Constants;
import '../helper/mqttClientWrapper.dart';

class EditPage extends StatefulWidget {
  EditPage(this.iduser, this.home, this.room, this.device, this.typeOfEdit);

  final String iduser;
  final Home home;
  final Room room;
  final Device device;
  final int typeOfEdit;

  _EditPageState createState() =>
      _EditPageState(iduser, home, room, device, typeOfEdit);
}

class _EditPageState extends State<EditPage> {
  _EditPageState(
      this.iduser, this.home, this.room, this.device, this.typeOfEdit);

  final String iduser;
  final Home home;
  final Room room;
  final Device device;
  final int typeOfEdit;

  String dropdownValue = 'Đèn';
  TextEditingController _deviceNameController = TextEditingController();
  TextEditingController _deviceIdController = TextEditingController();
  MQTTClientWrapper mqttClientWrapper;

  final List<String> spinnerItems = ['Đèn', 'Điều hòa', 'TV', 'Quạt'];

  @override
  void initState() {
    initMqtt();
    fillText();
    super.initState();
  }

  void addDevice(String message) {
    Map responseMap = jsonDecode(message);

    if (responseMap['result'] == 'true') {
      switch (typeOfEdit) {
        case Constants.EDIT_HOME:
          {
            home.tennha = utf8.encode(_deviceNameController.text).toString();
            home.manha = _deviceIdController.text;
            Navigator.pop(context, home);
            break;
          }
        case Constants.EDIT_ROOM:
          {
            room.tenphong = utf8.encode(_deviceNameController.text).toString();
            room.maphong = _deviceIdController.text;
            print('EditPage: Edit Room Success');
            Navigator.pop(context, room);
            break;
          }
        case Constants.EDIT_DEVICE:
          {
            device.tentb = _deviceNameController.text;
            device.matb = _deviceIdController.text;
            print('EditPage: Edit Device Success');
            Navigator.pop(context, device);
            break;
          }
      }
    } else {
      final snackBar = SnackBar(
        content: Text('Thất bại, vui lòng thử lại sau!'),
        action: SnackBarAction(
          label: 'Đồng ý',
          onPressed: () {
            Scaffold.of(context).hideCurrentSnackBar();
          },
        ),
      );

      // Find the Scaffold in the widget tree and use
      // it to show a SnackBar.
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  Widget _appBar() {
    return AppBar(
      title: Text("Chỉnh sửa"),
    );
  }

  Widget _dropdownAirConditioner(BuildContext context) {
    // ignore: non_constant_identifier_names
    String ACSelectedItem = 'Panasonic';
    var _dropdownACItems = ['Panasonic', 'Nagakawa'];
    return Scaffold(
      appBar: AppBar(
        title: Text("Dropdown Button"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.cyan,
              border: Border.all()),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
                value: ACSelectedItem,
                items: _dropdownACItems
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    ACSelectedItem = value;
                  });
                }),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: _appBar(),
        body: Container(
          margin: EdgeInsets.only(top: 20, left: 10, right: 10),
          height: height,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Column(
                  children: <Widget>[_entryField('Tên', _deviceNameController)],
                ),
                SizedBox(height: 20),
                Column(
                  children: <Widget>[_entryField('Mã', _deviceIdController)],
                ),
                SizedBox(
                  height: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GestureDetector(
                      child: Icon(Icons.camera),
                      onTap: () async {
                        String cameraScanResult = await scanner.scan();
                        _deviceIdController.text = cameraScanResult;
                      },
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Visibility(
                    visible: dropdownValue == spinnerItems[1],
                    child: _dropdownAirConditioner(context)),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    SizedBox(height: 10),
                    _button('Cập nhật'),
                    SizedBox(height: 10),
                    _button('Hủy'),
                  ],
                )
              ],
            ),
          ),
        ));
  }

  Widget _button(String text) {
    String topic = '';
    return InkWell(
      onTap: () {
        if (text == 'Cập nhật') {
          String updateName =
              utf8.encode(_deviceNameController.text).toString();
          if (typeOfEdit == Constants.EDIT_HOME) {
            topic = 'updatenha';
            Home h = new Home('', iduser, updateName, _deviceIdController.text,
                Constants.mac);
            h.idnha = home.idnha;
            publishMessage(topic, jsonEncode(h));
          } else if (typeOfEdit == Constants.EDIT_DEVICE) {
            Device d = Device('', iduser, home.idnha, room.idphong, updateName,
                _deviceIdController.text, 'loaitb', '', Constants.mac);
            String deviceJson = jsonEncode(d);
            publishMessage('updatethietbi', deviceJson);
          } else if (typeOfEdit == Constants.EDIT_ROOM) {
            topic = 'updatephong';
            Room r = new Room('', iduser, home.idnha, updateName,
                _deviceIdController.text, Constants.mac);
            r.idphong = room.idphong;
            publishMessage(topic, jsonEncode(r));
          }
        } else {
          Navigator.pop(context);
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
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

  Widget _entryField(String title, TextEditingController _controller,
      {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
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
              controller: _controller,
              obscureText: isPassword,
              enabled: _controller == _deviceIdController ? false : true,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  Future<void> initMqtt() async {
    mqttClientWrapper = MQTTClientWrapper(
        () => print('Success'), (message) => addDevice(message));
    await mqttClientWrapper.prepareMqttClient(Constants.mac);
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

  void fillText() {
    switch (typeOfEdit) {
      case Constants.EDIT_HOME:
        {
          _deviceIdController.text = home.manha;
          _deviceNameController.text = home.tennhaDecode;
          break;
        }
      case Constants.EDIT_ROOM:
        {
          _deviceIdController.text = room.maphong;
          _deviceNameController.text = room.tenphongDecode;
          break;
        }
      case Constants.EDIT_DEVICE:
        {
          _deviceIdController.text = device.matb;
          _deviceNameController.text = device.tentbDecode;
          break;
        }
    }
  }
}
