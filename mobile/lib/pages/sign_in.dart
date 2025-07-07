import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:dio/dio.dart';
import 'package:mobile/stores/client.dart';
import 'package:mobile/stores/pusher.dart';
import 'package:mobile/pages/main_page.dart';
import 'package:mobile/pages/sign_up.dart';
import 'package:mobile/pages/reset_password.dart';
import 'package:mobile/schemas/auth.dart';
import 'package:mobile/utils/extensions.dart';
import 'package:mobile/widgets/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/message_provider.dart';
import '../providers/user_provider.dart';

class SignInPage extends StatefulWidget {
  final Map<String, dynamic>? queryParameters;
  const SignInPage({super.key, this.queryParameters});

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

  Future<void> _onLogin() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
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
          if (mounted) {
            userProvider.fetchFromData(response.data);
            final messageProvider = Provider.of<MessagesProvider>(
              context,
              listen: false,
            );

            await initPusher(response.data['id'], messageProvider);
            messageProvider.fetchRefreshMessages();
          }
        } else {
          setState(() {
            fieldErrors['login'] = (response.data is Map<String, dynamic>)
                ? context.translate(response.data['message'] ?? 'unknown_error')
                : context.translate('network_error');
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
        errors[err.key] = context.translate(
          Map<String, String>.from(err.value).values.first,
        );
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
      if (mounted) {
        Navigator.pop(context);
      }
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
        sharedPrefs.remove('pkceCodeVerifier');
        sharedPrefs.remove('oauth_state');

        if (response.statusCode == 200) {
          if (mounted) {
            final userProvider = Provider.of<UserProvider>(
              context,
              listen: false,
            );
            userProvider.fetchFromData(response.data);
            final messageProvider = Provider.of<MessagesProvider>(
              context,
              listen: false,
            );

            await initPusher(response.data['id'], messageProvider);
            messageProvider.fetchRefreshMessages();

            if (mounted) {
              Navigator.pop(
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
    final localizedStrings = {
      'sign_in': FlutterI18n.translate(context, 'sign_in'),
      'email': FlutterI18n.translate(context, 'email'),
      'password': FlutterI18n.translate(context, 'password'),
      'dont_have_an_account': FlutterI18n.translate(
        context,
        'dont_have_an_account',
      ),
      'forgot_password': FlutterI18n.translate(context, 'forgot_password'),
    };

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text(localizedStrings['sign_in']!),
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
                  localizedStrings['sign_in']!,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: InputDecoration(
                    labelText: localizedStrings['email'],
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
                    labelText: localizedStrings['password'],
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
                        : Text(localizedStrings['sign_in']!),
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
                      child: Text(localizedStrings['dont_have_an_account']!),
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
                      child: Text(localizedStrings['forgot_password']!),
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
