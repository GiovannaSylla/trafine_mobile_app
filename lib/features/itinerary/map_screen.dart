import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  final LatLng _destinationLatLng = LatLng(48.8666, 2.3333); // Point fictif

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _setupMapElements();
  }

  void _setupMapElements() {
    // Ajout des marqueurs
    if (widget.departure.isNotEmpty) {
      _markers.add(
        Marker(
          markerId: MarkerId('depart'),
          position: _departureLatLng,
          infoWindow: InfoWindow(title: 'Départ : ${widget.departure}'),
        ),
      );
    }

    if (widget.destination.isNotEmpty) {
      _markers.add(
        Marker(
          markerId: MarkerId('arrivee'),
          position: _destinationLatLng,
          infoWindow: InfoWindow(title: 'Arrivée : ${widget.destination}'),
        ),
      );
    }

    // Ajout de l'itinéraire (polyline)
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
    );
  }
}