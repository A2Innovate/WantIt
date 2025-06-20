import 'dart:math'; // for cos, pi, pow
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/widgets/currency_dropdown.dart';
import 'package:mobile/widgets/local_global_toggle.dart';

import '../utils/global.dart';

class CreateRequestModal extends StatefulWidget {
  const CreateRequestModal({super.key});

  @override
  State<CreateRequestModal> createState() => _CreateRequestModalState();
}

class _CreateRequestModalState extends State<CreateRequestModal> {
  final TextEditingController contentController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();

  LatLng pickedLocation = LatLng(51.5074, -0.1278);
  double sliderValue = 3000;
  final double mapZoom = 13.0;

  bool isGlobal = true;
  Currency selectedCurrency = Currency.USD;

  @override
  void dispose() {
    contentController.dispose();
    budgetController.dispose();
    super.dispose();
  }

  String formatRadius(double r) {
    if (r >= 1000) {
      return '${(r / 1000).toStringAsFixed(1)} km';
    } else {
      return '${r.round()} m';
    }
  }

  /// Converts meters to pixels at the given latitude and zoom level.
  double metersToPixels(double meters, double latitude, double zoom) {
    final earthCircumference = 40075017.0; // in meters
    final latitudeRadians = latitude * (pi / 180);
    final metersPerPixel =
        earthCircumference * cos(latitudeRadians) / (256 * pow(2, zoom));
    return meters / metersPerPixel;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'New Request',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Location',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Center(
                child: LocalGlobalToggle(
                  initialValue: false,
                  onChanged: (value) {
                    setState(() {
                      isGlobal = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 8),

              if (!isGlobal)
                SizedBox(
                  height: 200,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: pickedLocation,
                      initialZoom: mapZoom,
                      onTap: (tapPosition, point) {
                        setState(() {
                          pickedLocation = point;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.yourapp',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            key: ValueKey(pickedLocation),
                            point: pickedLocation,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            key: ValueKey(pickedLocation),
                            point: pickedLocation,
                            color: Colors.blue.withValues(alpha: (0.2)),
                            borderStrokeWidth: 2,
                            borderColor: Colors.blue,
                            radius: metersToPixels(
                              sliderValue,
                              pickedLocation.latitude,
                              mapZoom,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              if (!isGlobal)
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        min: 3000,
                        max: 1000000,
                        divisions: 100,
                        value: sliderValue,
                        label: formatRadius(sliderValue),
                        onChanged: (value) {
                          setState(() {
                            sliderValue = value;
                          });
                        },
                      ),
                    ),

                    Text(formatRadius(sliderValue)),
                  ],
                ),

              const SizedBox(height: 16),

              const Text(
                'Request Details',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'What do you want?',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: budgetController,
                decoration: const InputDecoration(
                  labelText: 'Budget',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 12),

              CurrencyDropdown(
                selectedCurrency: selectedCurrency,
                errorText: 'Please select a currency',
                onChanged: (currency) {
                  setState(() {
                    selectedCurrency = currency!;
                  });
                },
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final content = contentController.text;
                    final budget = int.tryParse(budgetController.text) ?? 0;
                    final location = pickedLocation;

                    if (content.isEmpty || budget <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please fill all fields and pick a location',
                          ),
                        ),
                      );
                      return;
                    }

                    print('Content: $content');
                    print('Budget: $budget');
                    print(
                      'Location: ${location.latitude}, ${location.longitude}',
                    );
                    print('Radius (meters): $sliderValue');

                    Navigator.pop(context);
                  },
                  child: const Text('Add'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
