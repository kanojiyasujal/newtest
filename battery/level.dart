import 'package:flutter/material.dart';
import 'package:battery/battery.dart';
class BatteryWidget extends StatefulWidget {
  @override
  _BatteryWidgetState createState() => _BatteryWidgetState();
}
class _BatteryWidgetState extends State<BatteryWidget> {
  Battery _battery = new Battery();
  int _batteryLevel = 0;
  @override
  void initState() {
    super.initState();
    _getBatteryLevel();
  }
  void _getBatteryLevel() async {
    int batteryLevel = await _battery.batteryLevel;
    setState(() {
      _batteryLevel = batteryLevel;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Battery level: $_batteryLevel%'),
    );
  }
}