import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:wave_progress_widget/wave_progress_widget.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:percent_indicator/percent_indicator.dart';
// import 'package:marquee/marquee.dart';
import 'dart:async';
import 'model/model_single.dart';
import 'model/model_switch.dart';

class SinglePageApp extends StatefulWidget {
  SinglePageApp({Key key}) : super(key: key);

  @override
  _SinglePageAppState createState() => _SinglePageAppState();
}

class _SinglePageAppState extends State<SinglePageApp>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  int tabIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference _dhtRef =
      FirebaseDatabase.instance.reference().child('Data');
  bool _signIn;
  String heatIndexText;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _signIn = false;
    heatIndexText = "Tempat Heat Index Nantinya....";

    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (_signIn) {
        setState(() {});
      }
    });

    _signInAnonymously();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _signIn ? mainScaffold() : signInScaffold();
  }

  Widget mainScaffold() {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Scaffold(
      appBar: AppBar(
        title: Text('FIREBASE REALTIME DATABASE'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (int index) {
            setState(() {
              tabIndex = index;
            });
          },
          tabs: [
            Tab(
              icon: Icon(MaterialCommunityIcons.temperature_celsius),
              text: "Suhu",
            ),
            Tab(
              icon: Icon(MaterialCommunityIcons.water),
              text: "Kekeruhan",
            ),
            Tab(
              icon: Icon(MaterialCommunityIcons.cup_water),
              text: "pH",
            ),
            Tab(
              icon: Icon(MaterialCommunityIcons.water_percent),
              text: "TDS",
            ),
            Tab(
              icon: Icon(MaterialCommunityIcons.wrench),
              text: "Kontrol",
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Container(
          //   height: 30,
          //   // child: _buildMarquee(),
          // ),
          Expanded(
            child: StreamBuilder(
                stream: _dhtRef.onValue,
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      !snapshot.hasError &&
                      snapshot.data.snapshot.value != null) {
                    var _data =
                        DATA.fromJson(snapshot.data.snapshot.value['Sensor']);
                    var _switch =
                        ONOFF.fromJson(snapshot.data.snapshot.value['Switch']);
                    // print("Data: ${_data.suhu} / ${_data.kekeruhan}");
                    // _setMarqueeText(_data);
                    return IndexedStack(
                      index: tabIndex,
                      children: [
                        _temperatureLayout(_data),
                        _turbidityLayout(_data),
                        _pHAir(_data),
                        _tds(_data),
                        _kontrolAlat(_switch),
                      ],
                    );
                  } else {
                    return Center(
                      child: Text('No Data Yet'),
                    );
                  }
                }),
          ),
        ],
      ),
    );
  }

  Widget _temperatureLayout(DATA _data) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 40),
            child: Text(
              "TEMPERATURE",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: FAProgressBar(
                border: Border.all(color: Colors.red),
                progressColor: Colors.green,
                direction: Axis.vertical,
                verticalDirection: VerticalDirection.up,
                size: 100,
                currentValue: _data.suhu.toInt(),
                changeColorValue: 100,
                changeProgressColor: Colors.red,
                maxValue: 50,
                displayText: "°C",
                borderRadius: 16,
                animatedDuration: Duration(milliseconds: 500),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              '${_data.suhu} °C',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'Data pada waktu : ${_data.time}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _turbidityLayout(DATA _data) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 40),
            child: Text(
              "TURBIDITY",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
          Expanded(
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: WaveProgress(300.0, Colors.blue, Colors.blueAccent,
                    _data.kekeruhan.toInt() / 4)),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 40),
            child: Text(
              '${_data.kekeruhan} NTU',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'Data pada waktu : ${_data.time}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pHAir(DATA _data) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 40),
            child: Text(
              "PH AIR",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: CircularPercentIndicator(
                radius: 280.0,
                lineWidth: 20.0,
                animation: true,
                percent: 1.0,
                center: new Text(
                  "${_data.ph}",
                  style: new TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 40.0),
                ),
                footer: Container(
                  padding: const EdgeInsets.only(top: 20),
                  child: new Text(
                    "Kadar pH air saat ini",
                    style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17.0,
                    ),
                  ),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: Colors.blue[300],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Data pada waktu : ${_data.time}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tds(DATA _data) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 40),
            child: Text(
              "TDS",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "JUMLAH PADATAN YANG TERLARUT DALAM AIR",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: Center(
              child: Text(
                "${_data.tds} ppm",
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )),
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'Data pada waktu : ${_data.time}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kontrolAlat(ONOFF _switch) {
    bool valueHeater = _switch.heater;
    bool valueKipas = _switch.kipas;
    bool valuepHUp = _switch.phup;
    bool valuepHDown = _switch.phdown;
    bool valuepumpin = _switch.pumpIn;
    bool valuepumpout = _switch.pumpOut;
    bool valueswitchmode = _switch.switchMode;

    onUpdateHeater() {
      setState(() {
        valueHeater = !valueHeater;
      });
    }

    onUpdateKipas() {
      setState(() {
        valueKipas = !valueKipas;
      });
    }

    onUpdatepHUp() {
      setState(() {
        valuepHUp = !valuepHUp;
      });
    }

    onUpdatepHDown() {
      setState(() {
        valuepHDown = !valuepHDown;
      });
    }

    onUpdatepumpin() {
      setState(() {
        valuepumpin = !valuepumpin;
      });
    }

    onUpdatepumpout() {
      setState(() {
        valuepumpout = !valuepumpout;
      });
    }

    onUpdateswitchmode() {
      setState(() {
        valueswitchmode = !valueswitchmode;
      });
    }

    Future<void> writeDataHeater() {
      _dhtRef.child("Switch").update({"Heater": valueHeater});
    }

    Future<void> writeDataKipas() {
      _dhtRef.child("Switch").update({"Kipas": valueKipas});
    }

    Future<void> writeDatapHUp() {
      _dhtRef.child("Switch").update({"pHUp": valuepHUp});
    }

    Future<void> writeDatapHDown() {
      _dhtRef.child("Switch").update({"pHDown": valuepHDown});
    }

    Future<void> writeDataPumpin() {
      _dhtRef.child("Switch").update({"PompaAirMasuk": valuepumpin});
    }

    Future<void> writeDataPumpout() {
      _dhtRef.child("Switch").update({"PompaAirKeluar": valuepumpout});
    }

    Future<void> writeSwitchMode() {
      _dhtRef.child("Switch").update({"SwitchMode": valueswitchmode});
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              padding: EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      "Switch Mode",
                      style: TextStyle(
                        color: valueswitchmode ? Colors.green : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 10),
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        onUpdateswitchmode();
                        writeSwitchMode();
                      },
                      label: valueswitchmode ? Text("Auto Mode") : Text("Manual Mode"),
                      elevation: 20,
                      backgroundColor:
                      valueswitchmode ? Colors.green : Colors.white,
                      icon: valueswitchmode
                          ? Icon(Icons.hdr_auto_outlined)
                          : Icon(MaterialCommunityIcons.wrench),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              padding: EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      "Heater",
                      style: TextStyle(
                        color: valueHeater ? Colors.yellow : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 10),
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        onUpdateHeater();
                        writeDataHeater();
                      },
                      label: valueHeater ? Text("ON") : Text("OFF"),
                      elevation: 20,
                      backgroundColor:
                          valueHeater ? Colors.yellow : Colors.white,
                      icon: valueHeater
                          ? Icon(Icons.visibility)
                          : Icon(Icons.visibility_off),
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      "Kipas",
                      style: TextStyle(
                        color: valueKipas ? Colors.yellow : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 10),
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        onUpdateKipas();
                        writeDataKipas();
                      },
                      label: valueKipas ? Text("ON") : Text("OFF"),
                      elevation: 20,
                      backgroundColor:
                          valueKipas ? Colors.yellow : Colors.white,
                      icon: valueKipas
                          ? Icon(Icons.visibility)
                          : Icon(Icons.visibility_off),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              padding: EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                    child: Text(
                      "Pompa pH Up",
                      style: TextStyle(
                        color: valuepHUp ? Colors.yellow : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        onUpdatepHUp();
                        writeDatapHUp();
                      },
                      label: valuepHUp ? Text("ON") : Text("OFF"),
                      elevation: 20,
                      backgroundColor: valuepHUp ? Colors.yellow : Colors.white,
                      icon: valuepHUp
                          ? Icon(Icons.visibility)
                          : Icon(Icons.visibility_off),
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                    child: Text(
                      "Pompa pH Down",
                      style: TextStyle(
                        color: valuepHDown ? Colors.yellow : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        onUpdatepHDown();
                        writeDatapHDown();
                      },
                      label: valuepHDown ? Text("ON") : Text("OFF"),
                      elevation: 20,
                      backgroundColor:
                          valuepHDown ? Colors.yellow : Colors.white,
                      icon: valuepHDown
                          ? Icon(Icons.visibility)
                          : Icon(Icons.visibility_off),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              padding: EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                    child: Text(
                      "Pompa Air Masuk",
                      style: TextStyle(
                        color: valuepumpin ? Colors.yellow : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        onUpdatepumpin();
                        writeDataPumpin();
                      },
                      label: valuepumpin ? Text("ON") : Text("OFF"),
                      elevation: 20,
                      backgroundColor: valuepumpin ? Colors.yellow : Colors.white,
                      icon: valuepumpin
                          ? Icon(Icons.visibility)
                          : Icon(Icons.visibility_off),
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                    child: Text(
                      "Pompa Air Keluar",
                      style: TextStyle(
                        color: valuepumpout ? Colors.yellow : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        onUpdatepumpout();
                        writeDataPumpout();
                      },
                      label: valuepumpout ? Text("ON") : Text("OFF"),
                      elevation: 20,
                      backgroundColor:
                      valuepumpout ? Colors.yellow : Colors.white,
                      icon: valuepumpout
                          ? Icon(Icons.visibility)
                          : Icon(Icons.visibility_off),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget signInScaffold() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "SIMPLE FIREBASE FLUTTER APP",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(
              height: 50,
            ),
            RaisedButton(
              textColor: Colors.white,
              color: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.red)),
              onPressed: () async {
                _signInAnonymously();
              },
              child: Text(
                "ANONYMOUS SIGN-IN",
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _signInAnonymously() async {
    final FirebaseUser user = (await _auth.signInAnonymously()).user;
    print("*** user isAnonymous ${user.isAnonymous}");
    print("*** user uid ${user.uid}");

    setState(() {
      if (user != null) {
        _signIn = true;
      } else {
        _signIn = false;
      }
    });
  }
}
