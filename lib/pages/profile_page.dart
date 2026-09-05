import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:journly/services/firebase_auth_service.dart';
import 'package:journly/pages/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController _editNameController = TextEditingController();
  final TextEditingController _editPhoneController = TextEditingController();

  @override
  void dispose() {
    _editNameController.dispose();
    _editPhoneController.dispose();
    super.dispose();
  }

  User? get _currentUser => _auth.currentUser;

  DocumentReference<Map<String, dynamic>>? get _userDocument {
    final user = _currentUser;

    if (user == null) {
      return null;
    }

    return FirebaseFirestore.instance.collection('users').doc(user.uid);
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;
    final userDocument = _userDocument;

    if (user == null || userDocument == null) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: _buildSignedOutMessage(),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: userDocument.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Could not load your profile.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final userData = snapshot.data?.data();

          final registeredEmail = user.email ?? '';

          String name = (userData?['name'] as String? ?? '').trim();

          final email =
              (userData?['email'] as String? ?? registeredEmail).trim();

          final phone = (userData?['phone'] as String? ?? '').trim();

          if (name.isEmpty) {
            name = user.displayName?.trim() ?? '';
          }

          if (name.isEmpty && email.contains('@')) {
            name = email.split('@').first;
          }

          if (name.isEmpty) {
            name = 'User';
          }

          return _buildProfileContent(
            name: name,
            email: email,
            phone: phone,
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 102, 140, 84),
      leading: const BackButton(color: Colors.white),
      title: const Text(
        'Profile',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildProfileContent({
    required String name,
    required String email,
    required String phone,
  }) {
    final firstLetter =
        name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      firstLetter,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildInformationRow(
                    context: context,
                    icon: Icons.email,
                    title: 'Email ID',
                    value: email.isEmpty ? 'Not added' : email,
                  ),
                  const SizedBox(height: 20),
                  _buildInformationRow(
                    context: context,
                    icon: Icons.phone_outlined,
                    title: 'Phone number',
                    value: phone.isEmpty ? 'Not added' : phone,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        _showEditProfileDialog(
                          currentName: name,
                          currentEmail: email,
                          currentPhone: phone,
                        );
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit Profile'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              onTap: _showLogoutConfirmation,
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: const Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'Sign out of your Journly account',
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignedOutMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_off_outlined,
              size: 70,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'You are not signed in.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginDemo(),
                  ),
                  (route) => false,
                );
              },
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditProfileDialog({
    required String currentName,
    required String currentEmail,
    required String currentPhone,
  }) async {
    _editNameController.text = currentName;
    _editPhoneController.text = currentPhone;

    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Profile'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _editNameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                          labelText: 'Full Name',
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
                      TextFormField(
                        initialValue: currentEmail,
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email_outlined),
                          labelText: 'Email',
                          helperText: 'Email cannot be changed here',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _editPhoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone_outlined),
                          labelText: 'Phone Number',
                        ),
                        validator: (value) {
                          final phone = value?.trim() ?? '';

                          if (phone.isEmpty) {
                            return 'Please enter your phone number';
                          }

                          if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
                            return 'Enter a valid 10-digit number';
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          setDialogState(() {
                            isSaving = true;
                          });

                          final newName = _editNameController.text.trim();
                          final newPhone = _editPhoneController.text.trim();

                          try {
                            final userDocument = _userDocument;
                            final user = _currentUser;

                            if (userDocument == null || user == null) {
                              throw FirebaseAuthException(
                                code: 'user-not-found',
                                message: 'The user is not signed in.',
                              );
                            }

                            await userDocument.set({
                              'name': newName,
                              'email': user.email ?? currentEmail,
                              'phone': newPhone,
                              'updatedAt': FieldValue.serverTimestamp(),
                            }, SetOptions(merge: true));

                            await user.updateDisplayName(newName);

                            if (!mounted) return;

                            Navigator.pop(dialogContext);

                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile updated successfully'),
                              ),
                            );
                          } on FirebaseException catch (error) {
                            if (!mounted) return;

                            setDialogState(() {
                              isSaving = false;
                            });

                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  error.message ?? 'Could not update profile.',
                                ),
                              ),
                            );
                          } catch (_) {
                            if (!mounted) return;

                            setDialogState(() {
                              isSaving = false;
                            });

                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Could not update profile.',
                                ),
                              ),
                            );
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLogoutConfirmation() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text(
            'Are you sure you want to sign out?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                try {
                  await _auth.signOut();

                  if (!mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginDemo(),
                    ),
                    (route) => false,
                  );
                } catch (_) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Could not sign out. Please try again.',
                      ),
                    ),
                  );
                }
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
