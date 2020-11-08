class Lenh {
  String lenh;
  String param;
  String matb;

  Lenh(this.lenh, this.param, this.matb);

  Lenh.fromJson(Map<String, dynamic> json)
      : lenh = json['lenh'],
        param = json['param'],
        matb = json['matb'];

  Map<String, dynamic> toJson() => {'lenh': lenh, 'param': param, 'matb': matb};
}
