import 'dart:convert';

import 'package:back5/services/DatabaseHelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'LoginPage.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  String text = "Start Service";
  bool _swGlobal = true;
  bool _loading = false;
  bool _backgroundStatus = false;
  double? lat;
  double? lng;
  late MapController _mapController;
  List<LatLng> polylinePoints = [];
  @override
  void initState() {
    _mapController = MapController();
    _location();
    _statusBackGround();
    super.initState();
  }
  _statusBackGround() async {
    final service = FlutterBackgroundService();
    var isRunning = await service.isRunning();
    if (isRunning) {
      _backgroundStatus = true;
    }else{
      _backgroundStatus = false;
    }
  }
  _getRoute() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    double latDestino = -17.956733;
    double lngDestino = -67.111792;
    String url = 'https://router.project-osrm.org/route/v1/driving/$lng,$lat;$lngDestino,$latDestino?geometries=geojson';
    // print(url);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> coordinates = data['routes'][0]['geometry']['coordinates'];

      setState(() {
        polylinePoints = coordinates
            .map((point) => LatLng(point[1], point[0]))
            .toList();
      });

      // Mover la cámara al inicio de la ruta
      // _mapController.move(LatLng(startLat, startLng), 14.0);
    } else {
      print('Error al obtener la ruta: ${response.statusCode}');
    }
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
  _backGround() async {
    final service = FlutterBackgroundService();
    var isRunning = await service.isRunning();
    if (isRunning) {
      service.invoke("stopService");
      _backgroundStatus = false;
    }else {
      service.startService();
      _backgroundStatus = true;
    }
    setState(() {
      _backgroundStatus = _backgroundStatus;
    });
  }
  _location() async {
    setState(() {
      _loading = true;
    });
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    lat = position.latitude;
    lng = position.longitude;
    _mapController.move(LatLng(lat!, lng!), 17.0);
    setState(() {
      lat = lat;
      lng = lng;
      _loading = false;
    });
    _getRoute();
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
              maxZoom: 22.0,
              minZoom: 12.0,
            ),
            children: [
              TileLayer(
                urlTemplate: _swGlobal?'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}':'https://mt1.google.com/vt/lyrs=r&x={x}&y={y}&z={z}',
                userAgentPackageName: 'com.example.app',
                maxNativeZoom: 19,
                tileProvider: FMTCStore('mapStore').getTileProvider(),
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: polylinePoints,
                    strokeWidth: 4.0,
                    color: Colors.blue,
                  ),
                ],
              ),
              MarkerLayer(markers: [
                Marker(
                    width: 30.0,
                    height: 30.0,
                    point: LatLng(lat ?? 0, lng ?? 0),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.redAccent, // Color del marcador
                      size: 30.0,
                    ),
                ),
              ]),
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
                    setState(() {
                      _swGlobal = !_swGlobal;
                    });
                  },
                  // icono de un planeta
                  child: Icon(_swGlobal ? Icons.satellite_outlined : Icons.map_outlined),
                  heroTag: 'btn1',
                  backgroundColor: Colors.white,
                ),
                FloatingActionButton(
                  onPressed: _backGround,
                  child: Icon(Icons.send),
                  heroTag: 'btn2',
                  backgroundColor: _backgroundStatus? Colors.green : Colors.red,
                  foregroundColor: Colors.white,
                ),
                _loading
                    ? const CircularProgressIndicator()
                    :
                FloatingActionButton(
                  onPressed: _location,
                  child: Icon(Icons.location_searching),
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
