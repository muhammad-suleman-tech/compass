import 'dart:math' as math;
import 'package:compassapp/neu_circle.dart';
import 'package:compassapp/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _hasPermissions = false;

  @override
  void initState() {
    super.initState();
    // const SplashScreen();
    fetchPermissionStatus();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.blueGrey[600],
        body: Builder(
          builder: (context) {
            if (_hasPermissions) {
              return _buildCompass();
            } else {
              return _buildPermissionSheet();
            }
          },
        ),
      ),
    );
  }

  Widget _buildCompass() {
    return Column(
      children: [
        Container(
            margin: const EdgeInsets.only(top: 80),
            child:  Text("COMPASS",style: GoogleFonts.merriweather(fontSize: 32,color: Colors.white),)
        ),
        Container(
          margin: const EdgeInsets.only(top: 100),
          child: StreamBuilder<CompassEvent>(
            stream: FlutterCompass.events,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error reading heading: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              double? direction = snapshot.data!.heading;

              // if direction is null, then device does not support this sensor
              // show error message
              if (direction == null) {
                return const Center(
                  child: Text("Device does not have sensors !"),
                );
              }

              return NeuCircle(
                child: Transform.rotate(
                  angle: (direction * (math.pi / 180) * -1),
                  child: Image.asset(
                    'assets/compass.png',
                    color: Colors.white,
                    fit: BoxFit.fill,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionSheet() {
    return Center(
      child: ElevatedButton(
        child: const Text('Request Permissions'),
        onPressed: () {
          Permission.locationWhenInUse.request().then((ignored) {
            fetchPermissionStatus();
          });
        },
      ),
    );
  }

  void fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() => _hasPermissions = status == PermissionStatus.granted);
      }
    });
  }
}
