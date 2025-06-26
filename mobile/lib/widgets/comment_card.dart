import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/schemas/comments.dart';
import 'package:mobile/types/comment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../stores/client.dart';

class CommentCard extends StatefulWidget {
  final Comment comment;
  final VoidCallback? onChanged;

  const CommentCard({super.key, required this.comment, this.onChanged});
  @override
  _CommentCardState createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  bool isEditing = false;
  int? _currentUserId;
  final editCommentController = TextEditingController();
  Map<String, String?> fieldErrors = {};

  Future<void> _onDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this comment?'),
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
        '/comment/${widget.comment.id.toString()}',
      );
      if (response.statusCode == 200) {
        if (mounted) {
          widget.onChanged?.call();
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

  Future<void> _onEdit() async {
    setState(() {
      fieldErrors = {};
    });
    if (isEditing) {
      final formData = {'content': editCommentController.text.trim()};
      final result = await editCommentSchema.tryParseAsync(formData);
      if (!result.success) {
        final errors = <String, String?>{};
        for (final err in result.errors.entries) {
          errors[err.key] = Map<String, String>.from(err.value).values.first;
        }
        setState(() {
          fieldErrors = errors;
        });
        return;
      } else {
        try {
          final response = await useApi().put(
            '/comment/${widget.comment.id}',
            data: formData,
          );
          if (response.statusCode == 200) {
            if (mounted) {
              widget.onChanged?.call();
            }
          }
        } on DioException catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.response?.data['message'] ?? 'Network error'),
              ),
            );
            return;
          }
        }
      }
    }
    if (mounted) {
      setState(() {
        isEditing = !isEditing;
      });
    }
  }

  @override
  void dispose() {
    editCommentController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getInt('userId');
    });
  }

  @override
  initState() {
    super.initState();
    _loadCurrentUserId();
    editCommentController.text = widget.comment.content;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(
        0xFFFDF6E3,
      ), // Light cream background to match the screenshot
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Username + Time Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '@${widget.comment.user.username}',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  timeago.format(widget.comment.createdAt),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),

            const SizedBox(height: 8),

            if (isEditing)
              TextField(
                controller: editCommentController,
                decoration: InputDecoration(
                  // labelText: 'Edit Comment',
                  errorText: fieldErrors['content'],
                ),
              ),
            if (!isEditing)
              Text(
                widget.comment.content,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),

            if (widget.comment.edited != null && widget.comment.edited!)
              Text(
                'Edited',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),

            const SizedBox(height: 16),

            if (_currentUserId == widget.comment.user.id)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: _onEdit,
                    icon: const Icon(Icons.edit, size: 16),
                    label: Text(isEditing ? "Save" : "Edit"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Colors.black26),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _onDelete,
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Colors.black26),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      textStyle: const TextStyle(fontSize: 14),
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
