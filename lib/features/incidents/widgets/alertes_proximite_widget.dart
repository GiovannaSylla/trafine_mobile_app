import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlertesProximiteWidget extends StatefulWidget {
  @override
  _AlertesProximiteWidgetState createState() => _AlertesProximiteWidgetState();
}

class _AlertesProximiteWidgetState extends State<AlertesProximiteWidget> {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_incidents.isEmpty) {
      return Text("Aucune alerte signalée récemment.");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _incidents.map((incident) {
        final String type = incident['type'];
        final double lat = incident['lat'];
        final double lng = incident['lng'];
        final String rue = "Coord: (${lat.toStringAsFixed(3)}, ${lng.toStringAsFixed(3)})";

        return Card(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: Icon(
              type == "Accident" ? Icons.warning :
              type == "Bouchon" ? Icons.traffic :
              type == "Obstacle" ? Icons.block :
              Icons.error,
              color: Colors.deepOrange,
            ),
            title: Text(type),
            subtitle: Text(rue),
            trailing: Text("il y a quelques min"),
          ),
        );
      }).toList(),
    );
  }
}