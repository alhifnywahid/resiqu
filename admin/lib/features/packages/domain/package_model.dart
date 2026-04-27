import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/package_status.dart';

class PackageModel {
  final String id;
  final String trackingCode;
  final String recipientName;
  final String recipientPhone;
  final String destinationCity;
  final PackageStatus currentStatus;
  final String? batchId;
  final Map<String, double>? dimensions; // {p, l, t} in cm — optional
  final String createdBy;
  final String updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PackageModel({
    required this.id,
    required this.trackingCode,
    required this.recipientName,
    required this.recipientPhone,
    required this.destinationCity,
    required this.currentStatus,
    this.batchId,
    this.dimensions,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  String? get dimensionsLabel {
    if (dimensions == null) return null;
    final p = dimensions!['p'];
    final l = dimensions!['l'];
    final t = dimensions!['t'];
    if (p == null || l == null || t == null) return null;
    String fmt(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();
    return '${fmt(p)} × ${fmt(l)} × ${fmt(t)} cm';
  }

  factory PackageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    Map<String, double>? dims;
    if (data['dimensions'] is Map) {
      final raw = data['dimensions'] as Map<String, dynamic>;
      dims = {
        'p': (raw['p'] as num?)?.toDouble() ?? 0,
        'l': (raw['l'] as num?)?.toDouble() ?? 0,
        't': (raw['t'] as num?)?.toDouble() ?? 0,
      };
    }

    return PackageModel(
      id: doc.id,
      trackingCode: data['trackingCode'] ?? data['marketplaceResi'] ?? '',
      recipientName: data['recipientName'] ?? '',
      recipientPhone: data['recipientPhone'] ?? '',
      destinationCity: data['destinationCity'] ?? '',
      currentStatus: PackageStatus.fromValue(data['currentStatus'] ?? ''),
      batchId: data['batchId'],
      dimensions: dims,
      createdBy: data['createdBy'] ?? '',
      updatedBy: data['updatedBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'trackingCode': trackingCode,
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
      'destinationCity': destinationCity,
      'currentStatus': currentStatus.value,
      'batchId': batchId,
      if (dimensions != null) 'dimensions': dimensions,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateFirestore(String adminEmail) {
    return {
      'trackingCode': trackingCode,
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
      'destinationCity': destinationCity,
      'currentStatus': currentStatus.value,
      'batchId': batchId,
      if (dimensions != null) 'dimensions': dimensions,
      'updatedBy': adminEmail,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
