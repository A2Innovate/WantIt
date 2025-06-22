import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/client.dart';
import '../api/currencies.dart';
import '../types/offer.dart';
import '../types/request.dart';
import '../utils/global.dart';
import '../pages/persistent_search_page.dart';
import '../widgets/converted_budget.dart';
import '../widgets/edit_request_modal.dart';
import '../widgets/new_offer_modal.dart';
import '../widgets/offer_card.dart';

class RequestDetailPage extends StatefulWidget {
  final int requestId;
  final VoidCallback? onChanged;

  const RequestDetailPage({super.key, required this.requestId, this.onChanged});

  @override
  _RequestDetailPageState createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> {
  late Future<(Currency, double)?> _conversionFuture;
  final MapController _mapController = MapController();
  late final StreamSubscription<MapEvent> _mapSub;
  Request? _request;
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
      final response = await useApi().delete('/request/${widget.requestId}');
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

  Future<void> _loadRequest() async {
    try {
      final response = await useApi().get('/request/${widget.requestId}');
      if (response.statusCode == 200) {
        final request = Request.fromJson(response.data);
        setState(() {
          _request = request;
          _conversionFuture = _loadCurrencyAndConvert(request);
        });
      }
    } catch (e) {
      print('Failed to load request: $e');
    }
  }

  Future<void> _reloadRequest() async {
    final response = await useApi().get('/request/${widget.requestId}');
    if (response.statusCode == 200) {
      setState(() {
        _request = Request.fromJson(response.data);
        _conversionFuture = _loadCurrencyAndConvert(_request!);
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
      builder: (context) => EditRequestModal(request: _request!),
    );
    if (result != null && result) {
      await _reloadRequest();
      widget.onChanged?.call();
    }
  }

  Future<void> _onCreate() async {
    final result = await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) => NewOfferModal(
        request: _request!,
        onChanged: () {
          _loadRequest();
        },
      ),
    );
    if (result != null && result) {
      await _reloadRequest();
      // .call(true);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadRequest();
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

  Future<(Currency, double)?> _loadCurrencyAndConvert(Request request) async {
    final prefs = await SharedPreferences.getInstance();
    final currencyStr = prefs.getString('preferredCurrency');
    if (currencyStr == null) return null;

    final currency = Currency.values.byName(currencyStr);
    final result = await convertCurrency(
      request.currency,
      currency,
      request.budget,
    );

    return (currency, result);
  }

  List<Offer> _getSortedOffers() {
    if (_request?.offers == null) return [];

    List<Offer> offers = List.from(_request!.offers!); // copy

    switch (_selectedSort) {
      case 'newest_first':
        offers.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
        break;
      case 'oldest_first':
        offers.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
        break;
      case 'cheapest_first':
        offers.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'expensive_first':
        offers.sort((a, b) => b.price.compareTo(a.price));
        break;
      default:
        break;
    }

    return offers;
  }

  Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUsername = prefs.getString('username');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_request == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final request = _request!;
    final offers = _getSortedOffers();
    final bool? isAccepted =
        offers.any((o) => o.id == request.acceptedOffer?.offerId) ? true : null;

    // bool? isAccepted =;
    // if (isAccepted == null) {
    //   isAccepted = request.acceptedOffer != null;
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        if (request.location != null)
                          SizedBox(
                            height: 200,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  initialCenter: request.location!,
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
                                        key: ValueKey(request.location),
                                        point: request.location!,
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
                                        key: ValueKey(request.location),
                                        point: request.location!,
                                        color: Colors.blue.withOpacity(0.2),
                                        borderStrokeWidth: 2,
                                        borderColor: Colors.blue,
                                        radius: metersToPixels(
                                          request.radius!,
                                          request.location!.latitude,
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
                          request.content,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ConvertedBudgetText(
                          budget: (request.budget as num).toDouble(),
                          baseCurrency: request.currency,
                          future: _conversionFuture,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (_currentUsername ==
                                request.user.username.toString()) ...[
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
                            Text(request.user.username.toString()),
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
                        setState(() {
                          _selectedSort = val;
                        });
                      },
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _onCreate,
                      icon: const Icon(Icons.add),
                      label: const Text('New offer'),
                    ),
                  ],
                ),

                if (request.offers!.isNotEmpty)
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text('Offers'),
                          const Divider(),
                          ..._getSortedOffers().map(
                            (offer) => OfferCard(
                              offer: offer,
                              request: request,
                              onChanged: (value) {
                                _reloadRequest();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
