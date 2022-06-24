class DATA {
  final double suhu;
  final double kekeruhan;
  final double ph;
  final double tds;
  final String time;

  DATA({this.suhu, this.kekeruhan, this.time, this.ph, this.tds});

  factory DATA.fromJson(Map<dynamic, dynamic> json) {
    return DATA(
      suhu: json['Suhu'],
      kekeruhan: json['Kekeruhan'],
      ph: json['pH'],
      time: json['Time'],
      tds: json['TDS'],
    );
  }
}
