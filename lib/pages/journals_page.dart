import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:journly/models/journal.dart';

class JournalsPage extends StatefulWidget {
  const JournalsPage({super.key});

  @override
  State<JournalsPage> createState() => _JournalsPageState();
}

class _JournalsPageState extends State<JournalsPage> {
  static const LinearGradient _defaultGradient = LinearGradient(
    colors: [Colors.green, Colors.greenAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const List<Color> _pickerColors = [
    Colors.orangeAccent,
    Colors.pink,
    Colors.teal,
    Colors.redAccent,
    Colors.blueAccent,
  ];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  CollectionReference<Map<String, dynamic>>? get _journalsCollection {
    final user = _currentUser;

    if (user == null) return null;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('journals');
  }

  List<LinearGradient> get _journalGradients => _pickerColors
      .map(
        (color) => LinearGradient(
          colors: [
            color,
            const Color.fromARGB(12, 0, 0, 0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      )
      .toList();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final journalsCollection = _journalsCollection;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 102, 140, 84),
        title: const Text(
          'Journals',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: journalsCollection == null
          ? _buildSignedOutMessage()
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: journalsCollection
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildErrorMessage(snapshot.error);
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final documents = snapshot.data?.docs ?? [];
                final journals = documents
                    .map((document) => Journal.fromFirestore(document))
                    .toList();

                if (journals.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: journals.length,
                  itemBuilder: (context, index) {
                    return _buildJournalCard(journals[index]);
                  },
                );
              },
            ),
      floatingActionButton: journalsCollection == null
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              onPressed: () => _showJournalDialog(),
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildJournalCard(Journal journal) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        elevation: 5,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: journal.gradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      journal.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Edit journal',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _showJournalDialog(journal: journal),
                    icon: const Icon(Icons.edit, color: Colors.white),
                  ),
                ],
              ),
              if (journal.description.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  journal.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 80,
              color: Colors.green.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'No journals yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the + button to write your first journal.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignedOutMessage() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Please sign in to view your journals.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            const Text(
              'Could not load journals.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error?.toString() ?? 'Please try again.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showJournalDialog({Journal? journal}) async {
    final isEditing = journal != null;
    var selectedGradient = journal?.gradient ?? _defaultGradient;
    var isSaving = false;

    _titleController.text = journal?.title ?? '';
    _descriptionController.text = journal?.description ?? '';

    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      barrierDismissible: !isSaving,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.65,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: selectedGradient,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isEditing ? 'Edit Journal' : 'New Journal',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildColorPicker(
                          onSelected: (gradient) {
                            setDialogState(() {
                              selectedGradient = gradient;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _titleController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                            labelText: 'Title',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descriptionController,
                          minLines: 3,
                          maxLines: 6,
                          maxLength: 1000,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                            labelText: 'Description',
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (isEditing)
                              ElevatedButton(
                                onPressed: isSaving
                                    ? null
                                    : () async {
                                        Navigator.pop(dialogContext);
                                        await _confirmDelete(journal);
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Delete'),
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

                                      final saved = await _saveJournal(
                                        journal: journal,
                                        gradient: selectedGradient,
                                      );

                                      if (!mounted) return;

                                      if (saved && dialogContext.mounted) {
                                        Navigator.pop(dialogContext);
                                      } else if (dialogContext.mounted) {
                                        setDialogState(() {
                                          isSaving = false;
                                        });
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade800,
                                foregroundColor: Colors.white,
                              ),
                              child: isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(isEditing ? 'Update' : 'Save'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildColorPicker({
    required ValueChanged<LinearGradient> onSelected,
  }) {
    final gradients = _journalGradients;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        _pickerColors.length,
        (index) => IconButton(
          tooltip: 'Select colour',
          onPressed: () => onSelected(gradients[index]),
          icon: Icon(
            Icons.circle,
            size: 36,
            color: _pickerColors[index],
          ),
        ),
      ),
    );
  }

  Future<bool> _saveJournal({
    required Journal? journal,
    required LinearGradient gradient,
  }) async {
    final collection = _journalsCollection;

    if (collection == null) {
      _showMessage('Please sign in again.');
      return false;
    }

    final updatedJournal = Journal(
      id: journal?.id ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      gradient: gradient,
      createdAt: journal?.createdAt,
    );

    try {
      if (journal == null) {
        await collection.add({
          ...updatedJournal.toFirestore(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        _showMessage('Journal added');
      } else {
        await collection.doc(journal.id).update({
          ...updatedJournal.toFirestore(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        _showMessage('Journal updated');
      }

      return true;
    } on FirebaseException catch (error) {
      _showMessage(error.message ?? 'Could not save the journal.');
      return false;
    } catch (_) {
      _showMessage('Could not save the journal.');
      return false;
    }
  }

  Future<void> _confirmDelete(Journal journal) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Journal'),
          content: const Text(
            'Are you sure you want to delete this journal?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    final collection = _journalsCollection;
    if (collection == null) return;

    try {
      await collection.doc(journal.id).delete();
      if (mounted) _showMessage('Journal deleted');
    } on FirebaseException catch (error) {
      if (mounted) {
        _showMessage(error.message ?? 'Could not delete the journal.');
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
