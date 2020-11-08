class History {
  String _id;
  String hengio;
  String time;
  String gio;
  String phut;

  History(this._id, this.hengio, this.time);

  History.fromJson(Map<String, dynamic> json)
      : _id = json['_id'],
        hengio = json['hengio'],
        time = json['time'];

  Map<String, dynamic> toJson() => {'_id': _id, 'hengio': hengio, 'time': time};
}
