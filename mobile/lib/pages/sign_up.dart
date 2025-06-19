import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mobile/api/client.dart';
import 'package:mobile/pages/sign_in.dart';
import 'package:mobile/schemas/auth.dart';

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
  late final Dio dio;

  @override
  void initState() {
    super.initState();
    dio = useApi();
  }

  Future<void> _onSignUp() async {
    setState(() {
      fieldErrors = {};
      _loading = true;
    });

    final formData = {
      'name': _nameCtrl.text,
      'username': _usernameCtrl.text,
      'email': _emailCtrl.text,
      'password': _passCtrl.text,
    };

    final result = await signUpSchema.tryParseAsync(formData);

    if (result.success) {
      try {
        final response = await dio.post('/auth/register', data: formData);
        if (response.statusCode == 200) {
          Navigator.of(context).pop();
        } else {
          setState(() {
            fieldErrors['login'] = response.data['message'] ?? 'Sign up failed';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 32),
                const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    prefixIcon: const Icon(Icons.account_box),
                    errorText: fieldErrors['name'],
                  ),
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usernameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon: const Icon(Icons.account_circle),
                    errorText: fieldErrors['username'],
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    errorText: fieldErrors['email'],
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passCtrl,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    errorText: fieldErrors['password'],
                  ),
                  obscureText: _obscurePassword,
                ),
                if (fieldErrors['login'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      fieldErrors['login']!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 45),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
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
                        color: Colors.white,
                      ),
                    )
                        : const Text('Sign Up'),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Back to Home"),
                    ),
                    TextButton(
                      onPressed: () async {
                        await Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const SignInPage()),
                        );
                      },
                      child: const Text("Have an account?"),
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
