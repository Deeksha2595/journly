import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Journal {
  final String id;
  final LinearGradient gradient;
  final String title;
  final String description;
  final DateTime? createdAt;

  const Journal({
    required this.id,
    required this.gradient,
    required this.title,
    required this.description,
    this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    final begin = gradient.begin.resolve(TextDirection.ltr);
    final end = gradient.end.resolve(TextDirection.ltr);

    return {
      'title': title,
      'description': description,
      'gradientColors':
          gradient.colors.map((color) => color.toARGB32()).toList(),
      'beginX': begin.x,
      'beginY': begin.y,
      'endX': end.x,
      'endY': end.y,
    };
  }

  factory Journal.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? <String, dynamic>{};
    final rawColors = data['gradientColors'] as List<dynamic>?;
    final timestamp = data['createdAt'] as Timestamp?;

    final colors =
        rawColors?.map((value) => Color((value as num).toInt())).toList() ??
            const [Colors.green, Colors.greenAccent];

    return Journal(
      id: document.id,
      title: (data['title'] as String? ?? '').trim(),
      description: (data['description'] as String? ?? '').trim(),
      gradient: LinearGradient(
        colors: colors.length >= 2
            ? colors
            : const [Colors.green, Colors.greenAccent],
        begin: Alignment(
          (data['beginX'] as num?)?.toDouble() ?? -1,
          (data['beginY'] as num?)?.toDouble() ?? -1,
        ),
        end: Alignment(
          (data['endX'] as num?)?.toDouble() ?? 1,
          (data['endY'] as num?)?.toDouble() ?? 1,
        ),
      ),
      createdAt: timestamp?.toDate(),
    );
  }
}
