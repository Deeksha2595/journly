import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavQuotesPage extends StatelessWidget {
  const FavQuotesPage({super.key});

  CollectionReference<Map<String, dynamic>>? get _favouritesCollection {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return null;
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favoriteQuotes');
  }

  Future<void> _removeFavourite(
    BuildContext context,
    DocumentReference<Map<String, dynamic>> reference,
  ) async {
    try {
      await reference.delete();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quote removed from favourites'),
        ),
      );
    } on FirebaseException catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message ?? 'Could not remove the quote.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final collection = _favouritesCollection;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 102, 140, 84),
        title: const Text(
          'Favourite Quotes',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: collection == null
          ? const _MessageView(
              icon: Icons.login,
              message: 'Please log in to view your favourite quotes.',
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream:
                  collection.orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _MessageView(
                    icon: Icons.error_outline,
                    message:
                        'Could not load favourite quotes.\n${snapshot.error}',
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final documents = snapshot.data?.docs ?? [];

                if (documents.isEmpty) {
                  return const _MessageView(
                    icon: Icons.favorite_border,
                    message:
                        'You have no favourite quotes yet.\n\nTap the heart on the dashboard to add one.',
                  );
                }

                return Card(
                  margin: const EdgeInsets.all(12),
                  elevation: 8,
                  shadowColor: Colors.black54,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/forest-trees.jpg',
                        fit: BoxFit.cover,
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(190, 0, 0, 0),
                              Color.fromARGB(40, 0, 0, 0),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                      PageView.builder(
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          final document = documents[index];
                          final data = document.data();
                          final quote =
                              data['quote'] as String? ?? 'Quote unavailable';

                          return Stack(
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 36,
                                    vertical: 80,
                                  ),
                                  child: Text(
                                    quote,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      height: 1.5,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black87,
                                          offset: Offset(1, 1),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: IconButton(
                                  tooltip: 'Remove from favourites',
                                  onPressed: () => _removeFavourite(
                                    context,
                                    document.reference,
                                  ),
                                  icon: const Icon(
                                    Icons.favorite,
                                    size: 32,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 22,
                                left: 0,
                                right: 0,
                                child: Text(
                                  '${index + 1} of ${documents.length}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _MessageView extends StatelessWidget {
  final IconData icon;
  final String message;

  const _MessageView({
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17),
            ),
          ],
        ),
      ),
    );
  }
}
