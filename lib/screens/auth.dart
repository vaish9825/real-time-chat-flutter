import 'package:flutter/material.dart';
import 'dart:io';
import 'package:rtc_app/widgets/user_image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  String _email = '';
  String _password = '';
  File? _pickedImage;
  String url = '';
  var _isAuthencating = false;
  var _enteredUsername = '';

  final _supabase = Supabase.instance.client;

  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    if (!_isLogin && _pickedImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please pick an image.')));
      return;
    }

    _formKey.currentState!.save();

    try {
      setState(() {
        _isAuthencating = true;
      });
      if (_isLogin) {
        final userCred = await _supabase.auth.signInWithPassword(
          email: _email,
          password: _password,
        );
        final path = 'user_avatars/${userCred.user!.id}.jpeg';
        url = _supabase.storage.from('avatars').getPublicUrl(path);
      } else {
        final userCreds = await _supabase.auth.signUp(
          email: _email,
          password: _password,
        );

        final path = 'user_avatars/${userCreds.user!.id}.jpeg';
        final file = File(_pickedImage!.path);
        await _supabase.storage.from('avatars').upload(path, file);
        url = _supabase.storage.from('avatars').getPublicUrl(path);

        await _supabase.from('users').insert({
          'id': userCreds.user!.id,
          'username': _enteredUsername,
          'email': _email,
          'image_url': url,
        });
      }
    } on AuthApiException catch (e) {
      setState(() {
        _isAuthencating = false;
      });
      String message = 'An error occurred: ${e.message}';
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  bottom: 20,
                  top: 30,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogin)
                            UserImagePicker(
                              onImagePick: (pickedImage) {
                                _pickedImage = pickedImage;
                              },
                            ),
                          if (!_isLogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Username',
                              ),
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a username.';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                _enteredUsername = newValue!;
                              },
                            ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Email',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter an email address.';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _email = newValue!;
                            },
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Password',
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a password.';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters long.';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _password = newValue!;
                            },
                          ),
                          const SizedBox(height: 12),
                          if (_isAuthencating)
                            const CircularProgressIndicator(),
                          if (!_isAuthencating)
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                              ),
                              child: Text(_isLogin ? 'Login' : 'Sign Up'),
                            ),
                          const SizedBox(height: 12),
                          if (!_isAuthencating)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(
                                _isLogin ? 'Create new account' : 'Login',
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
