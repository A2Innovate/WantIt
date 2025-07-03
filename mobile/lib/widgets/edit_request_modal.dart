import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/widgets/local_global_toggle.dart';
import 'package:provider/provider.dart';

import 'package:mobile/utils/extensions.dart';
import '../stores/client.dart';
import '../schemas/request.dart';
import '../types/request.dart';
import '../utils/global.dart';

class EditRequestModal extends StatefulWidget {
  final Request request;
  const EditRequestModal({super.key, required this.request});

  @override
  State<EditRequestModal> createState() => _EditRequestModalState();
}

class _EditRequestModalState extends State<EditRequestModal> {
  final TextEditingController contentController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();
  final MapController mapController = MapController();
  late final StreamSubscription<MapEvent> _mapSub;

  Map<String, String?> fieldErrors = {};

  LatLng pickedLocation = const LatLng(37.78, -122.419);
  double sliderValue = 3000;
  double mapZoom = 13.0;

  bool isGlobal = false;
  Currency selectedCurrency = Currency.USD;

  Future<void> _editRequest() async {
    setState(() {
      fieldErrors = {};
    });
    final budget = int.tryParse(budgetController.text) ?? 0;
    final formData = {
      'content': contentController.text.trim(),
      'budget': budget,
      if (!isGlobal)
        'location': {
          'x': pickedLocation.longitude,
          'y': pickedLocation.latitude,
        },
      if (!isGlobal) 'radius': sliderValue,
      'currency': selectedCurrency.symbol.toString(),
    };
    final result = await createAndEditRequestSchema.tryParseAsync(formData);
    if (!result.success) {
      final errors = <String, String?>{};
      for (final err in result.errors.entries) {
        errors[err.key] = context.translate(
          Map<String, String>.from(err.value).values.first,
        );
      }
      setState(() {
        fieldErrors = errors;
      });
    } else {
      try {
        final current = Provider.of<UserProvider>(
          context,
          listen: false,
        ).current;
        bool isAdmin =
            ((current?.isAdmin ?? false) &&
            (widget.request.user.id != current?.id));

        final response = await useApi().put(
          '/request/${widget.request.id}',
          data: formData,
          queryParameters: {if (isAdmin) 'pretendUser': widget.request.user.id},
          options: Options(
            sendTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );
        if (response.statusCode == 200) {
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        } else {
          setState(() {
            fieldErrors['error'] = (response.data is Map<String, dynamic>)
                ? (response.data['message'] ??
                      context.translate("unknown_error"))
                : context.translate("network_error");
          });
        }
      } on DioException catch (e) {
        setState(() {
          fieldErrors['error'] = (e.response?.data is Map<String, dynamic>)
              ? (e.response?.data['message'] ??
                    context.translate("unknown_error"))
              : context.translate("network_error");
        });
      }
    }
  }

  @override
  void initState() {
    isGlobal = widget.request.location == null;
    if (isGlobal) {
      pickedLocation = const LatLng(37.78, -122.419);
      sliderValue = 3000;
    } else {
      pickedLocation = widget.request.location!;
      sliderValue = widget.request.radius!;
    }
    contentController.text = widget.request.content;
    budgetController.text = widget.request.budget.toString();
    selectedCurrency = widget.request.currency;
    _mapSub = mapController.mapEventStream.listen((event) {
      final newZoom = event.camera.zoom;
      if (newZoom != mapZoom) {
        setState(() {
          mapZoom = newZoom;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    contentController.dispose();
    budgetController.dispose();
    _mapSub.cancel();

    super.dispose();
  }

  String formatRadius(double r) {
    if (r >= 1000) {
      return '${(r / 1000).toStringAsFixed(1)} km';
    } else {
      return '${r.round()} m';
    }
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
              Center(
                child: Text(
                  context.translate("edit_request"),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                context.translate("location"),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Center(
                child: LocalGlobalToggle(
                  initialValue: isGlobal,
                  onChanged: (value) {
                    setState(() {
                      isGlobal = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 8),

              if (fieldErrors.containsKey('errorLocation'))
                Text(
                  fieldErrors['errorLocation']!,
                  style: const TextStyle(color: Colors.red),
                ),
              if (!isGlobal)
                SizedBox(
                  height: 200,
                  child: FlutterMap(
                    mapController: mapController,
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
                        userAgentPackageName: 'com.wantit.mobile',
                        errorTileCallback: (title, error, stackTrace) {
                          setState(() {
                            isGlobal = true;
                            fieldErrors['errorLocation'] = context.translate(
                              "unable_to_load_map",
                            );
                          });
                        },
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

              Text(
                context.translate("request_details"),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: contentController,
                decoration: InputDecoration(
                  labelText: 'What do you want?',
                  border: OutlineInputBorder(),
                  errorText: fieldErrors['content'],
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: budgetController,
                decoration: InputDecoration(
                  labelText: 'Budget',
                  border: OutlineInputBorder(),
                  errorText: fieldErrors['budget'],
                ),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 12),

              Text(
                selectedCurrency.symbol,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _editRequest,
                  child: Text(context.translate("edit_request")),
                ),
              ),
              if (fieldErrors.containsKey('error'))
                Text(
                  fieldErrors['error']!,
                  style: const TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
