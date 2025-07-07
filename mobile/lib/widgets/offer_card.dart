import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mobile/pages/profile.dart';
import 'package:mobile/schemas/comments.dart';
import 'package:mobile/types/offer.dart';
import 'package:provider/provider.dart';

import 'package:mobile/utils/extensions.dart';
import '../providers/user_provider.dart';
import '../stores/client.dart';
import '../stores/currencies.dart';
import '../types/request.dart';
import '../utils/global.dart';
import 'comment_card.dart';
import 'converted_budget.dart';
import 'edit_offer_modal.dart';
import '../api_config.dart';

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
  Map<String, String?> fieldErrors = {};

  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _conversionFuture = _loadCurrencyAndConvert(widget.request);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<(Currency, double)?> _loadCurrencyAndConvert(Request request) async {
    final current = Provider.of<UserProvider>(context, listen: false).current;
    if (current == null) return null;

    final result = await convertCurrency(
      request.currency,
      current.preferredCurrency,
      widget.offer.price,
    );

    return (current.preferredCurrency, result);
  }

  Future<void> _onDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.translate("confirm_deletion")),
          content: Text(context.translate("deletion_confirmation_offer")),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.translate("cancel")),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                context.translate("delete"),
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;

    final current = Provider.of<UserProvider>(context, listen: false).current;
    bool isAdmin =
        ((current?.isAdmin ?? false) && (widget.offer.user.id != current?.id));
    try {
      final response = await useApi().delete(
        '/request/${widget.request.id}/offer/${widget.offer.id}',
        queryParameters: {if (isAdmin) 'pretendUser': widget.offer.user.id},
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
            content: Text(
              (e.response?.data is Map<String, dynamic>)
                  ? context.translate(
                      e.response?.data['message'] ?? 'unknown_error',
                    )
                  : context.translate('network_error'),
            ),
          ),
        );
        widget.onChanged?.call(false);
      }
    }
  }

  Future<void> _onEdit() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) => EditOfferModal(
        offer: widget.offer,
        request: widget.request,
        onChanged: () {
          widget.onChanged?.call(true);
        },
      ),
    );
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
            content: Text(
              (e.response?.data is Map<String, dynamic>)
                  ? context.translate(
                      e.response?.data['message'] ?? 'unknown_error',
                    )
                  : context.translate('network_error'),
            ),
          ),
        );
      }
      widget.onChanged?.call(false);
    }
  }

  Future<void> _onPost() async {
    setState(() {
      fieldErrors = {};
    });
    final formData = {
      'content': _commentController.text.trim(),
      'offerId': widget.offer.id,
    };
    final result = await addCommentSchema.tryParseAsync(formData);
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
        final response = await useApi().post('/comment', data: formData);
        if (response.statusCode == 200) {
          if (mounted) {
            widget.onChanged?.call(true);
          }
        }
      } on DioException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                (e.response?.data is Map<String, dynamic>)
                    ? context.translate(
                        e.response?.data['message'] ?? 'unknown_error',
                      )
                    : context.translate('network_error'),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
    final isAccepted = widget.request.acceptedOffer?.offerId == widget.offer.id;
    final current = Provider.of<UserProvider>(context).current;
    final isOfferOwnerOrAdmin =
        current != null &&
        (current.id == widget.offer.user.id || (current.isAdmin ?? false));

    return Card(
      elevation: 4,
      color: Theme.of(context).scaffoldBackgroundColor,
      margin: const EdgeInsets.symmetric(vertical: 8),
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
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProfilePage(userId: offer.user.id),
                      ),
                    );
                  },
                  child: Text(
                    '@${offer.user.username}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                if (offer.negotiation)
                  Chip(
                    label: Text(
                      context.translate('negotiation'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    backgroundColor: Colors.green.shade100,
                  )
                else
                  Chip(label: Text(context.translate('no_negotiation'))),
              ],
            ),

            const SizedBox(height: 12),

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
                          '${ApiConfig.s3Endpoint}/${ApiConfig.s3Bucket}/request/${offer.requestId}/offer/${offer.id}/images/${image.name}';
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
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                ],
              ),

            const SizedBox(height: 12),

            Text(offer.content, style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (widget.request.user.id == current?.id &&
                    widget.request.acceptedOffer?.offerId == offer.id)
                  ElevatedButton.icon(
                    onPressed: _onAcceptOrRevert,
                    icon: const Icon(Icons.cancel),
                    label: Text(context.translate('revert_acceptance')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant,
                    ),
                  )
                else if (widget.request.user.id == current?.id &&
                    widget.request.acceptedOffer == null)
                  ElevatedButton.icon(
                    onPressed: _onAcceptOrRevert,
                    icon: const Icon(Icons.check),
                    label: Text(context.translate('accept')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant,
                    ),
                  ),

                if (isOfferOwnerOrAdmin) ...[
                  ElevatedButton.icon(
                    onPressed: _onEdit,
                    icon: const Icon(Icons.edit),
                    label: Text(context.translate('edit')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _onDelete,
                    icon: const Icon(Icons.delete),
                    label: Text(context.translate('delete')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[100],
                      foregroundColor: Colors.red[800],
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),

            ConvertedBudgetText(
              budget: (offer.price as num).toDouble(),
              baseCurrency: widget.request.currency,
              future: _conversionFuture,
            ),

            const SizedBox(height: 12),

            if (current != null)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: context.translate('add_comment'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        errorText: fieldErrors['content'],
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
                      onPressed: _onPost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant,
                      ),
                      child: Text(context.translate('send')),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            ...offer.comments.map(
              (comment) => CommentCard(
                comment: comment,
                onChanged: () {
                  widget.onChanged?.call(true);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
