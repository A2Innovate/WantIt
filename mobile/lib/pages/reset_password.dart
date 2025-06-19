import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/api/client.dart';
import 'package:mobile/schemas/auth.dart'; // where your schema is
import 'package:acanthis/acanthis.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  String? _emailError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _validateAndSubmit() async {
    setState(() {
      _emailError = null;
    });

    final formData = {'email': _emailCtrl.text};

    final result = await resetPasswordSchema.tryParseAsync(formData);

    if (result.success) {
      // Proceed with password reset API
      try {
        final response = await useApi().post(
          '/auth/request-password-reset',
          data: formData,
        );
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Reset link sent!')));
        }
      } on DioException catch (e) {
        if (e.response != null) {
          setState(() {
            _emailError = e.response!.data['message'] ?? 'Reset failed';
          });
        }
      }

      // _emailError = response.data['message'] ?? 'Login failed';
    } else {
      // Show error from schema
      setState(() {
        _emailError = Map<String, String>.from(
          result.errors['email'] ?? {},
        ).values.firstOrNull;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Reset Password',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: const OutlineInputBorder(),
                      errorText: _emailError,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _validateAndSubmit,
                    child: const Text('Reset Password'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
