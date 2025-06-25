import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supmap_clean/features/incidents/signalement_page.dart';
import 'package:supmap_clean/features/itinerary/itinerary_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController _mapController;
  final LatLng _initialPosition = LatLng(48.8566, 2.3522); // Paris par défaut

  // Exemple de markers d'incidents (à remplacer par une vraie liste plus tard)
  final List<Marker> _incidentMarkers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("SUPMAP - Accueil"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              " \nBienvenue sur SUPMAP",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 180,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _initialPosition,
                  zoom: 12,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                markers: Set<Marker>.of(_incidentMarkers),
                myLocationEnabled: false,
                zoomControlsEnabled: true,
                mapType: MapType.normal,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignalementPage()),
                );
              },
              icon: const Icon(Icons.report_problem),
              label: const Text("Signaler un incident"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size.fromHeight(50),
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ItineraryPage()),
                );
              },
              icon: const Icon(Icons.alt_route),
              label: const Text("Choisir un itinéraire"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                minimumSize: const Size.fromHeight(50),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              "Alertes à proximité",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: ListView(
                children: const [
                  _AlertCard(
                    type: "Accident",
                    location: "Rue Lafayette",
                    time: "Il y a 5 min",
                    color: Colors.redAccent,
                    icon: Icons.warning_amber_rounded,
                  ),
                  _AlertCard(
                    type: "Embouteillage",
                    location: "Bd Haussmann",
                    time: "Il y a 10 min",
                    color: Colors.orange,
                    icon: Icons.directions_car_filled,
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

class _AlertCard extends StatelessWidget {
  final String type;
  final String location;
  final String time;
  final Color color;
  final IconData icon;

  const _AlertCard({
    required this.type,
    required this.location,
    required this.time,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(type, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        subtitle: Text("$location • $time"),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {}, // futur lien vers détails
      ),
    );
  }
}