import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my_first_flutter_project/device/add_device_page.dart';
import 'package:my_first_flutter_project/device/temp_monitor_page.dart';
import 'package:my_first_flutter_project/helper/models.dart';
import 'package:my_first_flutter_project/main/user_profile_page.dart';
import 'package:my_first_flutter_project/model/device.dart';
import 'package:my_first_flutter_project/model/lenh.dart';
import 'package:my_first_flutter_project/model/room.dart';
import 'package:my_first_flutter_project/response/device_response.dart';

import 'file:///E:/KhanhLH/AndroidStudioProjects/my_first_flutter_project/lib/helper/constants.dart'
    as Constants;

import '../helper/mqttClientWrapper.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class RoomPage extends StatefulWidget {
  RoomPage({Key key, this.loginResponse, this.room}) : super(key: key);

  final Map loginResponse;
  final Room room;

  @override
  _RoomPageState createState() => _RoomPageState(loginResponse, room);
}

class _RoomPageState extends State<RoomPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  _RoomPageState(this.loginResponse, this.room);

  final Map loginResponse;
  final Room room;
  List<Device> devices;
  String iduser;
  DeviceResponse response;

  MQTTClientWrapper mqttClientWrapper;

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Bạn muốn thoát ứng dụng ?'),
            // content: new Text('Bạn muốn thoát ứng dụng?'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('Hủy'),
              ),
              new FlatButton(
                onPressed: () => exit(0),
                // Navigator.of(context).pop(true),
                child: new Text('Đồng ý'),
              ),
            ],
          ),
        )) ??
        false;
  }

  Future<bool> _deleteDevice(Device device) async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Bạn muốn xóa thiết bị ?'),
            // content: new Text('Bạn muốn thoát ứng dụng?'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('Hủy'),
              ),
              new FlatButton(
                onPressed: () {
                  setState(() {
                    Device d = Device('', iduser, device.tenthietbi,
                        device.mathietbi, '', Constants.mac);
                    String dJson = jsonEncode(d);
                    mqttClientWrapper.publishMessage('deletethietbi', dJson);
                  });
                },
                // Navigator.of(context).pop(true),
                child: new Text('Đồng ý'),
              ),
            ],
          ),
        )) ??
        false;
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
              child: Icon(Icons.keyboard_arrow_left, color: Colors.white),
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

  Widget _floatingActionButton() {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        SnackBarPage('onFabClicked', 'Btn');
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20.0)), //this right here
                child: Container(
                  height: 200,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Vui lòng chọn'),
                        ),
                        SizedBox(
                          width: 320.0,
                          child: RaisedButton(
                            onPressed: () {
                              Navigator.of(context).pop(this);
                              _navigateAddDevicePage();
                            },
                            child: Text(
                              "Thêm phòng",
                              style: TextStyle(color: Colors.white),
                            ),
                            color: const Color(0xFF1BC0C5),
                          ),
                        ),
                        SizedBox(
                          width: 320.0,
                          child: RaisedButton(
                            onPressed: () {
                              Navigator.of(context).pop(this);
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      AddDevice(response)));
                            },
                            child: Text(
                              "Thêm thiết bị",
                              style: TextStyle(color: Colors.white),
                            ),
                            color: const Color(0xFF1BC0C5),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // getDeviceStatus();
    response = DeviceResponse.fromJson(loginResponse);
    iduser = response.message;
    devices = response.id.map((e) => Device.fromJson(e)).toList();
    devices.forEach((element) {
      if (element.trangthai == 'BAT') {
        element.isEnable = true;
        element.nhietdo = '37';
      } else {
        element.isEnable = false;
        element.nhietdo = '38';
      }
    });

    initMqtt();
  }

  Future<void> initMqtt() async {
    mqttClientWrapper =
        MQTTClientWrapper(() => print('Success'), (message) => handle(message));
    await mqttClientWrapper.prepareMqttClient(Constants.mac);
  }

  Future<void> getDeviceStatus() async {
    mqttClientWrapper =
        MQTTClientWrapper(() => print('Success'), (message) => handle(message));
    await mqttClientWrapper.prepareMqttClient(Constants.mac);

    Device device = Device('', iduser, '', '', '', Constants.mac);
    String deviceJson = jsonEncode(device);
    mqttClientWrapper.publishMessage(Constants.device_status, deviceJson);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      if (state == AppLifecycleState.resumed) {
        print('HomePageLifeCycleState : $state');
        initMqtt();
        getDeviceStatus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String title = 'Home Page';
    final double height = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).padding;
    double newheight = height - padding.top - padding.bottom;

    return WillPopScope(
      // onWillPop: _onWillPop,
      child: Material(
          child: Stack(
        children: <Widget>[
          Column(children: <Widget>[
            Container(
              height: 170,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 30,
                  left: 30,
                  right: 30.0),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xff669df4), Color(0xff4e80f3)]),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30))),
              child: _upperContainer(),
            ),
            // _roomCategories(),
            _applianceGrid(devices, newheight)
          ]),
          Positioned(top: 30, left: 0, child: _backButton()),
          Positioned(bottom: 16, right: 16, child: _floatingActionButton()),
        ],
      )),
    );

    // return MaterialApp(
    //   title: title,
    //   home: Scaffold(
    //     appBar: AppBar(
    //       title: Text(title),
    //     ),
    //     body: GridView.builder(
    //         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //             crossAxisCount: 2, crossAxisSpacing: 4.0, mainAxisSpacing: 4.0),
    //         itemBuilder: (context, position) {
    //           return Card(
    //               child: InkWell(
    //                   onTap: () {
    //                     SnackBarPage(iduser[position].mathietbi, 'Review');
    //                   },
    //                   child: Container(
    //                     child: Text(iduser[position].tenthietbi),
    //                     decoration: BoxDecoration(
    //                         image: DecorationImage(
    //                       image: ExactAssetImage('images/lake.jpg'),
    //                     )),
    //                   )));
    //         },
    //         itemCount: iduser.length),
    //   ),
    // );
  }

  Widget _upperContainer() {
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Phòng ${room.name}',
                    style: TextStyle(color: Colors.white, fontSize: 26),
                  ),
                ],
              ),
              GestureDetector(
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                      'https://store.playstation.com/store/api/chihiro/00_09_000/container/US/en/999/UP1018-CUSA00133_00-AV00000000000015/1553561653000/image?w=256&h=256&bg_color=000000&opacity=100&_version=00_09_000'),
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => UserProfilePage()));
                },
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.white),
                    borderRadius: BorderRadius.circular(25)),
                child: Icon(
                  Icons.power,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        '${room.numberOfDevices}',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w900),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'bệnh nhân sốt',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Text(
                    '${room.id} bệnh nhân',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _applianceGrid(List<Device> devices, double newheight) {
    return Container(
        alignment: Alignment.topCenter,
        // padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        height: newheight - 150,
        child: GridView.count(
          // mainAxisSpacing: 10,
          // crossAxisSpacing: 10,
          crossAxisCount: 2,
          childAspectRatio: 1.62,
          padding: EdgeInsets.all(5),
          children: List.generate(devices.length, (index) {
            return devices[index].tenthietbi != null
                ? _buildApplianceCard(devices, index)
                : Container(
                    height: 120,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                    margin: index % 2 == 0
                        ? EdgeInsets.fromLTRB(15, 7.5, 7.5, 7.5)
                        : EdgeInsets.fromLTRB(7.5, 7.5, 15, 7.5),
                    decoration: BoxDecoration(
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              blurRadius: 10,
                              offset: Offset(0, 10),
                              color: Color(0xfff1f0f2))
                        ],
                        color: Colors.white,
                        border: Border.all(
                            width: 1,
                            style: BorderStyle.solid,
                            color: Color(0xffa3a3a3)),
                        borderRadius: BorderRadius.circular(20)),
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.add,
                        color: Colors.black,
                      ),
                      onPressed: () {},
                    ),
                  );
          }),
        ));
  }

  Widget _buildApplianceCard(List<Device> devices, int index) {
    return GestureDetector(
      child: InkWell(
        child: Container(
          height: 200,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          margin: index % 2 == 0
              ? EdgeInsets.fromLTRB(15, 7.5, 7.5, 7.5)
              : EdgeInsets.fromLTRB(7.5, 7.5, 15, 7.5),
          decoration: BoxDecoration(
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 2.0,
                  spreadRadius: 0.0,
                  offset: Offset(1.0, 1.0),
                )
              ],
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: devices[index].isEnable
                      ? [Color(0xff669df4), Color(0xff4e80f3)]
                      : [Colors.white, Colors.white]),
              borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  // devices[index].leftIcon
                  // Container(
                  //   padding: EdgeInsets.all(5),
                  //   width: 60,
                  //   height: 60,
                  //   child: Center(
                  //     child: Text(
                  //       '${devices[index].nhietdo} \u2103',
                  //       textAlign: TextAlign.center,
                  //       style: TextStyle(
                  //           fontWeight: FontWeight.bold, fontSize: 16),
                  //     ),
                  //   ),
                  //   decoration: BoxDecoration(
                  //       shape: BoxShape.circle,
                  //       color: devices[index].isEnable
                  //           ? Colors.green
                  //           : Colors.red),
                  // ),
                  new Tab(icon: new Image.asset('assets/images/thermometer.png')),
                  // Icon(Icons.warning_amber_outlined,
                  //     color: devices[index].isEnable
                  //         ? Colors.white
                  //         : Color(0xffa3a3a3)),
                  Text(
                    '${devices[index].nhietdo} \u2103',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.red),
                  ),
                  Switch(
                      value: devices[index].isEnable,
                      activeColor: Color(0xff457be4),
                      onChanged: (_) {
                        setState(() {
                          devices[index].isEnable = !devices[index].isEnable;
                          handleDevice(devices[index]);
                          // print('${devices[index].isEnable}');
                        });
                      })
                ],
              ),
              // SizedBox(
              //   height: 5,
              // ),
              Text(
                devices[index].tenthietbi,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: devices[index].isEnable
                        ? Colors.white
                        : Color(0xff302e45),
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
              Text(
                devices[index].mathietbi,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: devices[index].isEnable
                        ? Colors.white
                        : Color(0xffa3a3a3),
                    fontSize: 16),
              ),
              // Icon(model.allYatch[index].topRightIcon,color:model.allYatch[index].isEnable ? Colors.white : Color(0xffa3a3a3))
            ],
          ),
        ),
        onTap: () {
          print('Index of device: $index');
          print('${devices[index].toString()}');
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                  TempPage(devices[index], iduser)));
        },
      ),
      onLongPress: () {
        setState(() {
          print('Item OnLongPressed');
          _deleteDevice(devices[index]);
        });
      },
    );
  }

  Widget _roomCategories() {
    return Container(
      padding: EdgeInsets.only(left: 20, top: 20, bottom: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            Text(
              'Phòng ngủ',
              style: TextStyle(
                  color: Color(0xff4e80f3),
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 25,
            ),
            _roomLabel(
              'Phòng khách',
            ),
            SizedBox(
              width: 25,
            ),
            _roomLabel(
              'Phòng học',
            ),
            SizedBox(
              width: 25,
            ),
            _roomLabel(
              'Bếp',
            ),
            SizedBox(
              width: 25,
            ),
          ],
        ),
      ),
    );
  }

  Widget _roomLabel(String title) {
    return Text(
      title,
      style: TextStyle(
          color: Color(0xffb2b0b9), fontSize: 18, fontWeight: FontWeight.w600),
    );
  }

  void handle(String message) {
    Map responseMap = jsonDecode(message);

    if (responseMap['result'] == 'true') {
      response = DeviceResponse.fromJson(loginResponse);
      iduser = response.message;
      devices.clear();
      devices = response.id.map((e) => Device.fromJson(e)).toList();
      print('Length of devices: ${devices.length}');
      print('Devices: ${devices.toString()}');

      devices.forEach((element) {
        if (element.trangthai == 'BAT') {
          element.isEnable = true;
        } else {
          element.isEnable = false;
        }
      });
    }
  }

  final snackBar = SnackBar(
    content: Text('Yay! A SnackBar!'),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () {
        // Some code to undo the change.
      },
    ),
  );

  Future<void> handleDevice(Device device) async {
    Lenh lenh;
    if (device.isEnable) {
      lenh = Lenh('bat', '', iduser);
    } else {
      lenh = Lenh('tat', '', iduser);
    }
    if (mqttClientWrapper.connectionState ==
        MqttCurrentConnectionState.CONNECTED) {
      mqttClientWrapper.publishMessage(
          'P${device.mathietbi}', lenh.toJson().toString());
    } else {
      await initMqtt();
      mqttClientWrapper.publishMessage(
          'P${device.mathietbi}', lenh.toJson().toString());
    }
  }

  _navigateAddDevicePage() async {
    final kindOfDevice = await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => AddDevice(response)));
    _showToast(kindOfDevice);
  }

  void _showToast(BuildContext context) {
    final scaffold = Scaffold.of(context);
    final snackBar = SnackBar(
      content: Text('Đăng nhập thất bại!'),
      action: SnackBarAction(
        label: 'Quay lại',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );
    scaffold.showSnackBar(snackBar);
  }
}

class SnackBarPage extends StatelessWidget {
  final String data;
  final String buttonLabel;

  SnackBarPage(this.data, this.buttonLabel);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RaisedButton(
        onPressed: () {
          final snackBar = SnackBar(
            content: Text(data),
            action: SnackBarAction(
              label: buttonLabel,
              onPressed: () {
                // Some code to undo the change.
              },
            ),
          );

          // Find the Scaffold in the widget tree and use
          // it to show a SnackBar.
          Scaffold.of(context).showSnackBar(snackBar);
        },
        child: Text('Show SnackBar'),
      ),
    );
  }
}