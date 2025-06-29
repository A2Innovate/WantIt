import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'package:mobile/stores/client.dart';
import 'package:mobile/pages/sign_in.dart';
import 'package:mobile/schemas/auth.dart';
import 'package:mobile/utils/extensions.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  Map<String, String?> fieldErrors = {};

  @override
  void initState() {
    super.initState();
  }

  Future<void> _onSignUp() async {
    setState(() {
      fieldErrors = {};
      _loading = true;
    });

    final formData = {
      'name': _nameCtrl.text.trim(),
      'username': _usernameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'password': _passCtrl.text.trim(),
    };

    final result = await signUpSchema.tryParseAsync(formData);

    if (result.success) {
      try {
        final response = await useApi().post(
          '/auth/register',
          data: formData,
          options: Options(
            sendTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );
        if (response.statusCode == 200) {
          if (mounted) {
            Navigator.of(context).pop();
          }
        } else {
          setState(() {
            fieldErrors['login'] = context.translate(
              response.data['message'] ?? 'sign_up_failed',
            );
          });
        }
      } on DioException catch (e) {
        setState(() {
          fieldErrors['login'] = (e.response?.data is Map<String, dynamic>)
              ? context.translate(
                  e.response?.data['message'] ?? 'unknown_error',
                )
              : context.translate('network_error');
        });
      }
    } else {
      final errors = <String, String?>{};
      for (final err in result.errors.entries) {
        errors[err.key] = Map<String, String>.from(
          err.value,
        ).values.first; // You can translate if needed here
      }
      setState(() {
        fieldErrors = errors;
      });
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = (String key) => FlutterI18n.translate(context, key);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text(t('sign_up')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 32),
                Text(
                  t('create_an_account'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: t('name'),
                    prefixIcon: const Icon(Icons.account_box_outlined),
                    errorText: fieldErrors['name'],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usernameCtrl,
                  decoration: InputDecoration(
                    labelText: t('username'),
                    prefixIcon: const Icon(Icons.account_circle_outlined),
                    errorText: fieldErrors['username'],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: InputDecoration(
                    labelText: t('email'),
                    prefixIcon: const Icon(Icons.email_outlined),
                    errorText: fieldErrors['email'],
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: t('password'),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    errorText: fieldErrors['password'],
                  ),
                ),
                if (fieldErrors['login'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      fieldErrors['login']!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _loading ? null : _onSignUp,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : Text(t('sign_up')),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(t('back_to_home')),
                    ),
                    TextButton(
                      onPressed: () async {
                        await Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const SignInPage()),
                        );
                      },
                      child: Text(t('already_have_an_account')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
