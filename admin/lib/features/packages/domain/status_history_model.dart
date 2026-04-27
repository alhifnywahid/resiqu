import 'package:cloud_firestore/cloud_firestore.dart';

class StatusHistoryModel {
  final String id;
  final String status;
  final String note;
  final String updatedBy;
  final DateTime timestamp;

  const StatusHistoryModel({
    required this.id,
    required this.status,
    required this.note,
    required this.updatedBy,
    required this.timestamp,
  });

  factory StatusHistoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StatusHistoryModel(
      id: doc.id,
      status: data['status'] ?? '',
      note: data['note'] ?? '',
      updatedBy: data['updatedBy'] ?? '',
      timestamp:
          (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'status': status,
      'note': note,
      'updatedBy': updatedBy,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
