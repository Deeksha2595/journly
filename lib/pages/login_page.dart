import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:journly/services/firebase_auth_service.dart';
import 'package:journly/pages/dashboard_page.dart';
import 'package:journly/pages/reset_password_page.dart';
import 'package:journly/pages/register_page.dart';

class LoginDemo extends StatefulWidget {
  const LoginDemo({super.key});

  @override
  State<LoginDemo> createState() => _LoginDemoState();
}

class _LoginDemoState extends State<LoginDemo> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuthService _auth = FirebaseAuthService();

  bool _hidePassword = true;
  bool _isLoggingIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 102, 140, 84),
        title: const Text(
          'Login',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 16,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(15),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 26, 238, 136),
                      Color.fromARGB(0, 50, 83, 12),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: AutofillGroup(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/person.png',
                        height: MediaQuery.sizeOf(context).height * 0.1,
                        width: MediaQuery.sizeOf(context).width * 0.5,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Enter your login details:',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [
                          AutofillHints.email,
                          AutofillHints.username,
                        ],
                        autocorrect: false,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email_outlined),
                          labelText: 'Email',
                          hintText: 'Enter your email address',
                        ),
                        validator: (value) {
                          final email = value?.trim() ?? '';

                          if (email.isEmpty) {
                            return 'Please enter your email';
                          }

                          final emailPattern =
                              RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

                          if (!emailPattern.hasMatch(email)) {
                            return 'Please enter a valid email';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _hidePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        enableSuggestions: false,
                        autocorrect: false,
                        onFieldSubmitted: (_) {
                          if (!_isLoggingIn) {
                            _login();
                          }
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock_person_outlined),
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _hidePassword = !_hidePassword;
                              });
                            },
                            icon: Icon(
                              _hidePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoggingIn ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 102, 140, 84),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _isLoggingIn
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(),

                      TextButton(
                        onPressed: _isLoggingIn
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Register(),
                                  ),
                                );
                              },
                        child: const Text(
                          "Don't have an account? Register here!",
                        ),
                      ),

                      TextButton(
                        onPressed: _isLoggingIn
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ResetPasswordScreen(),
                                  ),
                                );
                              },
                        child: const Text('Forgot Password?'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoggingIn = true;
    });

    final email = _emailController.text.trim();

    // Do not trim passwords because spaces could be part of a password.
    final password = _passwordController.text;

    try {
      final user = await _auth.signInWithEmailAndPassword(
        email,
        password,
      );

      final userDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userData = userDocument.data();

      String userName = '';

      if (userData != null) {
        userName = (userData['name'] as String? ?? '').trim();
      }

      // Fallback for an older account without a Firestore profile.
      if (userName.isEmpty) {
        userName = user.displayName?.trim() ?? '';
      }

      if (userName.isEmpty) {
        userName = email.split('@').first;
      }

      final userEmail = user.email ?? email;

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => DashBoardPage(
            userName: userName,
            userEmail: userEmail,
          ),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      _showMessage(_auth.getErrorMessage(error));
    } on FirebaseException {
      // Authentication succeeded, but the profile could not be loaded.
      // Sign out to avoid leaving the application in a partial state.
      await _auth.signOut();

      if (!mounted) return;

      _showMessage(
        'Your account was found, but the profile could not be loaded.',
      );
    } catch (_) {
      if (!mounted) return;

      _showMessage(
        'Something went wrong. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
