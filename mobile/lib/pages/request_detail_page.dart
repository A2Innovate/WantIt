import 'dart:async';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/stores/pusher.dart';
import 'package:pusher_client_socket/channels/channel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../stores/client.dart';
import '../stores/currencies.dart';
import '../types/comment.dart';
import '../types/offer.dart';
import '../types/request.dart';
import '../utils/global.dart';
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
  int? _currentUserId;
  Channel? _pusherChannel;
  bool _loadFailed = false;

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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.data['message'] ?? 'Network error'),
            ),
          );
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.response?.data['message'] ?? 'Network error'),
          ),
        );
      }
    }
  }

  Future<void> _loadRequest() async {
    try {
      final response = await useApi().get('/request/${widget.requestId}');
      if (response.statusCode == 200) {
        final request = Request.fromJson(response.data);
        if (mounted) {
          setState(() {
            _request = request;
            _conversionFuture = _loadCurrencyAndConvert(request);
            _loadFailed = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _loadFailed = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load request details')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadFailed = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load request details')),
        );
      }
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

    _pusherChannel = usePusher().subscribe(
      'public-request-${widget.requestId}',
    );
    _pusherChannel?.bind('new-offer', (event) {
      setState(() {
        _request?.offers?.add(Offer.fromJson(event));
      });
    });
    _pusherChannel?.bind('update-offer', (event) {
      setState(() {
        final int? id = event['id'] as int?;
        final offer = _request?.offers?.firstWhereOrNull(
          (offer) => offer.id == id,
        );
        if (offer != null) {
          setState(() {
            offer.applyPartialUpdate(event);
          });
        }
      });
    });
    _pusherChannel?.bind('delete-offer', (event) {
      setState(() {
        final int? id = event as int?;
        _request?.offers?.removeWhere((offer) => offer.id == id);
      });
    });
    _pusherChannel?.bind('update-offer-images', (event) {
      final int? id = event['offerId'] as int?;
      final offer = _request?.offers?.firstWhereOrNull(
        (offer) => offer.id == id,
      );
      if (offer != null) {
        setState(() {
          offer.images.addAll(
            event['images'].map<ImageData>((image) {
              return ImageData(name: image);
            }).toList(),
          );
        });
      }
    });
    _pusherChannel?.bind('delete-offer-images', (event) {
      final int? id = event['offerId'] as int?;
      final offer = _request?.offers?.firstWhereOrNull(
        (offer) => offer.id == id,
      );
      if (offer != null) {
        final images = event['images'].map((image) => image as String).toList();
        setState(() {
          offer.images = offer.images
              .where((image) => !images.contains(image.name))
              .toList();
        });
      }
    });
    _pusherChannel?.bind('update-request', (event) {
      setState(() {
        _request?.applyPartialUpdate(event);
      });
    });
    _pusherChannel?.bind('new-offer-comment', (event) {
      Comment comment = Comment.fromJson(event);
      final offer = _request?.offers?.firstWhereOrNull(
        (offer) => offer.id == comment.offerId,
      );
      if (offer != null) {
        setState(() {
          offer.comments.add(comment);
        });
      }
    });
    _pusherChannel?.bind('update-offer-comment', (event) {
      final int? id = event['offerId'] as int?;
      final int? commentId = event['commentId'] as int?;

      final offer = _request?.offers?.firstWhereOrNull(
        (offer) => offer.id == id,
      );
      if (offer != null) {
        final comment = offer.comments.firstWhereOrNull(
          (comment) => comment.id == commentId,
        );
        if (comment != null) {
          setState(() {
            comment.applyPartialUpdate(event);
          });
        }
      }
    });
    _pusherChannel?.bind('delete-offer-comment', (event) {
      final int? id = event['offerId'] as int?;
      final int? commentId = event['commentId'] as int?;

      final offer = _request?.offers?.firstWhereOrNull(
        (offer) => offer.id == id,
      );
      if (offer != null) {
        final comment = offer.comments.firstWhereOrNull(
          (comment) => comment.id == commentId,
        );
        if (comment != null) {
          setState(() {
            offer.comments.remove(comment);
          });
        }
      }
    });
    _pusherChannel?.bind(
      'delete-request',
      (requestId) => {
        if (mounted) {Navigator.of(context).pop(true)},
      },
    );
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
    _pusherChannel?.unsubscribe();
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

    List<Offer> offers = List.from(_request!.offers!);

    switch (_selectedSort) {
      case 'newest_first':
        offers.sort(
          (a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
        );
        break;
      case 'oldest_first':
        offers.sort(
          (a, b) => (a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
        );
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
      _currentUserId = prefs.getInt('userId');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loadFailed) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Request Detail'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: Center(child: Text("Can't find request ${widget.requestId}")),
      );
    }
    if (_request == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final request = _request!;
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
                                  initialCenter:
                                      request.location ?? LatLng(0, 0),
                                  initialZoom: _zoom,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.wantit.mobile',
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
                                        color: Colors.blue.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderStrokeWidth: 2,
                                        borderColor: Colors.blue,
                                        radius: metersToPixels(
                                          request.radius ?? 5000,
                                          request.location?.latitude ?? 0,
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
                            if (_currentUserId == request.user.id) ...[
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
