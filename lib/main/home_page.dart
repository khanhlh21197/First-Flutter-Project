import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_first_flutter_project/constants.dart' as Constants;
import 'package:my_first_flutter_project/main/user_profile_page.dart';
import 'package:my_first_flutter_project/model/device.dart';
import 'package:my_first_flutter_project/response/device_response.dart';

import '../mqttClientWrapper.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.loginResponse}) : super(key: key);

  final Map loginResponse;

  @override
  _HomePageState createState() => _HomePageState(loginResponse);
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  _HomePageState(this.loginResponse);

  final Map loginResponse;
  List<Device> devices;

  MQTTClientWrapper mqttClientWrapper;

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
            Text('Back',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white))
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
                            onPressed: () {},
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
                            onPressed: () {},
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
    mqttClientWrapper =
        MQTTClientWrapper(() => print('Success'), (message) => handle(message));
    mqttClientWrapper.prepareMqttClient(Constants.mac);

    var response = DeviceResponse.fromJson(loginResponse);
    devices = response.id.map((e) => Device.fromJson(e)).toList();
    devices.forEach((element) {
      if (element.trangthai == 'BAT') {
        element.isEnable = true;
      } else {
        element.isEnable = false;
      }
    });
    // WidgetsBinding.instance.addObserver(LifecycleEventHandler(
    //     resumeCallBack: () async => setState(() {
    //
    //         })));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String title = 'Home Page';

    return Material(
        child: Stack(
          children: <Widget>[
            Column(children: <Widget>[
              Container(
                height: 258,
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                padding: EdgeInsets.only(
                    top: MediaQuery
                        .of(context)
                        .padding
                        .top + 50,
                    bottom: 30,
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
              _roomCategories(),
              _applianceGrid(devices)
            ]),
            Positioned(top: 40, left: 0, child: _backButton()),
            Positioned(bottom: 16, right: 16, child: _floatingActionButton()),
          ],
        ));

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
                    'Hello Khanh!',
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
            height: 40,
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
                        '7.9',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w900),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'kwh',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  Text(
                    'Power uses for today',
                    style: TextStyle(color: Colors.white54, fontSize: 18),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _applianceGrid(List<Device> devices) {
    return Container(
        alignment: Alignment.topCenter,
        // padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        height: 350,
        child: GridView.count(
          // mainAxisSpacing: 10,
          // crossAxisSpacing: 10,
          crossAxisCount: 2,
          padding: EdgeInsets.all(0),
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
    return Container(
      height: 220,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      margin: index % 2 == 0
          ? EdgeInsets.fromLTRB(15, 7.5, 7.5, 7.5)
          : EdgeInsets.fromLTRB(7.5, 7.5, 15, 7.5),
      decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
                blurRadius: 10, offset: Offset(0, 10), color: Color(0xfff1f0f2))
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
              Icon(Icons.devices,
                  color: devices[index].isEnable
                      ? Colors.white
                      : Color(0xffa3a3a3)),
              Switch(
                  value: devices[index].isEnable,
                  activeColor: Color(0xff457be4),
                  onChanged: (_) {
                    setState(() {
                      devices[index].isEnable = !devices[index].isEnable;
                      handleDevice(devices[index].isEnable);
                      // print('${devices[index].isEnable}');
                    });
                  })
            ],
          ),
          SizedBox(
            height: 46,
          ),
          Text(
            devices[index].tenthietbi,
            style: TextStyle(
                color:
                devices[index].isEnable ? Colors.white : Color(0xff302e45),
                fontSize: 25,
                fontWeight: FontWeight.w600),
          ),
          Text(
            devices[index].mathietbi,
            style: TextStyle(
                color:
                devices[index].isEnable ? Colors.white : Color(0xffa3a3a3),
                fontSize: 20),
          ),
          // Icon(model.allYatch[index].topRightIcon,color:model.allYatch[index].isEnable ? Colors.white : Color(0xffa3a3a3))
        ],
      ),
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
              'Bedroom',
              style: TextStyle(
                  color: Color(0xff4e80f3),
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 25,
            ),
            _roomLabel(
              'Living Room',
            ),
            SizedBox(
              width: 25,
            ),
            _roomLabel(
              'Study Room',
            ),
            SizedBox(
              width: 25,
            ),
            _roomLabel(
              'Kitchin',
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

  void handle(String message) {}

  final snackBar = SnackBar(
    content: Text('Yay! A SnackBar!'),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () {
        // Some code to undo the change.
      },
    ),
  );

  void handleDevice(bool isEnable) {
    if (isEnable) {

    }else{

    }
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
