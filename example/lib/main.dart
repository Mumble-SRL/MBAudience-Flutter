import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:mbaudience/mbaudience.dart';
import 'package:mbaudience/mbaudience_manager.dart';
import 'package:mburger/mburger.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    MBManager.shared.apiToken = 'YOUR_API_TOKEN';
    MBManager.shared.plugins = [MBAudience()];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('MBAudience example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  onPressed: () => _setTag(),
                  child: Text('Set tag'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  onPressed: () => _setCustomId(),
                  child: Text('Set custom id'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  onPressed: () => _startLocationUpdates(),
                  child: Text('Start location updates'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  onPressed: () => _stopLocationUpdates(),
                  child: Text('Stop location updates'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setTag() {
    MBAudience audience = MBManager.shared.pluginOf<MBAudience>();
    audience.setTag(tag: 'Tag', value: 'Value');
  }

  void _setCustomId() {
    MBAudience audience = MBManager.shared.pluginOf<MBAudience>();
    audience.setCustomId('CUSTOM_ID');
  }

  void _startLocationUpdates() {
    MBAudience audience = MBManager.shared.pluginOf<MBAudience>();
    audience.startLocationUpdates();
  }

  void _stopLocationUpdates() {
    MBAudience audience = MBManager.shared.pluginOf<MBAudience>();
    audience.stopLocationUpdates();
  }
}
