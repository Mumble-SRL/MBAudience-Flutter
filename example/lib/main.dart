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

    MBAudience audience = MBManager.shared.plugins.firstWhere(
      (element) => element is MBAudience,
      orElse: null,
    );

    audience.startLocationUpdates();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: '),
        ),
      ),
    );
  }
}
