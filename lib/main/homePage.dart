import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_first_flutter_project/constants.dart' as Constants;
import 'package:my_first_flutter_project/model/device.dart';

import '../mqttClientWrapper.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MQTTClientWrapper mqttClientWrapper;

  @override
  void initState() {
    super.initState();
    mqttClientWrapper =
        MQTTClientWrapper(() => print('Success'), (message) => handle(message));
    mqttClientWrapper.prepareMqttClient(Constants.mac);
  }

  @override
  Widget build(BuildContext context) {
    final String title = 'Home Page';
    List<Device> devices = new List(10);
    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: GridView.builder(
            gridDelegate: null,
            itemBuilder: (context, position) {
              return Card(
                child: Text(devices[position].tenthietbi),
              );
            },
            itemCount: devices.length),
      ),
    );
  }

  void handle(String message) {}
}