import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadItineraryHistory();
  }

  void _swapLocations() {
    final temp = _departureController.text;
    setState(() {
      _departureController.text = _destinationController.text;
      _destinationController.text = temp;
    });
  }

  Future<void> _saveItinerary(String from, String to) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('itinerary_history') ?? [];

    final newItinerary = jsonEncode({
      'from': from,
      'to': to,
      'date': DateTime.now().toIso8601String()
    });

    history.add(newItinerary);
    await prefs.setStringList('itinerary_history', history);
    _loadItineraryHistory();
  }

  Future<void> _loadItineraryHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('itinerary_history') ?? [];

    setState(() {
      _history = history
          .map((item) {
        try {
          final decoded = jsonDecode(item);
          if (decoded is Map &&
              decoded.containsKey('from') &&
              decoded.containsKey('to') &&
              decoded.containsKey('date')) {
            return Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}
        return null;
      })
          .where((item) => item != null)
          .cast<Map<String, dynamic>>()
          .toList()
          .reversed
          .toList();
    });
  }

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return "${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Planification d’itinéraire"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Planifier un itinéraire",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _departureController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.my_location),
                labelText: 'Point de départ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: IconButton(
                onPressed: _swapLocations,
                icon: const Icon(Icons.swap_vert, size: 30, color: Colors.deepPurple),
                tooltip: "Inverser Départ/Destination",
              ),
            ),
            TextField(
              controller: _destinationController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.place),
                labelText: 'Destination',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final from = _departureController.text;
                  final to = _destinationController.text;

                  if (from.isNotEmpty && to.isNotEmpty) {
                    await _saveItinerary(from, to);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapScreen(
                          departure: from,
                          destination: to,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Veuillez remplir les deux champs.")),
                    );
                  }
                },
                icon: const Icon(Icons.map),
                label: const Text(
                  "Afficher l’itinéraire",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text("Options", style: TextStyle(fontWeight: FontWeight.bold)),
            CheckboxListTile(
              title: const Text("Éviter les péages"),
              value: _avoidTolls,
              onChanged: (value) {
                setState(() {
                  _avoidTolls = value!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text("Chemin le plus rapide"),
              value: _fastestRoute,
              onChanged: (value) {
                setState(() {
                  _fastestRoute = value!;
                });
              },
            ),
            const SizedBox(height: 24),
            const Text("Historique des itinéraires", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _history.isEmpty
                ? const Text("Aucun itinéraire enregistré.")
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final item = _history[index];
                if (!item.containsKey('from') || !item.containsKey('to')) {
                  return const SizedBox();
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapScreen(
                          departure: item['from'],
                          destination: item['to'],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 2,
                    child: ListTile(
                      leading: const Icon(Icons.history),
                      title: Text("${item['from']} ➜ ${item['to']}"),
                      subtitle: Text("Le ${_formatDate(item['date'])}"),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}