import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddDevice extends StatefulWidget {
  AddDevice();

  _AddDeviceState createState() => _AddDeviceState();
}

class _AddDeviceState extends State<AddDevice> {
  String dropdownValue = 'One';
  TextEditingController _deviceNameController;
  TextEditingController _deviceIdController;

  List<String> spinnerItems = ['One', 'Two', 'Three', 'Four', 'Five'];

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Container(
      height: height,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text("Chọn loại thiết bị"),
                DropdownButton<String>(
                  value: dropdownValue,
                  icon: Icon(Icons.arrow_drop_down),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(color: Colors.red, fontSize: 18),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String data) {
                    setState(() {
                      dropdownValue = data;
                    });
                  },
                  items: spinnerItems
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                )
              ],
            ),
            Column(
              children: <Widget>[
                _entryField('Tên thiết bị', _deviceNameController)
              ],
            ),
            SizedBox(height: 20),
            Column(
              children: <Widget>[
                _entryField('Mã thiết bị', _deviceIdController)
              ],
            )
          ],
        ),
      ),
    ));
  }

  Widget _entryField(String title, TextEditingController _controller,
      {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
              controller: _controller,
              obscureText: isPassword,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }
}
