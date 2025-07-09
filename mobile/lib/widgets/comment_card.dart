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
  State<CommentCard> createState() => _CommentCardState();
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
    final theme = Theme.of(context);
    final current = Provider.of<UserProvider>(context).current;
    bool isCommentOwnerOrAdmin =
        (current != null && current.id == widget.comment.user.id) ||
        (current?.isAdmin ?? false);
    final currentLocale = FlutterI18n.currentLocale(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.scaffoldBackgroundColor,
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
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                    fontSize: 14,
                  ),
                ),
                Text(
                  timeago.format(
                    widget.comment.createdAt,
                    locale: currentLocale!.languageCode,
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            if (isEditing)
              TextField(
                controller: editCommentController,
                decoration: InputDecoration(
                  errorText: fieldErrors['content'],
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  errorStyle: TextStyle(color: theme.colorScheme.error),
                ),
                style: theme.textTheme.bodyMedium,
              ),
            if (!isEditing)
              Text(
                widget.comment.content,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),

            if (widget.comment.edited != null && widget.comment.edited!)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  context.translate("edited"),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            if (isCommentOwnerOrAdmin)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: _onEdit,
                    icon: Icon(
                      Icons.edit,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    label: Text(
                      isEditing
                          ? context.translate("save")
                          : context.translate("edit"),
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _onDelete,
                    icon: Icon(
                      Icons.delete,
                      size: 16,
                      color: theme.colorScheme.error,
                    ),
                    label: Text(
                      context.translate("delete"),
                      style: TextStyle(color: theme.colorScheme.error),
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
