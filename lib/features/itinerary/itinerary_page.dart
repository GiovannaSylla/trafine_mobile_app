import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_screen.dart';

class ItineraryPage extends StatefulWidget {
  const ItineraryPage({super.key});

  @override
  _ItineraryPageState createState() => _ItineraryPageState();
}

class _ItineraryPageState extends State<ItineraryPage> {
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  bool _avoidTolls = true;
  bool _fastestRoute = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Planification d’itinéraire"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Planifier un itinéraire",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // Champ DEPART
            TextField(
              controller: _departureController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.my_location),
                labelText: 'Point de départ',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),

            // Champ DESTINATION
            TextField(
              controller: _destinationController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.place),
                labelText: 'Destination',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // BOUTON afficher l'itinéraire
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_departureController.text.isNotEmpty && _destinationController.text.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapScreen(
                          departure: _departureController.text,
                          destination: _destinationController.text,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Veuillez remplir les deux champs.")),
                    );
                  }
                },
                icon: Icon(Icons.map),
                label: Text(
                  "Afficher l’itinéraire",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: Size.fromHeight(50),
                ),
              ),
            ),

            SizedBox(height: 24),
            Text("Options", style: TextStyle(fontWeight: FontWeight.bold)),

            CheckboxListTile(
              title: Text("Éviter les péages"),
              value: _avoidTolls,
              onChanged: (value) {
                setState(() {
                  _avoidTolls = value!;
                });
              },
            ),
            CheckboxListTile(
              title: Text("Chemin le plus rapide"),
              value: _fastestRoute,
              onChanged: (value) {
                setState(() {
                  _fastestRoute = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}