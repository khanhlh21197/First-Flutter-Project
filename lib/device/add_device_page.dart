import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'file:///E:/KhanhLH/AndroidStudioProjects/my_first_flutter_project/lib/helper/constants.dart' as Constants;
import 'package:my_first_flutter_project/model/device.dart';
import 'package:my_first_flutter_project/response/device_response.dart';

import '../helper/mqttClientWrapper.dart';

class AddDevice extends StatefulWidget {
  AddDevice(this.deviceResponse);

  final DeviceResponse deviceResponse;

  _AddDeviceState createState() => _AddDeviceState(deviceResponse);
}

class _AddDeviceState extends State<AddDevice> {
  _AddDeviceState(this.deviceResponse);

  final DeviceResponse deviceResponse;

  String dropdownValue = 'One';
  TextEditingController _deviceNameController;
  TextEditingController _deviceIdController;
  MQTTClientWrapper mqttClientWrapper;

  List<String> spinnerItems = ['One', 'Two', 'Three', 'Four', 'Five'];

  @override
  void initState() {
    mqttClientWrapper = MQTTClientWrapper(
        () => print('Success'), (message) => addDevice(message));
    mqttClientWrapper.prepareMqttClient(Constants.mac);
    super.initState();
  }

  void addDevice(String message) {
    Map responseMap = jsonDecode(message);

    if (responseMap['result'] == 'true') {
      Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Container(
      margin: EdgeInsets.only(top: 20, left: 10, right: 10),
      height: height,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text("Chọn loại thiết bị"),
                DropdownButton<String>(
                  value: dropdownValue,
                  icon: Icon(Icons.arrow_drop_down),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(color: Colors.red, fontSize: 18),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String data) {
                    setState(() {
                      dropdownValue = data;
                    });
                  },
                  items: spinnerItems
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                )
              ],
            ),
            Column(
              children: <Widget>[
                _entryField('Tên thiết bị', _deviceNameController)
              ],
            ),
            SizedBox(height: 20),
            Column(
              children: <Widget>[
                _entryField('Mã thiết bị', _deviceIdController)
              ],
            ),
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
    return InkWell(
      onTap: () {
        if (text == 'Thêm') {
          Device device = Device(
              '',
              deviceResponse.message.toString(),
              _deviceNameController.text,
              _deviceIdController.text,
              '',
              Constants.mac);
          String deviceJson = jsonEncode(device);
          mqttClientWrapper.publishMessage('registerthietbi', deviceJson);
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
}
