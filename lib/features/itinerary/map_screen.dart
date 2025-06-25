import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapScreen extends StatefulWidget {
  final String departure;
  final String destination;

  const MapScreen({
    Key? key,
    required this.departure,
    required this.destination,
  }) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;

  final LatLng _departureLatLng = LatLng(48.8566, 2.3522); // Paris
  final LatLng _destinationLatLng = LatLng(48.8666, 2.3333); // Fictif

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<Map<String, dynamic>> _incidents = [];

  @override
  void initState() {
    super.initState();
    _setupMapElements();
    _loadIncidents();
  }

  void _setupMapElements() {
    _markers.addAll([
      Marker(
        markerId: MarkerId('depart'),
        position: _departureLatLng,
        infoWindow: InfoWindow(title: 'Départ : ${widget.departure}'),
      ),
      Marker(
        markerId: MarkerId('arrivee'),
        position: _destinationLatLng,
        infoWindow: InfoWindow(title: 'Arrivée : ${widget.destination}'),
      ),
    ]);

    _polylines.add(
      Polyline(
        polylineId: PolylineId('itineraire'),
        visible: true,
        points: [_departureLatLng, _destinationLatLng],
        color: Colors.blue,
        width: 5,
      ),
    );
  }

  Future<void> _loadIncidents() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> saved = prefs.getStringList('map_incidents') ?? [];

    for (var jsonStr in saved) {
      final data = jsonDecode(jsonStr);
      _addIncidentMarker(data['lat'], data['lng'], data['type']);
    }
  }

  Future<void> _saveIncident(double lat, double lng, String type) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> saved = prefs.getStringList('map_incidents') ?? [];

    final newIncident = jsonEncode({'lat': lat, 'lng': lng, 'type': type});
    saved.add(newIncident);
    await prefs.setStringList('map_incidents', saved);
  }

  void _addIncidentMarker(double lat, double lng, String type) {
    final markerId = MarkerId("incident_${lat}_$lng");
    final icon = _getIconByType(type);

    setState(() {
      _markers.add(
        Marker(
          markerId: markerId,
          position: LatLng(lat, lng),
          icon: icon,
          infoWindow: InfoWindow(title: 'Incident : $type'),
        ),
      );
    });
  }

  BitmapDescriptor _getIconByType(String type) {
    switch (type) {
      case 'Accident':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case 'Bouchon':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      case 'Incendie':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose);
      case 'Obstacle':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
      default:
        return BitmapDescriptor.defaultMarker;
    }
  }

  void _showIncidentMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.car_crash, color: Colors.red),
            title: Text("Accident"),
            onTap: () => _handleIncident("Accident"),
          ),
          ListTile(
            leading: Icon(Icons.traffic, color: Colors.orange),
            title: Text("Bouchon"),
            onTap: () => _handleIncident("Bouchon"),
          ),
          ListTile(
            leading: Icon(Icons.local_fire_department, color: Colors.deepOrange),
            title: Text("Incendie"),
            onTap: () => _handleIncident("Incendie"),
          ),
          ListTile(
            leading: Icon(Icons.block, color: Colors.grey),
            title: Text("Obstacle"),
            onTap: () => _handleIncident("Obstacle"),
          ),
        ],
      ),
    );
  }

  void _handleIncident(String type) async {
    Navigator.pop(context);
    final LatLng position = await _mapController.getLatLng(
      ScreenCoordinate(x: 200, y: 300),
    );

    _addIncidentMarker(position.latitude, position.longitude, type);
    await _saveIncident(position.latitude, position.longitude, type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Incident '$type' signalé sur la carte.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Itinéraire : ${widget.departure} → ${widget.destination}'),
        backgroundColor: Colors.deepPurple,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _departureLatLng,
          zoom: 13,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
        },
        markers: _markers,
        polylines: _polylines,
        myLocationEnabled: false,
        zoomControlsEnabled: true,
        mapType: MapType.normal,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showIncidentMenu,
        backgroundColor: Colors.red,
        child: const Icon(Icons.report),
        tooltip: "Signaler un incident",
      ),
    );
  }
}