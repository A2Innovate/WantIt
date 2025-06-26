import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:mobile/api_config.dart';

import '../stores/client.dart';
import '../schemas/request.dart';
import '../types/offer.dart';
import '../types/request.dart';

class EditOfferModal extends StatefulWidget {
  final Request request;
  final Offer offer;
  final VoidCallback? onChanged;
  const EditOfferModal({
    super.key,
    required this.request,
    required this.offer,
    this.onChanged,
  });

  @override
  State<EditOfferModal> createState() => _EditOfferModalState();
}

class _EditOfferModalState extends State<EditOfferModal> {
  List<File> _selectedImages = [];
  bool? isNegotiable = false;
  TextEditingController priceController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  final List<String> _imagesToDelete = [];

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

  @override
  initState() {
    super.initState();
    priceController.text = widget.offer.price.toString();
    contentController.text = widget.offer.content;
    isNegotiable = widget.offer.negotiation;
  }

  @override
  void dispose() {
    contentController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> _editOffer() async {
    setState(() {
      fieldErrors = {};
    });
    final price = int.tryParse(priceController.text.trim());
    final formData = {
      'content': contentController.text.trim(),
      if (price != null) 'price': price,
      'negotiation': isNegotiable,
    };
    final result = await createAndEditOfferSchema.tryParseAsync(formData);
    if (!result.success) {
      final errors = <String, String?>{};
      for (final err in result.errors.entries) {
        errors[err.key] = Map<String, String>.from(err.value).values.first;
      }
      setState(() {
        fieldErrors = errors;
      });
    } else {
      if (_selectedImages.length > 10) {
        setState(() {
          fieldErrors["image"] = 'One offer can have up to 10 images.';
        });
        return;
      }
      for (final image in _selectedImages) {
        if (image.lengthSync() > 1024 * 1024 * 5) {
          setState(() {
            fieldErrors["image"] =
                'At least one of your images is too large, max size is 5MB.';
          });

          return;
        }
      }
      try {
        final api = useApi();
        final response = await api.put(
          '/request/${widget.request.id}/offer/${widget.offer.id}',
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

            final imagesResponse = await api.post(
              '/request/${widget.request.id}/offer/${response.data['id']}/image',
              data: formData,
              options: Options(
                sendTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
              ),
            );
            if (imagesResponse.statusCode != 200) {
              setState(() {
                fieldErrors['error'] = imagesResponse.data['message'];
              });
              return;
            }
          }

          if (_imagesToDelete.isNotEmpty) {
            await api.delete(
              '/request/${widget.request.id}/offer/${widget.offer.id}/images',
              data: {'images': _imagesToDelete},
              options: Options(
                sendTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
              ),
            );
          }

          widget.onChanged?.call();
          if (mounted) {
            Navigator.of(context).pop();
          }
        } else {
          setState(() {
            fieldErrors['error'] = response.data['message'];
          });
        }
      } on DioException catch (e) {
        setState(() {
          fieldErrors['error'] = e.response?.data['message'] ?? 'Network error';
        });
      }
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
              const Center(
                child: Text(
                  'Edit Offer',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),

              // Add Image Picker UI
              const Text(
                'Current Images',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              GestureDetector(
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: widget.offer.images.isNotEmpty
                      ? ListView(
                          scrollDirection: Axis.horizontal,
                          children: widget.offer.images.map((file) {
                            final isMarked = _imagesToDelete.contains(
                              file.name,
                            );
                            return Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isMarked
                                            ? Colors.red
                                            : Colors.transparent,
                                        width: 3,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: ColorFiltered(
                                        colorFilter: isMarked
                                            ? ColorFilter.mode(
                                                Colors.red.withValues(
                                                  alpha: 0.2,
                                                ),
                                                BlendMode.srcATop,
                                              )
                                            : const ColorFilter.mode(
                                                Colors.transparent,
                                                BlendMode.multiply,
                                              ),
                                        child: Image.network(
                                          'http://${ApiConfig.s3Endpoint}/${ApiConfig.s3Bucket}/request/${widget.request.id}/offer/${widget.offer.id}/images/${file.name}',
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isMarked) {
                                          _imagesToDelete.remove(file.name);
                                        } else {
                                          _imagesToDelete.add(file.name);
                                        }
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.2,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: Icon(
                                        isMarked ? Icons.undo : Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        )
                      : const Center(child: Text('No current images')),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'New Images',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
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
                      : const Center(child: Text('Tap to select image')),
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
                  labelText: 'What is your offer?',
                  errorText: fieldErrors['content'],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  errorText: fieldErrors['price'],
                ),
                keyboardType: TextInputType.number,
              ),

              Row(
                children: [
                  const Text('Negotiable'),
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
                  onPressed: _editOffer,
                  child: const Text('Save'),
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
    );
  }
}
