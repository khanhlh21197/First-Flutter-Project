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

class AddDevice extends StatefulWidget {
  AddDevice(this.iduser, this.idnha, this.idphong, this.typeOfAdd);

  final String iduser;
  final String idnha;
  final String idphong;
  final int typeOfAdd;

  _AddDeviceState createState() =>
      _AddDeviceState(iduser, idnha, idphong, typeOfAdd);
}

class _AddDeviceState extends State<AddDevice> {
  _AddDeviceState(this.iduser, this.idnha, this.idphong, this.typeOfAdd);

  final String iduser;
  final String idnha;
  final String idphong;
  final int typeOfAdd;

  String dropdownValue = 'Đèn';
  TextEditingController _deviceNameController = TextEditingController();
  TextEditingController _deviceIdController = TextEditingController();
  MQTTClientWrapper mqttClientWrapper;
  Home home;
  Room room;
  Device device;

  final List<String> spinnerItems = ['Đèn', 'Điều hòa', 'TV', 'Quạt'];

  @override
  void initState() {
    initMqtt();
    super.initState();
  }

  void addDevice(String message) {
    Map responseMap = jsonDecode(message);

    if (responseMap['result'] == 'true') {
      String saveId = responseMap['message'];
      print(saveId);
      switch (typeOfAdd) {
        case Constants.ADD_DEPARTMENT:
          home.id = saveId;
          print('AddDevicePage: Add Home Success');
          Navigator.pop(context, home);
          break;
        case Constants.ADD_ROOM:
          room.id = saveId;
          print('AddDevicePage: Add Room Success');
          Navigator.pop(context, room);
          break;
        case Constants.ADD_DEVICE:
          device.id = saveId;
          print('AddDevicePage: Add Device Success');
          Navigator.pop(context, device);
          break;
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
      title: Text("Thêm"),
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
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: <Widget>[
                //     Text("Chọn loại thiết bị"),
                //     DropdownButton<String>(
                //       value: dropdownValue,
                //       icon: Icon(Icons.arrow_drop_down),
                //       iconSize: 24,
                //       elevation: 16,
                //       style: TextStyle(color: Colors.red, fontSize: 18),
                //       underline: Container(
                //         height: 2,
                //         color: Colors.deepPurpleAccent,
                //       ),
                //       onChanged: (String data) {
                //         setState(() {
                //           dropdownValue = data;
                //           if (dropdownValue == spinnerItems[0]) {}
                //           if (dropdownValue == spinnerItems[1]) {}
                //           if (dropdownValue == spinnerItems[2]) {}
                //           if (dropdownValue == spinnerItems[3]) {}
                //         });
                //       },
                //       items: spinnerItems
                //           .map<DropdownMenuItem<String>>((String value) {
                //         return DropdownMenuItem<String>(
                //           value: value,
                //           child: Text(value),
                //         );
                //       }).toList(),
                //     )
                //   ],
                // ),
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
                    _button('Thêm'),
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
        if (text == 'Thêm') {
          String nameAdd = utf8.encode(_deviceNameController.text).toString();
          if (typeOfAdd == Constants.ADD_DEPARTMENT) {
            topic = 'registernha';
            home = new Home(
                '', iduser, nameAdd, _deviceIdController.text, Constants.mac);
            publishMessage(topic, jsonEncode(home));
          } else if (typeOfAdd == Constants.ADD_DEVICE) {
            device = Device('', iduser, idnha, idphong, nameAdd,
                _deviceIdController.text, 'loaitb', '', Constants.mac);
            String deviceJson = jsonEncode(device);
            publishMessage('registerthietbi', deviceJson);
          } else if (typeOfAdd == Constants.ADD_ROOM) {
            topic = 'registerphong';
            room = new Room('', iduser, idnha, nameAdd,
                _deviceIdController.text, Constants.mac);
            publishMessage(topic, jsonEncode(room));
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
      //utf8.encode(message).toString()
      mqttClientWrapper.publishMessage(topic, message);
    } else {
      await initMqtt();
      mqttClientWrapper.publishMessage(topic, message);
    }
  }
}
