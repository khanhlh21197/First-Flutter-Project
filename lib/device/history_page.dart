import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_care/model/history.dart';

class HistoryPage extends StatefulWidget {
  final List<History> histories;

  HistoryPage(this.histories);

  @override
  State<StatefulWidget> createState() {
    return _HistoryPageState(histories);
  }
}

class _HistoryPageState extends State<HistoryPage> {
  final List<History> histories;

  _HistoryPageState(this.histories);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300.0, // Change as per your requirement
      width: 300.0, // Change as per your requirement
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: histories.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(histories[index].time),
            subtitle:
                Text(histories[index].hengio == 'hengiobat' ? 'Bật' : 'Tắt'),
          );
        },
      ),
    );
  }
}
