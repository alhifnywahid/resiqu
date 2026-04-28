import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/package_status.dart';
import '../../../core/utils/string_utils.dart';
import '../domain/package_model.dart';
import '../domain/status_history_model.dart';

class PackageRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _packagesRef => _firestore.collection('packages');


  Future<String> addPackage({
    required String trackingCode,
    required String recipientName,
    required String adminEmail,
    String? batchId,
    Map<String, double>? dimensions,
  }) async {
    final normalizedCode = trackingCode.trim().toUpperCase();
    final docRef = _packagesRef.doc();

    final status = PackageStatus.transit.value;

    final packageData = {
      'trackingCode': normalizedCode,
      'recipientName': toTitleCase(recipientName),
      'recipientPhone': '',
      'destinationCity': '',
      'currentStatus': status,
      'batchId': batchId,
      ...?((dimensions != null) ? {'dimensions': dimensions} : null),
      'createdBy': adminEmail,
      'updatedBy': adminEmail,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (batchId != null) {
      final writeBatch = _firestore.batch();
      final batchRef = _firestore.collection('batches').doc(batchId);
      
      writeBatch.set(docRef, packageData);
      writeBatch.update(batchRef, {
        'packageIds': FieldValue.arrayUnion([docRef.id])
      });
      
      await writeBatch.commit();
    } else {
      await docRef.set(packageData);
    }

    // Add initial status history
    await docRef.collection('statusHistory').add({
      'status': status,
      'note': batchId != null ? 'Paket langsung didaftarkan ke dalam box' : 'Paket diterima di transit',
      'updatedBy': adminEmail,
      'timestamp': FieldValue.serverTimestamp(),
    });

    return normalizedCode;
  }

  Future<bool> checkTrackingCodeExists(String trackingCode) async {
    final normalizedCode = trackingCode.trim().toUpperCase();
    final snapshot = await _packagesRef
        .where('trackingCode', isEqualTo: normalizedCode)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future<void> updatePackage({
    required String id,
    required String trackingCode,
    required String recipientName,
    required String adminEmail,
    String? batchId,
    Map<String, double>? dimensions,
  }) async {
    final normalizedCode = trackingCode.trim().toUpperCase();
    final docRef = _packagesRef.doc(id);

    final updates = {
      'trackingCode': normalizedCode,
      'recipientName': toTitleCase(recipientName),
      'batchId': batchId,
      'dimensions': dimensions ?? FieldValue.delete(),
      'updatedBy': adminEmail,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await docRef.update(updates);
  }

  Future<void> deletePackage(String id) async {
    // Delete statusHistory subcollection first
    final historySnapshot = await _packagesRef.doc(id).collection('statusHistory').get();
    final writeBatch = _firestore.batch();
    
    for (final doc in historySnapshot.docs) {
      writeBatch.delete(doc.reference);
    }
    
    writeBatch.delete(_packagesRef.doc(id));
    await writeBatch.commit();
  }

  /// Get distinct recipient names for autocomplete suggestions
  Future<List<String>> getDistinctRecipientNames() async {
    final snapshot = await _packagesRef.get();
    final names = <String>{};
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>?;
      final name = data?['recipientName'] as String?;
      if (name != null && name.trim().isNotEmpty) {
        names.add(name.trim());
      }
    }
    final sorted = names.toList()..sort();
    return sorted;
  }

  Stream<List<PackageModel>> getPackagesStream() {
    return _packagesRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PackageModel.fromFirestore(doc)).toList());
  }

  Future<PackageModel?> getPackageById(String id) async {
    final doc = await _packagesRef.doc(id).get();
    if (!doc.exists) return null;
    return PackageModel.fromFirestore(doc);
  }

  Future<List<PackageModel>> searchPackages(String query) async {
    // Return all packages when query is empty (used by batch selection)
    if (query.isEmpty) {
      final all = await _packagesRef.orderBy('createdAt', descending: true).get();
      return all.docs.map((doc) => PackageModel.fromFirestore(doc)).toList();
    }

    // Search by tracking code first
    final byTracking = await _packagesRef
        .where('trackingCode', isEqualTo: query.toUpperCase())
        .get();

    if (byTracking.docs.isNotEmpty) {
      return byTracking.docs
          .map((doc) => PackageModel.fromFirestore(doc))
          .toList();
    }

    // Fallback: search by trackingCode with original case
    final byResi = await _packagesRef
        .where('trackingCode', isEqualTo: query)
        .get();

    if (byResi.docs.isNotEmpty) {
      return byResi.docs
          .map((doc) => PackageModel.fromFirestore(doc))
          .toList();
    }

    // Fallback: get all and filter client-side (MVP approach)
    final all = await _packagesRef.get();
    final lowerQuery = query.toLowerCase();
    return all.docs
        .map((doc) => PackageModel.fromFirestore(doc))
        .where((pkg) =>
            pkg.recipientName.toLowerCase().contains(lowerQuery) ||
            pkg.trackingCode.toLowerCase().contains(lowerQuery))
        .toList();
  }

  Stream<List<StatusHistoryModel>> getStatusHistory(String packageId) {
    return _packagesRef
        .doc(packageId)
        .collection('statusHistory')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StatusHistoryModel.fromFirestore(doc))
            .toList());
  }

  Future<Map<String, int>> getStatusCounts() async {
    final snapshot = await _packagesRef.get();
    final counts = <String, int>{};

    for (final status in PackageStatus.values) {
      counts[status.value] = 0;
    }

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['currentStatus'] as String? ?? '';
      counts[status] = (counts[status] ?? 0) + 1;
    }

    return counts;
  }

  Future<List<PackageModel>> getPackagesByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    // Firestore 'whereIn' supports max 30 items per query
    final results = <PackageModel>[];
    final chunks = <List<String>>[];

    for (var i = 0; i < ids.length; i += 30) {
      chunks.add(ids.sublist(i, i + 30 > ids.length ? ids.length : i + 30));
    }

    for (final chunk in chunks) {
      final snapshot = await _packagesRef
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      results.addAll(
        snapshot.docs.map((doc) => PackageModel.fromFirestore(doc)),
      );
    }

    return results;
  }
}
