class ONOFF {
  final bool heater;
  final bool kipas;
  final bool phdown;
  final bool phup;
  final bool pumpIn;
  final bool pumpOut;
  final bool switchMode;

  ONOFF({this.heater, this.kipas, this.phdown, this.phup, this.pumpIn, this.pumpOut, this.switchMode});

  factory ONOFF.fromJson(Map<dynamic, dynamic> json) {
    return ONOFF(
      heater: json['Heater'],
      kipas: json['Kipas'],
      phdown: json['pHDown'],
      phup: json['pHUp'],
      pumpIn: json['PompaAirMasuk'],
      pumpOut: json['PompaAirKeluar'],
      switchMode: json['SwitchMode'],
    );
  }
}
