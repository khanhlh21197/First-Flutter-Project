import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my_first_flutter_project/device/add_device_page.dart';
import 'package:my_first_flutter_project/helper/models.dart';
import 'package:my_first_flutter_project/main/user_profile_page.dart';
import 'package:my_first_flutter_project/model/department.dart';
import 'package:my_first_flutter_project/model/device.dart';
import 'package:my_first_flutter_project/model/home.dart';
import 'package:my_first_flutter_project/model/room.dart';
import 'package:my_first_flutter_project/response/device_response.dart';
import 'package:my_first_flutter_project/singup/signup.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../helper/constants.dart' as Constants;
import '../helper/mqttClientWrapper.dart';
import 'department_page.dart';

const int LOGIN_NHA = 0;
const int DELETE_NHA = 1;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class HomePage extends StatefulWidget {
  HomePage({Key key, this.loginResponse}) : super(key: key);

  final Map loginResponse;

  @override
  _HomePageState createState() => _HomePageState(loginResponse);
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  _HomePageState(this.loginResponse);

  final Map loginResponse;
  List<Device> devices;
  List<Room> rooms = List();
  List<Department> departments = List();
  List<Home> homes = List();
  Home seletedHome;
  String iduser;
  DeviceResponse response;
  int homeAction = 2;
  int deletePosition = 0;

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

  Future<bool> _deleteHome(Home home) async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Bạn muốn xóa nhà ?'),
            // content: new Text('Bạn muốn thoát ứng dụng?'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('Hủy'),
              ),
              new FlatButton(
                onPressed: () {
                  setState(() {
                    Home h = Home(
                        '', iduser, home.tennha, home.manha, Constants.mac);
                    String dJson = jsonEncode(h);
                    publishMessage('deletenha', dJson);
                    homeAction = DELETE_NHA;
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
        _onWillPop();
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
      heroTag: 'btn1',
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
                  height: 150,
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
                              _navigateAddDevicePage(Constants.ADD_DEPARTMENT);
                            },
                            child: Text(
                              "Thêm nhà",
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
    WidgetsBinding.instance.addObserver(this);
    response = DeviceResponse.fromJson(loginResponse);

    iduser = response.message;
    homes = response.id.map((e) => Home.fromJson(e)).toList();
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
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('HomePageLifeCycleState : $state');
    if (state == AppLifecycleState.resumed) {
      print('HomePageLifeCycleState : $state');
      initMqtt();
    }
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
      onWillPop: _onWillPop,
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
            _applianceGrid(homes, newheight)
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
                    'Xin chào Khanh!',
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
                        'phòng có bệnh nhân sốt',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  Text(
                    'Tổng số phòng : ${rooms.length}',
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

  Widget _applianceGrid(List<Home> homes, double newheight) {
    return Container(
        alignment: Alignment.topCenter,
        // padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        height: newheight - 150,
        child: GridView.count(
          // mainAxisSpacing: 10,
          // crossAxisSpacing: 10,
          crossAxisCount: 2,
          childAspectRatio: 1.3,
          padding: EdgeInsets.all(5),
          children: List.generate(homes.length, (index) {
            return homes[index].tennha != null
                ? _buildApplianceCard(homes, index)
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
                      heroTag: 'btn2',
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

  Widget _buildApplianceCard(List<Home> homes, int index) {
    return GestureDetector(
      child: InkWell(
        child: Container(
          height: 200,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          margin: index % 2 == 0
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
                  colors: homes[index].isEnable
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
                  Icon(Icons.home,
                      size: 50,
                      color: homes[index].isEnable
                          ? Colors.white
                          : Color(0xffa3a3a3)),
                  // Switch(
                  //     value: rooms[index].isEnable,
                  //     activeColor: Color(0xff457be4),
                  //     onChanged: (_) {
                  //       setState(() {
                  //         rooms[index].isEnable = !rooms[index].isEnable;
                  //         handleRoom(rooms[index]);
                  //         // print('${devices[index].isEnable}');
                  //       });
                  //     })
                ],
              ),
              SizedBox(
                height: 20,
              ),
              // Text(
              //   '${rooms[index].numberOfDevices} bệnh nhân',
              //   style: TextStyle(
              //       color: rooms[index].isEnable
              //           ? Colors.white
              //           : Color(0xff302e45),
              //       fontSize: 25,
              //       fontWeight: FontWeight.w600),
              // ),
              Flexible(
                  child: Text(
                '${homes[index].tennha}',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: homes[index].isEnable
                        ? Colors.white
                        : Color(0xff302e45),
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              )),
              SizedBox(height: 5),
              Flexible(
                child: Text(
                  '${homes[index].idnha}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      // color: homes[index].isEnable ? Colors.white : Colors.red,
                      // fontWeight: FontWeight.w600,
                      // : Color(0xffa3a3a3),
                      fontSize: 16),
                ),
              ),
              // Icon(model.allYatch[index].topRightIcon,color:model.allYatch[index].isEnable ? Colors.white : Color(0xffa3a3a3))
            ],
          ),
        ),
        onTap: () async {
          seletedHome = homes[index];
          Home home =
              new Home('', iduser, '', '${homes[index].manha}', Constants.mac);
          String json = jsonEncode(home);
          publishMessage('loginnha', json);
          homeAction = LOGIN_NHA;
          // RoomPage(loginResponse: loginResponse, room: rooms[index])));
          // TempPage(devices[index], iduser)));
        },
      ),
      onLongPress: () {
        setState(() {
          print('Item OnLongPressed');
          _deleteHome(homes[index]);
          deletePosition = index;
        });
      },
    );
  }

  Widget _roomLabel(String title) {
    return Text(
      title,
      style: TextStyle(
          color: Color(0xffb2b0b9), fontSize: 18, fontWeight: FontWeight.w600),
    );
  }

  Future<void> handle(String message) async {
    Map responseMap = jsonDecode(message);

    switch (homeAction) {
      case LOGIN_NHA:
        {
          if (responseMap['result'] == 'true') {
            response = DeviceResponse.fromJson(jsonDecode(message));

            rooms.clear();
            print('Home page: ${response.id}');
            rooms = response.id.map((e) => Room.fromJson(e)).toList();
            print('loginnha: ${rooms.length}');

            await Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => DepartmentPage(
                    loginResponse: loginResponse,
                    rooms: rooms,
                    home: seletedHome)));
          }
          break;
        }
      case DELETE_NHA:
        {
          if (responseMap['result'] == 'true') {
            setState(() {
              homes.removeAt(deletePosition);
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

  Future<void> handleRoom(Room room) async {
    // Lenh lenh;
    // if (room.isEnable) {
    //   lenh = Lenh('bat', '', iduser);
    // } else {
    //   lenh = Lenh('tat', '', iduser);
    // }
    // if (mqttClientWrapper.connectionState ==
    //     MqttCurrentConnectionState.CONNECTED) {
    //   mqttClientWrapper.publishMessage(
    //       'P${device.mathietbi}', lenh.toJson().toString());
    // } else {
    //   await initMqtt();
    //   mqttClientWrapper.publishMessage(
    //       'P${device.mathietbi}', lenh.toJson().toString());
    // }
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

  _navigateAddDevicePage(int typeOfAdd) async {
    final Home home = await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) =>
            AddDevice(iduser, '', '', typeOfAdd)));
    setState(() {
      homes.add(home);
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
