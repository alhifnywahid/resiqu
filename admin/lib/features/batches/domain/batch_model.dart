import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/batch_status.dart';

export '../../../core/constants/batch_status.dart';


class BatchModel {
  final String id;
  final String name;
  final String destinationCity;
  final BatchStatus status;
  final List<String> packageIds;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? startDate;
  final DateTime? expiryDate;

  const BatchModel({
    required this.id,
    required this.name,
    required this.destinationCity,
    required this.status,
    required this.packageIds,
    required this.createdBy,
    required this.createdAt,
    this.startDate,
    this.expiryDate,
  });

  factory BatchModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BatchModel(
      id: doc.id,
      name: data['name'] ?? '',
      destinationCity: data['destinationCity'] ?? '',
      status: BatchStatus.fromValue(data['status'] ?? 'collecting'),
      packageIds: List<String>.from(data['packageIds'] ?? []),
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startDate: (data['startDate'] as Timestamp?)?.toDate(),
      expiryDate: (data['expiryDate'] as Timestamp?)?.toDate(),
    );
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  String get statusLabel {
    if (isExpired && status == BatchStatus.collecting) return 'Kadaluarsa';
    return status.label;
  }
}
