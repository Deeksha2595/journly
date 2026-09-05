import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  static const Color _primaryColor = Color.fromARGB(255, 102, 140, 84);

  String? _selectedTag;

  CollectionReference<Map<String, dynamic>>? get _eventsCollection {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return null;
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('calendarEvents');
  }

  List<String> _getAllTags(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> events,
  ) {
    final tags = <String>{};

    for (final event in events) {
      final data = event.data();
      final eventTags = List<String>.from(data['tags'] ?? []);

      tags.addAll(eventTags);
    }

    final sortedTags = tags.toList();
    sortedTags.sort(
      (first, second) => first.toLowerCase().compareTo(second.toLowerCase()),
    );

    return sortedTags;
  }

  Future<void> _deleteEvent(
    DocumentReference<Map<String, dynamic>> reference,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Event'),
          content: const Text(
            'Are you sure you want to delete this event?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
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

    try {
      await reference.delete();
      _showMessage('Event deleted');
    } on FirebaseException catch (error) {
      _showMessage(
        error.message ?? 'Could not delete the event.',
      );
    } catch (_) {
      _showMessage('Something went wrong.');
    }
  }

  String _formatDate(Map<String, dynamic> data) {
    final timestamp = data['eventDate'];

    if (timestamp is Timestamp) {
      final date = timestamp.toDate();

      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];

      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }

    return data['dateKey'] as String? ?? 'Date unavailable';
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final collection = _eventsCollection;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Events',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: collection == null
          ? const _MessageView(
              icon: Icons.login,
              message: 'Please log in to view your events.',
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: collection.orderBy('eventDate').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _MessageView(
                    icon: Icons.error_outline,
                    message: 'Could not load events.\n${snapshot.error}',
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final allEvents = snapshot.data?.docs ?? [];
                final allTags = _getAllTags(allEvents);

                // If a deleted event contained the selected tag,
                // safely show all events again.
                final selectedTag =
                    allTags.contains(_selectedTag) ? _selectedTag : null;

                final filteredEvents = selectedTag == null
                    ? allEvents
                    : allEvents.where((event) {
                        final tags = List<String>.from(
                          event.data()['tags'] ?? [],
                        );

                        return tags.contains(selectedTag);
                      }).toList();

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        8,
                      ),
                      child: DropdownButtonFormField<String?>(
                        value: selectedTag,
                        decoration: InputDecoration(
                          labelText: 'Filter by tag',
                          prefixIcon: const Icon(Icons.filter_alt_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All events'),
                          ),
                          ...allTags.map(
                            (tag) => DropdownMenuItem<String?>(
                              value: tag,
                              child: Text('#$tag'),
                            ),
                          ),
                        ],
                        onChanged: (tag) {
                          setState(() {
                            _selectedTag = tag;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Text(
                            selectedTag == null
                                ? 'All events'
                                : 'Events tagged #$selectedTag',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${filteredEvents.length} found',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: filteredEvents.isEmpty
                          ? _MessageView(
                              icon: Icons.event_busy,
                              message: selectedTag == null
                                  ? 'No events added yet.'
                                  : 'No events found for #$selectedTag.',
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                12,
                                4,
                                12,
                                20,
                              ),
                              itemCount: filteredEvents.length,
                              itemBuilder: (context, index) {
                                final event = filteredEvents[index];

                                return _EventCard(
                                  document: event,
                                  formattedDate: _formatDate(
                                    event.data(),
                                  ),
                                  onDelete: () {
                                    _deleteEvent(
                                      event.reference,
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _EventCard extends StatelessWidget {
  static const Color _primaryColor = Color.fromARGB(255, 102, 140, 84);

  final QueryDocumentSnapshot<Map<String, dynamic>> document;
  final String formattedDate;
  final VoidCallback onDelete;

  const _EventCard({
    required this.document,
    required this.formattedDate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final data = document.data();
    final note = data['note'] as String? ?? 'No note';
    final tags = List<String>.from(data['tags'] ?? []);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              backgroundColor: _primaryColor,
              child: Icon(
                Icons.event_note,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      color: _primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    note,
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: tags.map((tag) {
                        return Chip(
                          visualDensity: VisualDensity.compact,
                          backgroundColor: _primaryColor.withOpacity(0.12),
                          side: BorderSide.none,
                          label: Text('#$tag'),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              tooltip: 'Delete event',
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
            ),
          ],
        ),
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
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 14),
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
