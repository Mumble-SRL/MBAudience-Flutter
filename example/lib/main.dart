import 'package:flutter/material.dart';
import 'package:mbaudience/mbaudience.dart';
import 'package:mburger/mburger.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
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
                child: TextButton(
                  onPressed: () => _setTag(),
                  child: const Text('Set tag'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () => _setCustomId(),
                  child: const Text('Set custom id'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () => _startLocationUpdates(),
                  child: const Text('Start location updates'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () => _stopLocationUpdates(),
                  child: const Text('Stop location updates'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setTag() {
    MBAudience.setTag(tag: 'Tag', value: 'Value');
  }

  void _setCustomId() {
    MBAudience.setCustomId('CUSTOM_ID');
  }

  void _startLocationUpdates() {
    MBAudience.startLocationUpdates();
  }

  void _stopLocationUpdates() {
    MBAudience.stopLocationUpdates();
  }
}
