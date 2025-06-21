import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/client.dart';
import '../api/currencies.dart';
import '../utils/global.dart';
import '../pages/persistent_search_page.dart';
import '../widgets/converted_budget.dart';
import '../widgets/edit_request_modal.dart';

class RequestDetailPage extends StatefulWidget {
  Request request;
  final VoidCallback? onChanged;
  RequestDetailPage({super.key, required this.request, this.onChanged});

  @override
  _RequestDetailPageState createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> {
  late Future<(Currency, double)?> _conversionFuture;
  final MapController _mapController = MapController();
  late final StreamSubscription<MapEvent> _mapSub;
  String? _currentUsername;

  String? _selectedSort = 'newest_first';

  double _zoom = 13;

  Future<void> _onDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
            'Are you sure you want to delete this request? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;

    try {
      final response = await useApi().delete('/request/${widget.request.id}');
      if (response.statusCode == 200) {
        if (mounted) {
          widget.onChanged?.call();
          Navigator.of(context).pop(true);
        }
      } else {
        print(response.data);
      }
    } on DioException catch (e) {
      print(e.message);
    }
  }

  Future<void> _reloadRequest() async {
    final response = await useApi().get('/request/${widget.request.id}');
    if (response.statusCode == 200) {
      setState(() {
        widget.request = Request.fromJson(response.data);
        _conversionFuture = _loadCurrencyAndConvert();
      });
    }
  }

  Future<void> _onEdit() async {
    final result = await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) => EditRequestModal(request: widget.request),
    );
    if (result != null && result) {
      await _reloadRequest();
      widget.onChanged?.call();
    }
  }

  @override
  void initState() {
    super.initState();
    _conversionFuture = _loadCurrencyAndConvert();
    _loadCurrentUserId();

    _mapSub = _mapController.mapEventStream.listen((event) {
      final newZoom = event.camera.zoom;
      if (newZoom != _zoom) {
        setState(() {
          _zoom = newZoom;
        });
      }
    });
  }

  @override
  void dispose() {
    _mapSub.cancel();
    super.dispose();
  }

  Future<(Currency, double)?> _loadCurrencyAndConvert() async {
    final prefs = await SharedPreferences.getInstance();
    final currencyStr = prefs.getString('preferredCurrency');
    if (currencyStr == null) return null;

    final currency = Currency.values.byName(currencyStr);
    final result = await convertCurrency(
      widget.request.currency,
      currency,
      widget.request.budget,
    );

    return (currency, result);
  }

  Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUsername = prefs.getString('username');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Detail'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 200,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: widget.request.location!,
                              initialZoom: _zoom,
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
                                    key: ValueKey(widget.request.location),
                                    point: widget.request.location!,
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
                                    key: ValueKey(widget.request.location),
                                    point: widget.request.location!,
                                    color: Colors.blue.withValues(alpha: (0.2)),
                                    borderStrokeWidth: 2,
                                    borderColor: Colors.blue,
                                    radius: metersToPixels(
                                      widget.request.radius!,
                                      widget.request.location!.latitude,
                                      _zoom,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.request.content,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ConvertedBudgetText(
                        budget: (widget.request.budget as num).toDouble(),
                        baseCurrency: widget.request.currency,
                        future: _conversionFuture,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (_currentUsername ==
                              widget.request.user.username.toString()) ...[
                            ElevatedButton.icon(
                              onPressed: _onEdit,
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[200],
                                foregroundColor: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: _onDelete,
                              icon: const Icon(Icons.delete),
                              label: const Text('Delete'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[100],
                                foregroundColor: Colors.red[800],
                              ),
                            ),
                          ],
                          const Spacer(),
                          const Icon(Icons.visibility),
                          const SizedBox(width: 4),
                          Text(widget.request.user.username.toString()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  DropdownButton<String>(
                    value: _selectedSort,
                    items: const [
                      DropdownMenuItem(
                        value: 'newest_first',
                        child: Text('Newest first'),
                      ),
                      DropdownMenuItem(
                        value: 'oldest_first',
                        child: Text('Oldest first'),
                      ),
                      DropdownMenuItem(
                        value: 'cheapest_first',
                        child: Text('Cheapest first'),
                      ),
                      DropdownMenuItem(
                        value: 'expensive_first',
                        child: Text('Expensive first'),
                      ),
                    ],
                    onChanged: (val) {
                      // val ??= 'newest_first';
                      setState(() {
                        _selectedSort = val;
                      });
                    },
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text('New offer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
