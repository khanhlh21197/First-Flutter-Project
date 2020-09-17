class User {
  final String email;
  final String pass;
  final String ten;
  final String sdt;
  final String nha;
  final String mac;

  User(this.mac, this.email, this.pass, this.ten, this.sdt, this.nha);

  User.fromJson(Map<String, dynamic> json)
      : email = json['email'],
        pass = json['pass'],
        ten = json['ten'],
        sdt = json['sdt'],
        nha = json['nha'],
        mac = json['mac'];

  Map<String, dynamic> toJson() => {
        'email': email,
        'pass': pass,
        'ten': ten,
        'sdt': sdt,
        'nha': nha,
        'mac': mac,
      };
}
