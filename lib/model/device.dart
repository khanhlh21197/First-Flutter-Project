class Device {
  String id;
  String iduser;
  String tenthietbi;
  String mathietbi;
  String status;

  Device(this.id, this.iduser, this.tenthietbi, this.mathietbi, this.status);

  Map<String, dynamic> toJson() => {
        'id': id,
        'iduser': iduser,
        'tenthietbi': tenthietbi,
        'mathietbi': mathietbi,
        'status': status
      };
}
