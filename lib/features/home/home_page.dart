import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supmap_clean/features/itinerary/itinerary_page.dart';
import 'package:supmap_clean/features/auth/login_page.dart';

class HomePage extends StatefulWidget {
  final String prenom;
  final String nom;

  const HomePage({super.key, required this.prenom, required this.nom});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController _mapController;
  final LatLng _initialPosition = const LatLng(48.8566, 2.3522); // Paris
  final List<Marker> _incidentMarkers = [];

  int _selectedIndex = 0;
  List<Map<String, dynamic>> _incidents = [];

  @override
  void initState() {
    super.initState();
    _loadIncidents();
  }

  Future<void> _loadIncidents() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> saved = prefs.getStringList('map_incidents') ?? [];

    final incidents = saved.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();

    setState(() {
      _incidents = incidents.reversed.toList(); // les plus récents en haut

      _incidentMarkers.clear();
      for (var incident in _incidents) {
        _incidentMarkers.add(
          Marker(
            markerId: MarkerId(incident['timestamp'].toString()),
            position: LatLng(incident['lat'], incident['lng']),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(title: incident['type']),
          ),
        );
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ItineraryPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SUPMAP - Accueil"),
        backgroundColor: Colors.deepPurple,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text("${widget.prenom} ${widget.nom}"),
              accountEmail: const Text("giovanna@email.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(widget.prenom[0], style: const TextStyle(fontSize: 30, color: Colors.deepPurple)),
              ),
              decoration: const BoxDecoration(color: Colors.deepPurple),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Mon profil"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Déconnexion"),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'Bienvenue ',
                style: const TextStyle(fontSize: 22, color: Colors.black87),
                children: [
                  TextSpan(
                    text: "${widget.prenom} ${widget.nom}",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 12),
              onMapCreated: (controller) => _mapController = controller,
              markers: Set<Marker>.of(_incidentMarkers),
              zoomControlsEnabled: true,
              mapType: MapType.normal,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ItineraryPage()));
            },
            icon: const Icon(Icons.alt_route),
            label: const Text("Choisir un itinéraire"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 32),
          const Text("Alertes à proximité", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_incidents.isEmpty)
            const Text("Aucune alerte signalée récemment.")
          else
            Column(
              children: _incidents.map((incident) {
                final type = incident['type'];
                final time = "il y a quelques min";
                final coords = "Lat: ${incident['lat']}, Lng: ${incident['lng']}";

                return Card(
                  child: ListTile(
                    leading: Icon(
                      type == "Accident" ? Icons.warning :
                      type == "Bouchon" ? Icons.traffic :
                      Icons.report,
                      color: Colors.deepOrange,
                    ),
                    title: Text(type),
                    subtitle: Text(coords + " • $time"),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
          BottomNavigationBarItem(icon: Icon(Icons.alt_route), label: "Itinéraire"),
        ],
      ),
    );
  }
}