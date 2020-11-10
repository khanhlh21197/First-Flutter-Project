class History {
  String _id;
  String hengio;
  String hengioE;
  int index;
  String matb;
  String time;
  String gio;
  String phut;

  History(this._id, this.hengio, this.time, this.matb);

  History.fromJson(Map<String, dynamic> json)
      : _id = json['_id'],
        hengio = json['hengio'],
        time = json['time'],
        matb = json['matb'];

  Map<String, dynamic> toJson() =>
      {'_id': _id, 'hengio': hengio, 'time': time, 'matb': matb};
}
