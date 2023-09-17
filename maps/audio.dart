import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sound_mode/permission_handler.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';



class audio extends StatefulWidget {
  @override
  _audioState createState() => _audioState();
}

class _audioState extends State<audio> {
  RingerModeStatus _soundMode = RingerModeStatus.unknown;
  String? _permissionStatus;

  @override
  void initState() {
    super.initState();
    _getCurrentSoundMode();
    _getPermissionStatus();
  }

  Future<void> _getCurrentSoundMode() async {
    RingerModeStatus ringerStatus = RingerModeStatus.unknown;

    Future.delayed(const Duration(seconds: 1), () async {
      try {
        ringerStatus = await SoundMode.ringerModeStatus;
      } catch (err) {
        ringerStatus = RingerModeStatus.unknown;
      }

      setState(() {
        _soundMode = ringerStatus;
      });
    });
  }

  Future<void> _getPermissionStatus() async {
    bool? permissionStatus = false;
    try {
      permissionStatus = await PermissionHandler.permissionsGranted;
      print(permissionStatus);
    } catch (err) {
      print(err);
    }

    setState(() {
      _permissionStatus =
          permissionStatus! ? "Permissions Enabled" : "Permissions not granted";
    });
  }
 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Running on: $_soundMode'),
              Text('Permission status: $_permissionStatus'),
              SizedBox(
                height: 20,
              ),
             
              
              ElevatedButton(
                onPressed: () => _openDoNotDisturbSettings(),
                child: Text('Open Do Not Access Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }

 

 

  Future<void> _openDoNotDisturbSettings() async {
    await PermissionHandler.openDoNotDisturbSetting();
  }
  
//code

void main() async {
  // Get the current location of the device.
  Position position = await Geolocator.getCurrentPosition();
  // Check if the device is in a location where the phone should be muted.
  if (position.latitude == 40.712775 && position.longitude == -74.005973) {
    // Mute the phone.
    await  SoundMode.setSoundMode(RingerModeStatus.silent);
  } else {
    // Unmute the phone.
    await SoundMode.setSoundMode(RingerModeStatus.normal);
  }
}
}