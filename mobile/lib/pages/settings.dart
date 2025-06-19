import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/schemas/user.dart';
import 'package:mobile/schemas/auth.dart';
import 'package:mobile/utils/global.dart';
import 'package:mobile/api/client.dart';

import 'package:mobile/widgets/password_field.dart';
import 'package:mobile/widgets/currency_dropdown.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

// Reusable password field with toggle

class _SettingsPageState extends State<SettingsPage> {
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _repeatPassCtrl = TextEditingController();

  Currency? _selectedCurrency = Currency.USD;

  bool _obscurePassword = true;
  bool _isSavingProfile = false;
  bool _isChangingPassword = false;

  Map<String, String?> _profileErrors = {};
  Map<String, String?> _passwordErrors = {};

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _repeatPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    _nameCtrl.text = prefs.getString('name') ?? '';
    _usernameCtrl.text = prefs.getString('username') ?? '';
    _emailCtrl.text = prefs.getString('email') ?? '';
    final savedCurrency = prefs.getString('preferredCurrency');
    _selectedCurrency = Currency.values.firstWhere(
          (c) => c.symbol == savedCurrency,
      orElse: () => Currency.USD,
    );
    setState(() {});
  }

  Future<void> _onSaveProfile() async {
    setState(() {
      _profileErrors = {};
      _isSavingProfile = true;
    });

    final formData = {
      'name': _nameCtrl.text.trim(),
      'username': _usernameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'preferredCurrency': _selectedCurrency?.symbol ?? 'USD',
    };

    final result = await updateProfileSchema.tryParseAsync(formData);

    if (!result.success) {
      final errors = <String, String?>{};
      for (final err in result.errors.entries) {
        errors[err.key] = Map<String, String>.from(err.value).values.first;
      }
      setState(() {
        _profileErrors = errors;
        _isSavingProfile = false;
      });
      return;
    }

    try {
      final response = await useApi().put('/user/update', data: formData);
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', formData['name']!);
        await prefs.setString('username', formData['username']!);
        await prefs.setString('preferredCurrency', formData['preferredCurrency']!);

        setState(() {
          _profileErrors = {};
          _isSavingProfile = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated!')),
          );
        }

        // If email changed, log out user
        if (formData['email'] != prefs.getString('email')) {
          await prefs.remove('sessionId');
          await prefs.remove('userId');
          await prefs.remove('username');
          await prefs.remove('name');
          await prefs.remove('email');
          await prefs.remove('currency');
          await prefs.remove('isAdmin');
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/sign-in', (route) => false);
          }
        }
      } else {
        setState(() {
          _profileErrors['error'] = response.data['message'] ?? 'Profile update failed';
          _isSavingProfile = false;
        });
      }
    } on DioException catch (e) {
      setState(() {
        _profileErrors['error'] = e.response?.data['message'] ?? 'Network error';
        _isSavingProfile = false;
      });
    }
  }

  Future<void> _onChangePassword() async {
    setState(() {
      _passwordErrors = {};
      _isChangingPassword = true;
    });

    if (_newPassCtrl.text.trim() != _repeatPassCtrl.text.trim()) {
      setState(() {
        _passwordErrors['repeatPassword'] = 'Passwords do not match';
        _isChangingPassword = false;
      });
      return;
    }

    final formData = {
      'oldPassword': _oldPassCtrl.text.trim(),
      'newPassword': _newPassCtrl.text.trim(),
    };

    final result = await changePasswordSchema.tryParseAsync(formData);

    if (!result.success) {
      final errors = <String, String?>{};
      for (final err in result.errors.entries) {
        errors[err.key] = Map<String, String>.from(err.value).values.first;
      }
      setState(() {
        _passwordErrors = errors;
        _isChangingPassword = false;
      });
      return;
    }

    try {
      final response = await useApi().post('/auth/change-password', data: formData);
      if (response.statusCode == 200) {
        setState(() {
          _passwordErrors = {};
          _isChangingPassword = false;
          _oldPassCtrl.clear();
          _newPassCtrl.clear();
          _repeatPassCtrl.clear();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password changed!')),
          );
        }
      } else {
        setState(() {
          _passwordErrors['error'] = response.data['message'] ?? 'Password change failed';
          _isChangingPassword = false;
        });
      }
    } on DioException catch (e) {
      setState(() {
        _passwordErrors['error'] = e.response?.data['message'] ?? 'Network error';
        _isChangingPassword = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: bottomInset + 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              const Text('Name'),
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(errorText: _profileErrors['name']),
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 12),

              const Text('Username'),
              Row(
                children: [
                  const Text('@'),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextFormField(
                      controller: _usernameCtrl,
                      decoration: InputDecoration(errorText: _profileErrors['username']),
                      keyboardType: TextInputType.name,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              const Text('Email'),
              TextFormField(
                controller: _emailCtrl,
                decoration: InputDecoration(errorText: _profileErrors['email']),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              const Text('Preferred currency'),
              CurrencyDropdown(
                selectedCurrency: _selectedCurrency,
                errorText: _profileErrors['preferredCurrency'],
                onChanged: (value) {
                  setState(() {
                    _selectedCurrency = value;
                  });
                },
              ),


              if (_profileErrors['error'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _profileErrors['error']!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _isSavingProfile ? null : _onSaveProfile,
                child: _isSavingProfile
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Save'),
              ),

              const SizedBox(height: 32),

              const Text(
                'Change password',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              PasswordField(
                controller: _oldPassCtrl,
                label: 'Old password',
                errorText: _passwordErrors['oldPassword'],
                obscureText: _obscurePassword,
                onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              const SizedBox(height: 12),

              PasswordField(
                controller: _newPassCtrl,
                label: 'New password',
                errorText: _passwordErrors['newPassword'],
                obscureText: _obscurePassword,
                onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              const SizedBox(height: 12),

              PasswordField(
                controller: _repeatPassCtrl,
                label: 'Repeat new password',
                errorText: _passwordErrors['repeatPassword'],
                obscureText: _obscurePassword,
                onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
              ),

              if (_passwordErrors['error'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _passwordErrors['error']!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: _isChangingPassword ? null : _onChangePassword,
                child: _isChangingPassword
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Change password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
