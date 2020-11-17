import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_care/actions/actions.dart';
import 'package:health_care/helper/models.dart';
import 'package:health_care/helper/reminder/notificationHelper.dart';
import 'package:health_care/model/device.dart';
import 'package:health_care/model/history.dart';
import 'package:health_care/model/lenh.dart';
import 'package:health_care/response/device_response.dart';
import 'package:health_care/store/store.dart';

import '../helper/constants.dart' as Constants;
import '../helper/mqttClientWrapper.dart';

const String custom = 'Custom time';

const String HENGIOBAT = 'hengiobat';
const String HENGIOTAT = 'hengiotat';
const String XOALICHSU = 'deletehistorytime';
const String LAYLICHSU = 'historytime';

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

class _LightController extends State<LightController>
    with SingleTickerProviderStateMixin {
  MQTTClientWrapper mqttClientWrapper;
  final Device device;
  final String iduser;
  TimeOfDay customNotificationTime;
  bool customReminder = false;
  TabController _tabController;
  List<Tab> tabs = <Tab>[
    Tab(icon: Icon(Icons.timer)),
    Tab(icon: Icon(Icons.timer_off)),
  ];

  DateTime _dateTimeOn = DateTime.now();
  DateTime _dateTimeOff = DateTime.now();
  bool _timerOnSwitch = false;
  bool _timerOffSwitch = false;
  bool onHistory = true;
  String topic;
  int deletePosition;
  int currentTabIndex;

  List<History> histories = List();
  List<History> onHistories = List();
  List<History> offHistories = List();

  _LightController(this.device, this.iduser);

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        currentTabIndex = _tabController.index;
        print('Current Tab Index: $currentTabIndex');
      });
    });
    initMqtt();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                        Text('${device.tentbDecode}',
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
                        key: UniqueKey(),
                        value: device.isEnable,
                        onChanged: (_) {
                          setState(() {
                            initNotifications(flutterLocalNotificationsPlugin)
                                .then((value) => {
                                      showNotification(
                                          flutterLocalNotificationsPlugin,
                                          device.tentb != null
                                              ? '${device.tentbDecode}'
                                              : "Ten TB",
                                          _ ? 'Bật' : 'Tắt')
                                    });
                            device.isEnable = !device.isEnable;
                            if (device.isEnable) {
                              Lenh lenh = Lenh("bat", '', "${device.matb}");
                              publishMessage(
                                  'P${device.matb}', jsonEncode(lenh));
                            } else {
                              Lenh lenh = Lenh("tat", '', "${device.matb}");
                              publishMessage(
                                  'P${device.matb}', jsonEncode(lenh));
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
                                    topic = HENGIOBAT;
                                    Lenh lenh =
                                        Lenh(HENGIOBAT, param, device.matb);
                                    publishMessage(
                                        'PUB${device.matb}', jsonEncode(lenh));
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
                                    topic = HENGIOTAT;
                                    Lenh lenh = Lenh(topic, param, device.matb);
                                    publishMessage(
                                        'PUB${device.matb}', jsonEncode(lenh));
                                  } else {
                                    // Lenh lenh = Lenh('hengiotat', param, iduser);
                                    // mqttClientWrapper.publishMessage(
                                    //     'P${device.mathietbi}', jsonEncode(lenh));
                                  }
                                });
                              }),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    _historyWidget(),
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

  void handle(String message) async {
    Map responseMap = jsonDecode(message);
    print('${responseMap['message']}');

    if (responseMap['result'] == 'true') {
      setState(() {
        if (responseMap['message'] == 'bat') {
          device.isEnable = true;
        } else {
          device.isEnable = false;
        }
        initNotifications(flutterLocalNotificationsPlugin).then((value) => {
              showNotification(
                  flutterLocalNotificationsPlugin,
                  device.tentb != null ? '${device.tentbDecode}' : "Ten TB",
                  device.isEnable ? 'Bật' : 'Tắt')
            });
      });
      switch (topic) {
        // case LAYLICHSU:
        //   {
        //     DeviceResponse response = DeviceResponse.fromJson(responseMap);
        //
        //     histories.clear();
        //     onHistories.clear();
        //     offHistories.clear();
        //
        //     histories = response.id.map((e) => History.fromJson(e)).toList();
        //     print('History: ${histories.length}');
        //     histories.forEach((element) {
        //       element.index = histories.indexOf(element);
        //       if (element.hengio == HENGIOBAT) {
        //         element.hengioE = 'Hẹn giờ bật';
        //         onHistories.add(element);
        //       } else {
        //         element.hengioE = 'Hẹn giờ tắt';
        //         offHistories.add(element);
        //       }
        //       element.gio = element.time.split('&')[0] + ' giờ';
        //       element.phut = element.time.split('&')[1] + ' phút';
        //     });
        //
        //     showDialog(
        //         context: context,
        //         builder: (BuildContext context) {
        //           return Dialog(
        //             shape: RoundedRectangleBorder(
        //                 borderRadius: BorderRadius.circular(20.0)),
        //             //this right here
        //             child: Container(
        //               child: _historyTab(onHistories, offHistories),
        //             ),
        //           );
        //         });
        //     topic = "";
        //     break;
        //   }
        case XOALICHSU:
          {
            if (currentTabIndex == 0) {
              print('Delete Position: $deletePosition');
              print('onHistories ${onHistories.length}');
              setState(() {
                onHistories.removeAt(deletePosition);
              });
              print('onHistories removed! ${onHistories.length}');
            } else {
              offHistories.removeAt(deletePosition);
              print('offHistories removed!');
            }
            // onHistories.forEach((element) {
            //   if (element.matb == histories[deletePosition].matb) {
            //     setState(() {
            //       onHistories.remove(element);
            //     });
            //   }
            // });
            // offHistories.forEach((element) {
            //   if (element.matb == histories[deletePosition].matb) {
            //     setState(() {
            //       offHistories.remove(element);
            //     });
            //   }
            // });
            topic = "";
            break;
          }
        case HENGIOBAT:
          {
            topic = "";
            break;
          }
        case HENGIOTAT:
          {
            topic = "";
            break;
          }
      }
    }
  }

  Widget _historyTab(List<History> onHistories, List<History> offHistories) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          tabs: tabs,
          controller: _tabController,
        ),
        title: Text('Hẹn giờ'),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _historyList(onHistories, true),
          _historyList(offHistories, false),
        ],
      ),
    ));
  }

  Widget _historyList(List<History> histories, bool on) {
    return Container(
      // height: 300.0, // Change as per your requirement
      // width: 300.0, // Change as per your requirement
      child: histories.isNotEmpty
          ? ListView.builder(
              shrinkWrap: true,
              itemCount: histories.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title:
                      Text('${histories[index].gio} ${histories[index].phut}'),
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) => new AlertDialog(
                        title: new Text('Xóa hẹn giờ ?'),
                        actions: <Widget>[
                          new FlatButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: new Text('Hủy'),
                          ),
                          new FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                              setState(() {
                                histories[index].matb = device.matb;

                                String dJson = jsonEncode(histories[index]);
                                topic = XOALICHSU;
                                publishMessage(XOALICHSU, dJson);
                                deletePosition = index;
                              });
                            },
                            child: new Text('Đồng ý'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            )
          : Container(
              margin: const EdgeInsets.all(10),
              child: Text(
                'Không có lịch sử hẹn giờ',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
    );
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

  Widget _historyWidget() {
    device.mac = Constants.mac;
    return InkWell(
        onTap: () =>
            {topic = LAYLICHSU, publishMessage(topic, jsonEncode(device))},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          //change here don't //worked
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                  left: 8.0, top: 8.0, bottom: 8.0, right: 12.0),
              width: 15.0,
              height: 15.0,
              decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(40.0)),
            ),
            Text(
              "Xem lịch sử hẹn giờ",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 19.0,
                  fontWeight: FontWeight.bold),
            ),
            new Spacer(), // I just added one line
            Icon(Icons.info, color: Colors.blue) // This Icon
          ],
        ));
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

  Future<void> initMqtt() async {
    mqttClientWrapper =
        MQTTClientWrapper(() => print('Success'), (message) => handle(message));
    await mqttClientWrapper.prepareMqttClient('S${device.matb}');
    mqttClientWrapper.subscribe(
        'SUB${device.matb}', (message) => laylichsu(message));
  }

  void laylichsu(String message) {
    if (topic != LAYLICHSU) return;
    Map responseMap = jsonDecode(message);
    print('Lichsu: ${responseMap['message']}');

    DeviceResponse response = DeviceResponse.fromJson(responseMap);

    histories.clear();
    onHistories.clear();
    offHistories.clear();

    histories = response.id.map((e) => History.fromJson(e)).toList();
    print('History: ${histories.length}');
    histories.forEach((element) {
      element.index = histories.indexOf(element);
      if (element.hengio == HENGIOBAT) {
        element.hengioE = 'Hẹn giờ bật';
        onHistories.add(element);
      } else {
        element.hengioE = 'Hẹn giờ tắt';
        offHistories.add(element);
      }
      element.gio = element.time.split('&')[0] + ' giờ';
      element.phut = element.time.split('&')[1] + ' phút';
    });

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            //this right here
            child: Container(
              child: _historyTab(onHistories, offHistories),
            ),
          );
        });
    topic = "";
  }
}
