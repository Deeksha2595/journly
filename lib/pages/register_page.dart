import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:journly/services/firebase_auth_service.dart';
import 'package:journly/pages/dashboard_page.dart';
import 'package:journly/pages/login_page.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isSigningUp = false;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 102, 140, 84),
        title: const Text(
          'Registration',
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
                      'Enter Details Here:',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),

                    // Name
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                        labelText: 'Name',
                        hintText: 'Enter your name',
                      ),
                      validator: (value) {
                        final name = value?.trim() ?? '';

                        if (name.isEmpty) {
                          return 'Please enter your name';
                        }

                        if (name.length < 2) {
                          return 'Name is too short';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Phone
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone_outlined),
                        labelText: 'Phone',
                        hintText: 'Enter 10-digit phone number',
                      ),
                      validator: (value) {
                        final phone = value?.trim() ?? '';

                        if (phone.isEmpty) {
                          return 'Please enter your phone number';
                        }

                        if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
                          return 'Enter a valid 10-digit phone number';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
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
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock_outline),
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
                          return 'Please enter a password';
                        }

                        if (value.length < 6) {
                          return 'Use at least 6 characters';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Confirm password
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _hideConfirmPassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      enableSuggestions: false,
                      autocorrect: false,
                      onFieldSubmitted: (_) {
                        if (!_isSigningUp) {
                          _signUp();
                        }
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock_person_outlined),
                        labelText: 'Confirm Password',
                        hintText: 'Enter the password again',
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _hideConfirmPassword = !_hideConfirmPassword;
                            });
                          },
                          icon: Icon(
                            _hideConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }

                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSigningUp ? null : _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 102, 140, 84),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _isSigningUp
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Register',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(),

                    TextButton(
                      onPressed: _isSigningUp
                          ? null
                          : () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginDemo(),
                                ),
                              );
                            },
                      child: const Text(
                        'Already have an account? Login here!',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSigningUp = true;
    });

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    User? createdUser;

    try {
      createdUser = await _auth.signUpWithEmailAndPassword(
        email,
        password,
      );

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(createdUser.uid)
            .set({
          'name': name,
          'email': email,
          'phone': phone,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (_) {
        // If the profile cannot be saved, remove the newly created
        // authentication account to avoid an incomplete account.
        try {
          await createdUser.delete();
        } catch (_) {
          // Ignore a rollback failure and show the original error.
        }

        rethrow;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful!'),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => DashBoardPage(
            userName: name,
            userEmail: email,
          ),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      _showMessage(_auth.getErrorMessage(error));
    } on FirebaseException {
      if (!mounted) return;

      _showMessage(
        'Could not save your profile. Please try again.',
      );
    } catch (_) {
      if (!mounted) return;

      _showMessage(
        'Something went wrong. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSigningUp = false;
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
