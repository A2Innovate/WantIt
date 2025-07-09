import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

import 'package:mobile/utils/extensions.dart';
import '../stores/client.dart';
import '../schemas/request.dart';
import '../types/request.dart';

class NewOfferModal extends StatefulWidget {
  final Request request;
  final VoidCallback? onChanged;
  const NewOfferModal({super.key, required this.request, this.onChanged});

  @override
  State<NewOfferModal> createState() => _NewOfferModalState();
}

class _NewOfferModalState extends State<NewOfferModal> {
  List<File> _selectedImages = [];
  bool? isNegotiable = false;
  TextEditingController priceController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  Map<String, String?> fieldErrors = {};

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final List<XFile> pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<void> _createOffer() async {
    setState(() {
      fieldErrors = {};
    });
    final price = int.tryParse(priceController.text.trim()) ?? 0;
    final formData = {
      'content': contentController.text.trim(),
      'price': price,
      'negotiation': isNegotiable,
    };
    final result = await createAndEditOfferSchema.tryParseAsync(formData);
    if (!result.success) {
      final errors = <String, String?>{};
      for (final err in result.errors.entries) {
        print(err.value);
        errors[err.key] = context.translate(
          Map<String, String>.from(err.value).values.first,
        );
      }
      setState(() {
        fieldErrors = errors;
      });
    } else {
      if (_selectedImages.length > 10) {
        setState(() {
          fieldErrors["image"] = context.translate("max_offer_images");
        });
        return;
      }
      for (final image in _selectedImages) {
        if (image.lengthSync() > 1024 * 1024 * 5) {
          setState(() {
            fieldErrors["image"] = context.translate("max_image_size");
          });

          return;
        }
      }
      try {
        final api = useApi();
        final response = await api.post(
          '/request/${widget.request.id}/offer',
          data: formData,
          options: Options(
            sendTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );
        if (response.statusCode == 200) {
          if (_selectedImages.isNotEmpty) {
            final formData = FormData();

            for (final image in _selectedImages) {
              final file = await MultipartFile.fromFile(
                image.path,
                contentType: DioMediaType.parse(lookupMimeType(image.path)!),
              );
              formData.files.add(MapEntry('images[]', file));
            }

            // Post the images
            final imageResponse = await api.post(
              '/request/${widget.request.id}/offer/${response.data['id']}/image',
              data: formData,
              options: Options(
                sendTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
              ),
            );

            if (imageResponse.statusCode != 200) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.translate(
                        imageResponse.data['message'] ?? 'network_error',
                      ),
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            }
          }
          widget.onChanged?.call();
          if (mounted) {
            Navigator.of(context).pop();
          }
        } else {
          setState(() {
            fieldErrors['error'] = (response.data is Map<String, dynamic>)
                ? context.translate(response.data['message'] ?? 'unknown_error')
                : context.translate('network_error');
          });
        }
      } on DioException catch (e) {
        setState(() {
          print(e.response?.data);
          fieldErrors['error'] = (e.response?.data is Map<String, dynamic>)
              ? context.translate(
                  e.response?.data['message'] ?? 'unknown_error',
                )
              : context.translate('network_error');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Card(
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    context.translate('new_offer'),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),

                // Add Image Picker UI
                Text(
                  context.translate('images'),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _selectedImages.isNotEmpty
                        ? ListView(
                            scrollDirection: Axis.horizontal,
                            children: _selectedImages
                                .map(
                                  (file) => Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Image.file(
                                      file,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                                .toList(),
                          )
                        : Center(
                            child: Text(
                              context.translate('tap_to_select_images'),
                            ),
                          ),
                  ),
                ),
                if (fieldErrors.containsKey('image'))
                  Text(
                    fieldErrors['image']!,
                    style: const TextStyle(color: Colors.red),
                  ),

                const SizedBox(height: 16),
                TextFormField(
                  controller: contentController,
                  decoration: InputDecoration(
                    labelText: context.translate('what_is_your_offer'),
                    errorText: fieldErrors['content'],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: context.translate('price'),
                    errorText: fieldErrors['price'],
                  ),
                  keyboardType: TextInputType.number,
                ),

                Row(
                  children: [
                    Text(context.translate('negotiable')),
                    const Spacer(),
                    Checkbox(
                      value: isNegotiable,
                      onChanged: (value) {
                        setState(() {
                          isNegotiable = value;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _createOffer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant,
                    ),
                    child: Text(context.translate('add_offer')),
                  ),
                ),
                const SizedBox(height: 16),
                if (fieldErrors.containsKey('error'))
                  Text(
                    fieldErrors['error']!,
                    style: const TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
