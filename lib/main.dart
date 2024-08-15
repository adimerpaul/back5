import 'dart:async';
import 'dart:ffi';
import 'package:back5/services/Foreground.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String text = "Start Service";
  double? lat;
  double? lng;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }
  _location() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    lat = position.latitude;
    lng = position.longitude;
    setState(() {
      lat = lat;
      lng = lng;
    });
  }

  Future<void> _requestPermissions() async {
    FlutterBackgroundService().invoke("setAsForeground");
    // Solicita el permiso para notificaciones
    while (!(await Permission.notification.isGranted)) {
      var notificationStatus = await Permission.notification.request();

      if (notificationStatus.isPermanentlyDenied) {
        // Si el permiso está denegado permanentemente, muestra un mensaje o dirige al usuario a la configuración.
        print("Permiso de notificaciones denegado permanentemente");
        openAppSettings();
        return;
      }
    }

    // Solicita el permiso para ubicación
    while (!(await Permission.location.isGranted)) {
      var locationStatus = await Permission.location.request();

      if (locationStatus.isPermanentlyDenied) {
        // Si el permiso está denegado permanentemente, muestra un mensaje o dirige al usuario a la configuración.
        print("Permiso de ubicación denegado permanentemente");
        openAppSettings();
        return;
      }else{
        _location();
      }
    }
    print("Todos los permisos concedidos");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            // Mapa
            FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(lat ?? 0, lng ?? 0),
                initialZoom: 9.2,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://mt1.google.com/vt/lyrs=r&x={x}&y={y}&z={z}',
                  userAgentPackageName: 'com.example.app',
                  maxNativeZoom: 19,
                ),
              ],
            ),
            // Botones flotantes
            Positioned(
              top: 50.0,
              left: 10.0,
              right: 10.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      // Acción del botón 1
                    },
                    child: Icon(Icons.location_on),
                    heroTag: 'btn1',
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      // Acción del botón 2
                    },
                    child: Icon(Icons.map),
                    heroTag: 'btn2',
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      // Acción del botón 3
                    },
                    child: Icon(Icons.navigation),
                    heroTag: 'btn3',
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      // Acción del botón 4
                    },
                    child: Icon(Icons.settings),
                    heroTag: 'btn4',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}