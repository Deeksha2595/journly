import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarSection extends StatefulWidget {
  const CalendarSection({super.key});

  @override
  State<CalendarSection> createState() => _CalendarSectionState();
}

class _CalendarSectionState extends State<CalendarSection> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }

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

  Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      _groupEventsByDate(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents,
  ) {
    final groupedEvents =
        <String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>{};

    for (final document in documents) {
      final data = document.data();
      final dateKey = data['dateKey'] as String?;

      if (dateKey == null) continue;

      groupedEvents.putIfAbsent(dateKey, () => []);
      groupedEvents[dateKey]!.add(document);
    }

    return groupedEvents;
  }

  Future<void> _showEventsForDate(DateTime selectedDate) async {
    final collection = _eventsCollection;

    if (collection == null) {
      _showMessage('Please log in first.');
      return;
    }

    final selectedDateKey = _dateKey(selectedDate);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 8, 0),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  'Events on ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.pop(dialogContext),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.sizeOf(context).height * 0.45,
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: collection
                  .where('dateKey', isEqualTo: selectedDateKey)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Could not load events.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final events = snapshot.data?.docs ?? [];

                if (events.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_note,
                          size: 55,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No events for this date.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: events.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final data = event.data();

                    final note = data['note'] as String? ?? '';
                    final tags = List<String>.from(data['tags'] ?? []);

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        backgroundColor: Color.fromARGB(255, 102, 140, 84),
                        child: Icon(
                          Icons.event,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        note,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: tags.isEmpty
                          ? null
                          : Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: tags
                                    .map(
                                      (tag) => Chip(
                                        visualDensity: VisualDensity.compact,
                                        label: Text('#$tag'),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                      trailing: IconButton(
                        tooltip: 'Delete event',
                        onPressed: () => _confirmDeleteEvent(
                          dialogContext,
                          event.reference,
                        ),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () => _showAddEventDialog(selectedDate),
              icon: const Icon(Icons.add),
              label: const Text('Add Event'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddEventDialog(DateTime selectedDate) async {
    final formKey = GlobalKey<FormState>();

    String note = '';
    String tagsText = '';
    bool isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (addDialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Add Event\n'
                '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          autofocus: true,
                          minLines: 2,
                          maxLines: 4,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            labelText: 'Event note',
                            hintText: 'What do you want to remember?',
                            prefixIcon: Icon(Icons.edit_note),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            note = value;
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter an event note.';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Tags (optional)',
                            hintText: 'work, personal, health',
                            prefixIcon: Icon(Icons.tag),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            tagsText = value;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isSaving ? null : () => Navigator.pop(addDialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          setDialogState(() {
                            isSaving = true;
                          });

                          final saved = await _saveEvent(
                            selectedDate: selectedDate,
                            note: note,
                            tagsText: tagsText,
                          );

                          if (!addDialogContext.mounted) return;

                          if (saved) {
                            Navigator.pop(addDialogContext);
                          } else {
                            setDialogState(() {
                              isSaving = false;
                            });
                          }
                        },
                  icon: isSaving
                      ? const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    isSaving ? 'Saving...' : 'Save',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool> _saveEvent({
    required DateTime selectedDate,
    required String note,
    required String tagsText,
  }) async {
    final collection = _eventsCollection;

    if (collection == null) {
      _showMessage('Please log in first.');
      return false;
    }

    final tags = tagsText
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();

    try {
      await collection.add({
        'note': note.trim(),
        'tags': tags,
        'dateKey': _dateKey(selectedDate),
        'eventDate': Timestamp.fromDate(
          DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
          ),
        ),
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showMessage('Event saved');
      return true;
    } on FirebaseException catch (error) {
      _showMessage(error.message ?? 'Could not save the event.');
      return false;
    } catch (_) {
      _showMessage('Something went wrong.');
      return false;
    }
  }

  Future<void> _confirmDeleteEvent(
    BuildContext parentDialogContext,
    DocumentReference<Map<String, dynamic>> reference,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: parentDialogContext,
      builder: (confirmationContext) {
        return AlertDialog(
          title: const Text('Delete Event'),
          content: const Text(
            'Are you sure you want to delete this event?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(
                confirmationContext,
                false,
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(
                confirmationContext,
                true,
              ),
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
      _showMessage(error.message ?? 'Could not delete the event.');
    }
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

    if (collection == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text('Please log in to use the calendar.'),
          ),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: collection.snapshots(),
      builder: (context, snapshot) {
        final documents = snapshot.data?.docs ?? [];
        final groupedEvents = _groupEventsByDate(documents);

        return Card(
          margin: EdgeInsets.zero,
          elevation: 8,
          shadowColor: Colors.black54,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: TableCalendar<QueryDocumentSnapshot<Map<String, dynamic>>>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2035, 12, 31),
            focusedDay: _focusedDay,

            // These heights ensure the calendar fits inside 400 pixels.
            rowHeight: 48,
            daysOfWeekHeight: 20,

            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },

            eventLoader: (day) {
              return groupedEvents[_dateKey(day)] ?? [];
            },

            calendarFormat: CalendarFormat.month,

            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
            },

            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              headerPadding: EdgeInsets.symmetric(vertical: 8),
              titleTextStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              leftChevronPadding: EdgeInsets.zero,
              rightChevronPadding: EdgeInsets.zero,
            ),

            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(fontSize: 11),
              weekendStyle: TextStyle(
                fontSize: 11,
                color: Colors.red,
              ),
            ),

            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              cellMargin: EdgeInsets.all(3),
              defaultTextStyle: TextStyle(fontSize: 12),
              weekendTextStyle: TextStyle(
                fontSize: 12,
                color: Colors.red,
              ),
              selectedDecoration: BoxDecoration(
                color: Color.fromARGB(255, 102, 140, 84),
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Color.fromARGB(150, 102, 140, 84),
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 1,
              markerSize: 5,
            ),

            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });

              _showEventsForDate(selectedDay);
            },

            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
        );
      },
    );
  }
}
