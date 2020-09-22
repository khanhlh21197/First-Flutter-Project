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
    devices.add(
        new Device('_id', 'iduser', 'tenthietbi', 'mathietbi', 'trangthai'));
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
                  child: InkWell(
                      onTap: () {
                        SnackBarPage(devices[position].mathietbi, 'Review');
                      },
                      child: Container(
                        child: Text(devices[position].tenthietbi),
                        decoration: BoxDecoration(
                            image: DecorationImage(
                          image: ExactAssetImage('images/lake.jpg'),
                        )),
                      )));
            },
            itemCount: devices.length),
      ),
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
