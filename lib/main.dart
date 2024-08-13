import 'dart:async';
import 'package:back5/services/Foreground.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';

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

  @override
  void initState() {
    super.initState();
    _requestPermissions();
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
      }
    }
    print("Todos los permisos concedidos");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Service App'),
        ),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  child: Text(text),
                  onPressed: () async {
                    final service = FlutterBackgroundService();
                    var isRunning = await service.isRunning();
                    isRunning
                        ? service.invoke("stopService")
                        : service.startService();

                    setState(() {
                      text = isRunning ? 'Start Service' : 'Stop Service';
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}