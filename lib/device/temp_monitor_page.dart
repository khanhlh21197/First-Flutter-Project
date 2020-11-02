import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_first_flutter_project/helper/mqttClientWrapper.dart';
import 'package:my_first_flutter_project/model/device.dart';
import 'package:my_first_flutter_project/patient/patient_page.dart';

class TempPage extends StatefulWidget {
  final Device device;
  final String iduser;

  TempPage(this.device, this.iduser);

  @override
  State<StatefulWidget> createState() {
    return _TempPageState(device, iduser);
  }
}

class _TempPageState extends State<TempPage> {
  final Device device;
  final String iduser;
  MQTTClientWrapper mqttClientWrapper;

  _TempPageState(this.device, this.iduser);

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
          ],
        ),
      ),
    );
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
                  SizedBox(height: 5),
                  Text(
                    'Theo dõi thiết bị',
                    style: TextStyle(color: Colors.black, fontSize: 26),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _appBar() {
    return AppBar(
      title: Text("Theo dõi thiết bị"),
    );
  }

  @override
  void initState() {
    mqttClientWrapper =
        MQTTClientWrapper(() => print('Success'), (message) => handle(message));
    mqttClientWrapper.prepareMqttClient('S${device.mathietbi}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _9spaces = '         ';
    return Scaffold(
        appBar: _appBar(),
        body: Stack(
          children: <Widget>[
            Column(children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SizedBox(
                      width: 10,
                    ),
                    IconButton(
                      icon: Icon(Icons.settings_backup_restore),
                      onPressed: () => {
                        //restore the device
                      },
                    ),
                    Text(
                      '${device.tenthietbi}',
                      style: TextStyle(fontSize: 32),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => {
                        //edit device name
                      },
                    ),
                    SizedBox(
                      width: 10,
                    )
                  ]),
              SizedBox(
                height: 20,
              ),
              Container(
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.blueAccent)),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Nhiệt độ'.toUpperCase(),
                      style: TextStyle(fontSize: 36),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '${device.nhietdo} \u2103',
                      style: TextStyle(fontSize: 42, color: Colors.red),
                    )
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                  margin: const EdgeInsets.only(left: 2, right: 2),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent)),
                  child: Column(
                    children: <Widget>[
                      Column(children: <Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            child: Text('Ngưỡng, thời gian cập nhật',
                                style: TextStyle(fontSize: 26)),
                          ),
                        ),
                      ]),
                      Divider(color: Colors.black),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Ngưỡng cảnh báo',
                              style: TextStyle(fontSize: 20)),
                          Text('40',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.red)),
                          IconButton(
                            icon: Icon(Icons.settings),
                            onPressed: () => {
                              //set the threshold
                            },
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Thời gian (s)', style: TextStyle(fontSize: 20)),
                          Text('${_9spaces}3',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.red)),
                          IconButton(
                            icon: Icon(Icons.settings),
                            onPressed: () => {
                              //set the update time
                            },
                          )
                        ],
                      ),
                    ],
                  )),
              SizedBox(height: 5),
              Column(children: <Widget>[
                FlatButton.icon(
                  label: Text('Thông tin bệnh nhân'.toUpperCase(),
                      style: TextStyle(color: Colors.blue, fontSize: 18)),
                  icon: Icon(Icons.info),
                  onPressed: () => {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => PatientPage()))
                  },
                ),
              ]),
            ]),
          ],
        ));
  }

  handle(String message) {}
}
