import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/stores/client.dart';
import 'package:mobile/schemas/auth.dart';

import 'package:mobile/utils/extensions.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  String? _emailError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _validateAndSubmit() async {
    setState(() {
      _emailError = null;
      _loading = true;
    });

    final formData = {'email': _emailCtrl.text.trim()};
    final result = await requestPasswordResetSchema.tryParseAsync(formData);

    if (result.success) {
      try {
        final response = await useApi().post(
          '/auth/request-password-reset',
          data: formData,
          options: Options(
            sendTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );

        if (response.statusCode == 200 && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.translate("reset_link_sent")),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else {
          setState(() {
            _emailError = (response.data is Map<String, dynamic>)
                ? context.translate(response.data['message'] ?? 'unknown_error')
                : context.translate('network_error');
          });
        }
      } on DioException catch (e) {
        setState(() {
          _emailError = (e.response?.data is Map<String, dynamic>)
              ? context.translate(
                  context.translate(
                    e.response?.data['message'] ?? 'unknown_error',
                  ),
                )
              : context.translate('network_error');
        });
      }
    } else {
      setState(() {
        _emailError = Map<String, String>.from(
          result.errors['email'] ?? {},
        ).values.firstOrNull;
        _emailError = context.translate(_emailError ?? 'unknown_error');
      });
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate("reset_password")),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  context.translate("reset_password"),
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(context.translate("reset_password_desc")),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    errorText: _emailError,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _loading ? null : _validateAndSubmit,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(context.translate("send_reset_link")),
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
