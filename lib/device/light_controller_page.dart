import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:my_first_flutter_project/model/device.dart';

import 'file:///E:/KhanhLH/AndroidStudioProjects/my_first_flutter_project/lib/helper/constants.dart'
    as Constants;

import '../helper/mqttClientWrapper.dart';

class LightController extends StatefulWidget {
  final Device device;

  LightController(this.device);

  @override
  State<StatefulWidget> createState() {
    return _LightController(device);
  }
}

class _LightController extends State<LightController> {
  MQTTClientWrapper mqttClientWrapper;
  final Device device;
  DateTime _dateTimeOn = DateTime.now();
  DateTime _dateTimeOff = DateTime.now();
  bool _timerOnSwitch = false;
  bool _timerOffSwitch = false;

  _LightController(this.device);

  @override
  void initState() {
    super.initState();
    mqttClientWrapper =
        MQTTClientWrapper(() => print('Success'), (message) => handle(message));
    mqttClientWrapper.prepareMqttClient(Constants.mac);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    int w = 12;

    return Scaffold(
      body: Container(
        height: height,
        child: Stack(
          children: <Widget>[
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${device.tenthietbi}',
                          style: TextStyle(fontSize: 26))
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: Icon(
                          Icons.lightbulb_outline,
                          color: device.isEnable ? Colors.amber : Colors.grey,
                          size: 150,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Text('Điện tiêu thụ: ${device.isEnable ? w : 0}W',
                      style: TextStyle(
                          fontSize: 20,
                          color: device.isEnable ? Colors.amber : Colors.grey)),
                  SizedBox(height: 10),
                  Switch(
                      value: device.isEnable,
                      onChanged: (_) {
                        setState(() {
                          device.isEnable = !device.isEnable;
                        });
                      }),
                  SizedBox(height: 20),
                  Container(
                    color: _timerOnSwitch ? Colors.greenAccent : Colors.grey,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Hẹn giờ bật',
                          style: TextStyle(fontSize: 26),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        _timePicker(true),
                        SizedBox(
                          width: 15,
                        ),
                        Switch(
                            value: _timerOnSwitch,
                            onChanged: (_) {
                              setState(() {
                                _timerOnSwitch = !_timerOnSwitch;
                              });
                            })
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    color: _timerOffSwitch ? Colors.greenAccent : Colors.grey,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Hẹn giờ tắt',
                          style: TextStyle(fontSize: 26),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        _timePicker(false),
                        SizedBox(
                          width: 15,
                        ),
                        Switch(
                            value: _timerOffSwitch,
                            onChanged: (_) {
                              setState(() {
                                _timerOffSwitch = !_timerOffSwitch;
                              });
                            })
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  handle(String message) {}

  Widget _timePicker(bool on) {
    return new TimePickerSpinner(
      is24HourMode: true,
      normalTextStyle: TextStyle(fontSize: 24, color: Colors.black),
      highlightedTextStyle: TextStyle(fontSize: 24, color: Colors.red),
      spacing: 50,
      itemHeight: 50,
      isForce2Digits: true,
      onTimeChange: (time) {
        setState(() {
          if (on) {
            _timerOnSwitch = false;
            _dateTimeOn = time;
          } else {
            _timerOffSwitch = false;
            _dateTimeOff = time;
          }
        });
      },
    );
  }
}
