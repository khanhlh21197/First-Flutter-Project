import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:health_care/device/add_device_page.dart';
import 'package:health_care/device/edit_page.dart';
import 'package:health_care/helper/models.dart';
import 'package:health_care/main/user_profile_page.dart';
import 'package:health_care/model/device.dart';
import 'package:health_care/model/home.dart';
import 'package:health_care/model/room.dart';
import 'package:health_care/response/device_response.dart';
import 'package:health_care/room/room_page.dart';
import 'package:health_care/singup/signup.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../helper/constants.dart' as Constants;
import '../helper/mqttClientWrapper.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
const int LOGIN_PHONG = 0;
const int DELETE_PHONG = 1;

class DepartmentPage extends StatefulWidget {
  DepartmentPage({Key key, this.loginResponse, this.rooms, this.home})
      : super(key: key);

  final Map loginResponse;
  final List<Room> rooms;
  final Home home;

  @override
  _DepartmentPageState createState() =>
      _DepartmentPageState(loginResponse, rooms, home);
}

class _DepartmentPageState extends State<DepartmentPage>
    with SingleTickerProviderStateMixin {
  _DepartmentPageState(this.loginResponse, this.rooms, this.home);

  final Map loginResponse;
  List<Room> rooms;
  final Home home;
  List<Device> devices;
  int roomAction = 2;
  int deletePosition = 0;

  Room seletedRoom;

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
                child: new Text('Đồng ý'),
              ),
            ],
          ),
        )) ??
        false;
  }

  Future<bool> _deleteRoom(Room room) async {
    roomAction = DELETE_PHONG;
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Bạn muốn xóa phòng ?'),
            // content: new Text('Bạn muốn thoát ứng dụng?'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('Hủy'),
              ),
              new FlatButton(
                onPressed: () {
                  setState(() {
                    Navigator.of(context).pop(false);
                    Room r = Room('', iduser, home.idnha, room.tenphong,
                        room.maphong, Constants.mac);
                    String dJson = jsonEncode(r);
                    publishMessage('deletephong', dJson);
                  });
                },
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
      heroTag: 'btn3',
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
                  height: 120,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vui lòng chọn',
                        ),
                        SizedBox(height: 15),
                        SizedBox(
                          width: 320.0,
                          child: RaisedButton(
                            onPressed: () {
                              Navigator.of(context).pop(this);
                              _navigateAddDevicePage(Constants.ADD_ROOM);
                            },
                            child: Text(
                              "Thêm phòng",
                              style: TextStyle(color: Colors.white),
                            ),
                            color: const Color(0xFF1BC0C5),
                          ),
                        ),
                        // SizedBox(
                        //   width: 320.0,
                        //   child: RaisedButton(
                        //     onPressed: () {
                        //       Navigator.of(context).pop(this);
                        //       _navigateAddDevicePage(Constants.ADD_DEVICE);
                        //     },
                        //     child: Text(
                        //       "Thêm thiết bị",
                        //       style: TextStyle(color: Colors.white),
                        //     ),
                        //     color: const Color(0xFF1BC0C5),
                        //   ),
                        // ),
                        // SizedBox(
                        //   width: 320.0,
                        //   child: RaisedButton(
                        //     onPressed: () {
                        //       Navigator.of(context).pop(this);
                        //       _navigateAddDevicePage(Constants.ADD_DEPARTMENT);
                        //     },
                        //     child: Text(
                        //       "Tạo tài khoản",
                        //       style: TextStyle(color: Colors.white),
                        //     ),
                        //     color: const Color(0xFF1BC0C5),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              );
            });
      },
    );
  }

  void initOneSignal(oneSignalAppId) {
    var settings = {
      OSiOSSettings.autoPrompt: true,
      OSiOSSettings.inAppLaunchUrl: true
    };
    OneSignal.shared.init(oneSignalAppId, iOSSettings: settings);
    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);
// will be called whenever a notification is received
    OneSignal.shared
        .setNotificationReceivedHandler((OSNotification notification) {
      print('Received: ' + notification?.payload?.body ?? '');
    });
// will be called whenever a notification is opened/button pressed.
    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      print('Opened: ' + result.notification?.payload?.body ?? '');
    });
  }

  @override
  void initState() {
    super.initState();
    initMqtt();
    initOneSignal(Constants.one_signal_app_id);
    response = DeviceResponse.fromJson(loginResponse);
    iduser = response.message;
    // rooms = response.id.map((e) => Room.fromJson(e)).toList();
    // print('Department Page: ${response.id}');
    // print('Department Page: ${rooms.length}');
    // devices = response.id.map((e) => Device.fromJson(e)).toList();
    // devices.forEach((element) {
    //   if (element.trangthai == 'BAT') {
    //     element.isEnable = true;
    //   } else {
    //     element.isEnable = false;
    //   }
    // });
    // mqttClientWrapper =
    //     MQTTClientWrapper(() => print('Success'), (message) => handle(message));
    // mqttClientWrapper.prepareMqttClient(Constants.mac);

    // initMqtt();
  }

  Future<void> initMqtt() async {
    mqttClientWrapper =
        MQTTClientWrapper(() => print('Success'), (message) => handle(message));
    await mqttClientWrapper.prepareMqttClient(Constants.mac);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String title = 'Home Page';
    final double height = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).padding;
    double newheight = height - padding.top - padding.bottom;

    //gridView
    var size = MediaQuery.of(context).size;
    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;

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
            _applianceGrid(rooms, newheight)
          ]),
          Positioned(top: 25, left: 0, child: _backButton()),
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
                    home.tennha != null ? home.tennhaDecode : 'Tên nhà',
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
                        '${rooms.length}',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w900),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'phòng',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  Text(
                    'Tổng số thiết bị : ${rooms.length}',
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

  Widget _applianceGrid(List<Room> rooms, double newheight) {
    return Container(
        alignment: Alignment.topCenter,
        // padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        height: newheight - 150,
        child: GridView.count(
          // mainAxisSpacing: 10,
          // crossAxisSpacing: 10,
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          padding: EdgeInsets.all(5),
          children: List.generate(rooms.length, (index) {
            return rooms.isNotEmpty
                ? _buildApplianceCard(rooms, index)
                : Container(
                    height: 120,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                    margin: index % 3 == 0
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
                      heroTag: 'btn$index',
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

  Widget _buildApplianceCard(List<Room> rooms, int index) {
    return GestureDetector(
      child: InkWell(
        child: Container(
          height: 200,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          margin: index % 3 == 0
              ? EdgeInsets.fromLTRB(5, 5, 5, 5)
              : EdgeInsets.fromLTRB(5, 5, 5, 5),
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
                  colors: [Colors.white, Colors.white]),
              borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  // devices[index].leftIcon
                  Icon(Icons.meeting_room, color: Color(0xffa3a3a3)),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
                              //this right here
                              child: Container(
                                height: 160,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Vui lòng chọn',
                                      ),
                                      SizedBox(height: 15),
                                      SizedBox(
                                        width: 320.0,
                                        child: RaisedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(this);
                                            _navigateEditPage(
                                                Constants.EDIT_ROOM, index);
                                          },
                                          child: Text(
                                            "Sửa thông tin",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          color: const Color(0xFF1BC0C5),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 320.0,
                                        child: RaisedButton(
                                          onPressed: () {
                                            setState(() {
                                              print('Item OnLongPressed');
                                              Navigator.of(context).pop(false);
                                              _deleteRoom(rooms[index]);
                                              deletePosition = index;
                                            });
                                          },
                                          child: Text(
                                            "Xóa",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          color: const Color(0xFF1BC0C5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          });
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Flexible(
                  child: Text(
                rooms[index].tenphong != null
                    ? '${rooms[index].tenphongDecode}'
                    : 'Tên phòng',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Color(0xff302e45),
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              )),
              Text(
                rooms[index].maphong != null
                    ? '${rooms[index].maphong}'
                    : 'Mã phòng',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    // : Color(0xffa3a3a3),
                    fontSize: 20),
              ),
              // Icon(model.allYatch[index].topRightIcon,color:model.allYatch[index].isEnable ? Colors.white : Color(0xffa3a3a3))
            ],
          ),
        ),
        onTap: () async {
          seletedRoom = rooms[index];
          Room room = new Room('', iduser, home.id, '',
              '${rooms[index].maphong}', Constants.mac);
          String json = jsonEncode(room);
          publishMessage('loginphong', json);
          roomAction = LOGIN_PHONG;
          // TempPage(devices[index], iduser)));
        },
      ),
      onLongPress: () {
        //onLongPress
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

  void handle(String message) async {
    Map responseMap = jsonDecode(message);

    switch (roomAction) {
      case LOGIN_PHONG:
        {
          if (responseMap['result'] == 'true') {
            response = DeviceResponse.fromJson(responseMap);
            if (devices != null && devices.isNotEmpty) {
              devices.clear();
            }
            devices = response.id.map((e) => Device.fromJson(e)).toList();

            devices.forEach((element) {
              if (element.trangthai == '1') {
                element.isEnable = true;
              } else {
                element.isEnable = false;
              }
            });

            await Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => RoomPage(
                    loginResponse: loginResponse,
                    devices: devices,
                    room: seletedRoom,
                    home: home)));
          }
          break;
        }
      case DELETE_PHONG:
        {
          if (responseMap['result'] == 'true') {
            setState(() {
              rooms.removeAt(deletePosition);
            });
          }
          break;
        }
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

  Future<void> publishMessage(String topic, String message) async {
    if (mqttClientWrapper.connectionState ==
        MqttCurrentConnectionState.CONNECTED) {
      mqttClientWrapper.publishMessage(topic, message);
    } else {
      await initMqtt();
      mqttClientWrapper.publishMessage(topic, message);
    }
  }

  _navigateAddDevicePage(int typeOfAdd) async {
    final Room room = await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) =>
            AddDevice(iduser, home.id, '', typeOfAdd)));
    setState(() {
      rooms.add(room);
    });
  }

  _navigateCreateUserPage() async {
    //khanhlh
    await Navigator.of(context).push(
        MaterialPageRoute(builder: (BuildContext context) => SignUpPage()));
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

  void _navigateEditPage(int typeOfEdit, int index) async {
    Room room = await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) =>
            EditPage(iduser, home, rooms[index], null, typeOfEdit)));
    setState(() {
      // rooms.removeAt(index);
      // rooms.add(room);
      rooms[index].maphong = room.maphong;
      rooms[index].tenphong = room.tenphong;
    });
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
