import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_first_flutter_project/actions/actions.dart';
import 'package:my_first_flutter_project/helper/reminder/notificationHelper.dart';
import 'package:my_first_flutter_project/model/device.dart';
import 'package:my_first_flutter_project/model/lenh.dart';
import 'package:my_first_flutter_project/store/store.dart';

import '../helper/mqttClientWrapper.dart';

const String custom = 'Custom time';
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class LightController extends StatefulWidget {
  final Device device;
  final String iduser;

  LightController(this.device, this.iduser);

  @override
  State<StatefulWidget> createState() {
    return _LightController(device, iduser);
  }
}

class _LightController extends State<LightController> {
  MQTTClientWrapper mqttClientWrapper;
  final Device device;
  final String iduser;
  TimeOfDay customNotificationTime;
  bool customReminder = false;

  DateTime _dateTimeOn = DateTime.now();
  DateTime _dateTimeOff = DateTime.now();
  bool _timerOnSwitch = false;
  bool _timerOffSwitch = false;

  _LightController(this.device, this.iduser);

  @override
  void initState() {
    super.initState();
    mqttClientWrapper =
        MQTTClientWrapper(() => print('Success'), (message) => handle(message));
    mqttClientWrapper.prepareMqttClient('S${device.mathietbi}');
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
            //         color: Colors.black))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    int w = 12;

    return Scaffold(
        body: Stack(
      children: <Widget>[
        Positioned(top: 40, left: 0, child: _backButton()),
        Container(
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
                            FontAwesomeIcons.lightbulb,
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
                            color:
                                device.isEnable ? Colors.amber : Colors.grey)),
                    SizedBox(height: 10),
                    CupertinoSwitch(
                        value: device.isEnable,
                        onChanged: (_) {
                          setState(() {
                            initNotifications(flutterLocalNotificationsPlugin)
                                .then((value) => {
                                      showNotification(
                                          flutterLocalNotificationsPlugin)
                                    });
                            device.isEnable = !device.isEnable;
                            if (device.isEnable) {
                              Lenh lenh = Lenh('bat', '', iduser);
                              mqttClientWrapper.publishMessage(
                                  'P${device.mathietbi}', jsonEncode(lenh));
                            } else {
                              Lenh lenh = Lenh('tat', '', iduser);
                              mqttClientWrapper.publishMessage(
                                  'P${device.mathietbi}', jsonEncode(lenh));
                            }
                          });
                        }),
                    SizedBox(height: 20),
                    Card(
                      color:
                          _timerOnSwitch ? Colors.yellow : Colors.transparent,
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
                          CupertinoSwitch(
                              value: _timerOnSwitch,
                              onChanged: (_) {
                                setState(() {
                                  _timerOnSwitch = !_timerOnSwitch;
                                  String param =
                                      '${_dateTimeOn.hour}&${_dateTimeOn.minute}';
                                  if (_timerOnSwitch) {
                                    Lenh lenh =
                                        Lenh('hengiobat', param, iduser);
                                    mqttClientWrapper.publishMessage(
                                        'P${device.mathietbi}',
                                        jsonEncode(lenh));
                                  } else {
                                    // Lenh lenh = Lenh('hengiotat', param, iduser);
                                    // mqttClientWrapper.publishMessage(
                                    //     'P${device.mathietbi}', jsonEncode(lenh));
                                  }
                                });
                              })
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Card(
                      color:
                          _timerOffSwitch ? Colors.yellow : Colors.transparent,
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
                          CupertinoSwitch(
                              value: _timerOffSwitch,
                              onChanged: (_) {
                                setState(() {
                                  _timerOffSwitch = !_timerOffSwitch;
                                  String param =
                                      '${_dateTimeOff.hour}&${_dateTimeOff.minute}';
                                  if (_timerOffSwitch) {
                                    Lenh lenh =
                                        Lenh('hengiotat', param, iduser);
                                    mqttClientWrapper.publishMessage(
                                        'P${device.mathietbi}',
                                        jsonEncode(lenh));
                                  } else {
                                    // Lenh lenh = Lenh('hengiotat', param, iduser);
                                    // mqttClientWrapper.publishMessage(
                                    //     'P${device.mathietbi}', jsonEncode(lenh));
                                  }
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
      ],
    ));
  }

  _showTimeDialog(StateSetter setState) async {
    TimeOfDay selectedTime = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
    );

    setState(() {
      customNotificationTime = selectedTime;
      customReminder = true;
    });

    _configureCustomReminder(true);
  }

  void _configureCustomReminder(bool value) {
    if (customNotificationTime != null) {
      if (value) {
        var now = new DateTime.now();
        var notificationTime = new DateTime(now.year, now.month, now.day,
            customNotificationTime.hour, customNotificationTime.minute);

        getStore().dispatch(SetReminderAction(
            time: notificationTime.toIso8601String(),
            name: custom,
            repeat: RepeatInterval.Daily));

        scheduleNotification(
            flutterLocalNotificationsPlugin, '4', custom, notificationTime);
      } else {
        getStore().dispatch(RemoveReminderAction(custom));
        turnOffNotificationById(flutterLocalNotificationsPlugin, 4);
      }
    }
  }

  handle(String message) {
    print('Light Controller $message');
  }

  Widget _timePicker(bool on) {
    return new TimePickerSpinner(
      is24HourMode: true,
      normalTextStyle: TextStyle(fontSize: 24, color: Colors.black),
      highlightedTextStyle: TextStyle(fontSize: 24, color: Colors.red),
      spacing: 50,
      itemHeight: 30,
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
