import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mobile/types/offer.dart';
import 'package:mobile/widgets/new_offer_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/client.dart';
import '../api/currencies.dart';
import '../types/request.dart';
import '../utils/global.dart';
import 'converted_budget.dart';

class OfferCard extends StatefulWidget {
  final Offer offer;
  final Request request;
  final ValueChanged<bool>? onChanged;

  const OfferCard({
    super.key,
    required this.offer,
    required this.request,
    this.onChanged,
  });

  @override
  State<OfferCard> createState() => _OfferCardState();
}

class _OfferCardState extends State<OfferCard> {
  int _current = 0;
  late Future<(Currency, double)?> _conversionFuture;

  @override
  void initState() {
    super.initState();
    _conversionFuture = _loadCurrencyAndConvert(widget.request);
  }

  Future<(Currency, double)?> _loadCurrencyAndConvert(Request request) async {
    final prefs = await SharedPreferences.getInstance();
    final currencyStr = prefs.getString('preferredCurrency');
    if (currencyStr == null) return null;

    final currency = Currency.values.byName(currencyStr);
    final result = await convertCurrency(
      request.currency,
      currency,
      widget.offer.price,
    );

    return (currency, result);
  }

  Future<void> _onDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
            'Are you sure you want to delete this offer? This action cannot be undone.',
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
      final response = await useApi().delete(
        '/request/${widget.request.id}/offer/${widget.offer.id}',
      );
      if (response.statusCode == 200) {
        if (mounted) {
          widget.onChanged?.call(true);
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error deleting offer')));
      }
      widget.onChanged?.call(false);
    }
  }

  Future<void> _onEdit() async {
    // final result = await showModalBottomSheet(
    //   context: context,
    //   shape: const RoundedRectangleBorder(
    //     borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    //   ),
    //   isScrollControlled: true,
    //   builder: (context) => EditOfferModal(offer: widget.offer),
    // );
    // if (result != null && result) {
    //   widget.onChanged?.call(true);
    // }
  }
  Future<void> _onAcceptOrRevert() async {
    try {
      final response = await useApi().post(
        '/request/${widget.request.id}/offer/${widget.offer.id}/accept',
        data: {
          'accepted': widget.request.acceptedOffer?.offerId != widget.offer.id,
        },
      );
      if (response.statusCode == 200) {
        if (mounted) {
          widget.onChanged?.call(true);
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
      widget.onChanged?.call(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
    final isAccepted = widget.request.acceptedOffer?.offerId == widget.offer.id;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: isAccepted ? Colors.green.shade100 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),

        side: isAccepted
            ? const BorderSide(color: Colors.green, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with username and badge
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  child: Text(
                    offer.user.username[0].toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '@${offer.user.username}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (offer.negotiation)
                  Chip(
                    label: Text(
                      'NEGOTIABLE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    backgroundColor: Colors.green.shade100,
                  )
                else
                  const Chip(label: Text('FIXED')),
              ],
            ),

            const SizedBox(height: 12),

            // Carousel with dot indicators
            if (offer.images.isNotEmpty)
              Column(
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 200,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: false,
                      viewportFraction: 0.9,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _current = index;
                        });
                      },
                    ),
                    items: offer.images.map((image) {
                      final imageUrl =
                          'http://172.21.0.2:9000/mybucket/request/${offer.requestId}/offer/${offer.id}/images/${image.name}';
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 100),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 8),

                  if (offer.images.length > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(offer.images.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _current == index ? 12 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _current == index
                                ? Colors.black87
                                : Colors.grey[400],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                ],
              ),

            const SizedBox(height: 12),

            // Offer content
            Text(offer.content, style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 12),

            // Action buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (widget.request.acceptedOffer?.offerId == offer.id)
                  ElevatedButton.icon(
                    onPressed: _onAcceptOrRevert,
                    icon: const Icon(Icons.cancel),
                    label: const Text('Revert acceptance'),
                  )
                else if (widget.request.acceptedOffer == null)
                  ElevatedButton.icon(
                    onPressed: _onAcceptOrRevert,
                    icon: const Icon(Icons.check),
                    label: const Text('Accept'),
                  ),

                ElevatedButton.icon(
                  onPressed: _onEdit,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
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
            ),

            const SizedBox(height: 16),

            ConvertedBudgetText(
              budget: (offer.price as num).toDouble(),
              baseCurrency: widget.request.currency,
              future: _conversionFuture,
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Add comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 80,
                    minHeight: 36,
                  ),
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Send'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
