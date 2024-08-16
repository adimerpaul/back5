import 'package:back5/services/DatabaseHelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'LoginPage.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  String text = "Start Service";
  double? lat;
  double? lng;
  late MapController _mapController;
  @override
  void initState() {
    _mapController = MapController();
    _location();
    super.initState();
  }
  _logout() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Cerrar sesión'),
            content: const Text('¿Está seguro de cerrar sesión?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  DatabaseHelper().deleteUser();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                        (Route<dynamic> route) => false,
                  );
                },
                child: const Text('Aceptar'),
              ),
            ],
          );
        });
  }
  _location() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    lat = position.latitude;
    lng = position.longitude;
    _mapController.move(LatLng(lat!, lng!), 15.0);
    setState(() {
      lat = lat;
      lng = lng;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Mapa
          FlutterMap(
            mapController: _mapController,
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
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  onPressed: _logout,
                  child: Icon(Icons.logout),
                  heroTag: 'btn4',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
