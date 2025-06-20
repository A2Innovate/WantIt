import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:mobile/pages/persistent_search_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/global.dart';
import '../api/currencies.dart';

class RequestDetailPage extends StatefulWidget {
  final Request request;
  const RequestDetailPage({super.key, required this.request});

  @override
  _RequestDetailPageState createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> {

  late final convertedAmount;
  late final preferredCurrency;

  @override
  void initState() {
    super.initState();
    _loadCurrencyAndConvert();


  }

  Future<void> _loadCurrencyAndConvert() async {
    final prefs = await SharedPreferences.getInstance();
    final currencyStr = prefs.getString('preferredCurrency');
    if (currencyStr == null) return;

    final currency = Currency.values.byName(currencyStr);
    final result = await convert_currency(
      widget.request.currency,
      currency,
      widget.request.budget,
    );

    setState(() {
      preferredCurrency = currency;
      convertedAmount = result;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Detail')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Request',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 200,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: widget.request.location!,
                    initialZoom: 13,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.yourapp',
                      errorTileCallback: (title, error, stackTrace) {
                        setState(() {
                          // isGlobal = true;
                          // fieldErrors['errorLocation'] = 'Unable to load map';
                        });
                      },
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
                            13,
                            // mapZoom,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerLeft, // align left inside full width
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment
                      .start, // left align texts inside column
                  children: [
                    Text(
                      widget.request.content,
                      style: const TextStyle(fontSize: 16),
                    ),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: formatCurrency(widget.request.budget, widget.request.currency),
                          ),
                          TextSpan(
                            text: ' (≈ ${formatCurrency(
                              double.parse(convertedAmount!.toStringAsFixed(2)),
                              preferredCurrency!,
                            )})',
                            style: const TextStyle(
                              fontSize: 12, // smaller text for the converted value
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
