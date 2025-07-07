import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mobile/schemas/comments.dart';
import 'package:mobile/types/comment.dart';
import 'package:mobile/utils/extensions.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../providers/user_provider.dart';
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
  final editCommentController = TextEditingController();
  Map<String, String?> fieldErrors = {};

  Future<void> _onDelete() async {
    final current = Provider.of<UserProvider>(context, listen: false).current;
    bool isAdmin =
        ((current?.isAdmin ?? false) &&
        (widget.comment.user.id != current?.id));

    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.translate('confirm_deletion')),
          content: Text(context.translate("deletion_confirmation_comment")),
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

    try {
      final response = await useApi().delete(
        '/comment/${widget.comment.id.toString()}',
        queryParameters: {
          if (isAdmin) 'pretendUser': widget.comment.user.id.toString(),
        },
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

  Future<void> _onEdit() async {
    final current = Provider.of<UserProvider>(context, listen: false).current;
    bool isAdmin =
        ((current?.isAdmin ?? false) &&
        (widget.comment.user.id != current?.id));
    setState(() {
      fieldErrors = {};
    });
    if (isEditing) {
      final formData = {'content': editCommentController.text.trim()};
      final result = await editCommentSchema.tryParseAsync(formData);
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
        return;
      } else {
        try {
          final response = await useApi().put(
            '/comment/${widget.comment.id}',
            data: formData,
            queryParameters: {
              if (isAdmin) 'pretendUser': widget.comment.user.id,
            },
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
                content: Text(
                  (e.response?.data is Map<String, dynamic>)
                      ? context.translate(
                          e.response?.data['message'] ?? 'unknown_error',
                        )
                      : context.translate('network_error'),
                ),
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

  @override
  initState() {
    super.initState();
    editCommentController.text = widget.comment.content;
  }

  @override
  Widget build(BuildContext context) {
    final current = Provider.of<UserProvider>(context).current;
    bool isCommentOwnerOrAdmin =
        (current != null && current.id == widget.comment.user.id) ||
        ((current?.isAdmin ?? false));
    final currentLocale = FlutterI18n.currentLocale(context);

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
                  timeago.format(
                    widget.comment.createdAt,
                    locale: currentLocale!.languageCode,
                  ),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),

            const SizedBox(height: 8),

            if (isEditing)
              TextField(
                controller: editCommentController,
                decoration: InputDecoration(errorText: fieldErrors['content']),
              ),
            if (!isEditing)
              Text(
                widget.comment.content,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),

            if (widget.comment.edited != null && widget.comment.edited!)
              Text(
                context.translate("edited"),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),

            const SizedBox(height: 16),

            if (isCommentOwnerOrAdmin)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: _onEdit,
                    icon: const Icon(Icons.edit, size: 16),
                    label: Text(
                      isEditing
                          ? context.translate("save")
                          : context.translate("edit"),
                    ),
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
                    label: Text(context.translate("delete")),
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
