import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mobile/stores/client.dart';
import 'package:mobile/stores/pusher.dart';
import 'package:mobile/pages/main_page.dart';
import 'package:mobile/pages/sign_up.dart';
import 'package:mobile/pages/reset_password.dart';
import 'package:mobile/schemas/auth.dart';
import 'package:mobile/widgets/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/message_provider.dart';

class SignInPage extends StatefulWidget {
  Map<String, dynamic>? queryParameters;
  SignInPage({super.key, this.queryParameters});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  Map<String, String?> fieldErrors = {};
  bool _obscurePassword = true;
  bool _loading = false;
  late final Dio dio;

  @override
  void initState() {
    super.initState();
    dio = useApi();
    if (widget.queryParameters != null) {
      switch (widget.queryParameters!['oauth']) {
        case 'google':
          _onGoogleSignIn(true);
          break;
      }
    }
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userData['id']);
    await prefs.setString('username', userData['username']);
    await prefs.setString('name', userData['name']);
    await prefs.setString('email', userData['email']);
    await prefs.setString('currency', userData['preferredCurrency']);
    await prefs.setBool('isAdmin', userData['isAdmin']);
    await prefs.setString('sessionId', userData['sessionId']);
  }

  Future<void> _onLogin() async {
    setState(() {
      fieldErrors = {};
      _loading = true;
    });

    final formData = {
      'email': _emailCtrl.text.trim(),
      'password': _passCtrl.text.trim(),
    };

    final result = await loginSchema.tryParseAsync(formData);

    if (result.success) {
      try {
        final response = await dio.post('/auth/login', data: formData);
        if (response.statusCode == 200) {
          await saveUserData(response.data);
          if (mounted) {
            await initPusher(
              response.data['id'],
              Provider.of<MessagesProvider>(context, listen: false),
            );
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MainPage()),
              );
            }
          }
        } else {
          setState(() {
            fieldErrors['login'] = response.data['message'] ?? 'Login failed';
          });
        }
      } on DioException catch (e) {
        setState(() {
          fieldErrors['login'] = e.response?.data['message'] ?? 'Network error';
        });
      }
    } else {
      final errors = <String, String?>{};
      for (final err in result.errors.entries) {
        errors[err.key] = Map<String, String>.from(err.value).values.first;
      }
      setState(() {
        fieldErrors = errors;
      });
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _onGoogleSignIn(bool queryParameters) async {
    final sharedPrefs = await SharedPreferences.getInstance();
    if (!queryParameters) {
      final response = await useApi().get(
        '/auth/oauth/google',
        queryParameters: {"mobile": true},
      );
      final url = response.data['url'];

      sharedPrefs.setString(
        'pkceCodeVerifier',
        response.data['pkceCodeVerifier'],
      );
      if (response.data.containsKey('state')) {
        sharedPrefs.setString('oauth_state', response.data['state']);
      }
      await launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);
    } else {
      try {
        final pkceCodeVerifier = sharedPrefs.getString('pkceCodeVerifier');
        final state = sharedPrefs.getString('oauth_state');
        final query = {
          'url': (widget.queryParameters?['url'] as String).replaceAll(
            'wantit://auth/google',
            '',
          ),
          'pkce_code_verifier': pkceCodeVerifier,
          'state': state,
        };
        final response = await dio.get(
          '/auth/oauth/google/callback-mobile',
          queryParameters: query,
        );
        response.headers['set-cookie']?.forEach((cookie) {
          print(cookie);
        });

        if (response.statusCode == 200) {
          await saveUserData(response.data);
          if (mounted) {
            await initPusher(
              response.data['id'],
              Provider.of<MessagesProvider>(context, listen: false),
            );
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MainPage()),
              );
            }
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
        // print(e.response?.data!['message']);
        // print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text('Sign In'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 32),
                const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: InputDecoration(
                    labelText: 'Email',
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
                    labelText: 'Password',
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
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _loading ? null : _onLogin,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Text('Login'),
                  ),
                ),
                const SizedBox(height: 20),

                GoogleSignInButton(onPressed: () => _onGoogleSignIn(false)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () async {
                        await Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const SignUpPage()),
                        );
                      },
                      child: const Text("Don't have an account?"),
                    ),
                    TextButton(
                      onPressed: () async {
                        await Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ResetPasswordPage(),
                          ),
                        );
                      },
                      child: const Text("Forgot Password?"),
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
