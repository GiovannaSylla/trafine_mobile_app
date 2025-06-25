import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SignalementPage extends StatefulWidget {
  const SignalementPage({super.key});

  @override
  State<SignalementPage> createState() => _SignalementPageState();
}

class _SignalementPageState extends State<SignalementPage> {
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedType = 'Accident';
  LatLng? _selectedLocation;
  DateTime? _selectedDateTime;

  final List<String> _incidentTypes = [
    'Accident',
    'Embouteillage',
    'Travaux',
    'Route barrée',
    'Danger sur la route',
    'Autre'
  ];

  GoogleMapController? _mapController;

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _envoyerSignalement() {
    if (_descriptionController.text.isEmpty || _selectedLocation == null || _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Merci de compléter tous les champs."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    print("Type: $_selectedType");
    print("Description: ${_descriptionController.text}");
    print("Date/Heure: $_selectedDateTime");
    print("Position: ${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Signalement envoyé avec succès !"),
        backgroundColor: Colors.green,
      ),
    );

    _descriptionController.clear();
    setState(() {
      _selectedLocation = null;
      _selectedType = 'Accident';
      _selectedDateTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String dateTimeText = _selectedDateTime != null
        ? "${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} à ${_selectedDateTime!.hour}h${_selectedDateTime!.minute.toString().padLeft(2, '0')}"
        : "Sélectionner la date et l’heure";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Signaler un incident'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Type d’incident", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: _incidentTypes
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedType = value!),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            const Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Décrivez l’incident…',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Date et heure de l’incident", style: TextStyle(fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: _selectDateTime,
              icon: const Icon(Icons.calendar_today),
              label: Text(dateTimeText),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            ),
            const SizedBox(height: 20),
            const Text("Choisir l’emplacement sur la carte", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 250,
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(48.8566, 2.3522),
                  zoom: 12,
                ),
                onMapCreated: (controller) => _mapController = controller,
                onTap: _onMapTap,
                markers: _selectedLocation != null
                    ? {
                  Marker(markerId: const MarkerId('incident'), position: _selectedLocation!)
                }
                    : {},
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: _envoyerSignalement,
                icon: const Icon(Icons.send),
                label: const Text("Envoyer le signalement"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}