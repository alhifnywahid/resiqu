import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/package_status.dart';
import '../domain/batch_model.dart';

class BatchRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _batchesRef => _firestore.collection('batches');
  CollectionReference get _packagesRef => _firestore.collection('packages');

  /// Safely get a query snapshot: tries server first, falls back to cache.
  Future<QuerySnapshot> _safeGet(Query query) async {
    try {
      return await query.get(const GetOptions(source: Source.serverAndCache));
    } catch (_) {
      return await query.get(const GetOptions(source: Source.cache));
    }
  }

  /// Safely get a single document: tries server first, falls back to cache.
  Future<DocumentSnapshot> _safeGetDoc(DocumentReference ref) async {
    try {
      return await ref.get(const GetOptions(source: Source.serverAndCache));
    } catch (_) {
      return await ref.get(const GetOptions(source: Source.cache));
    }
  }

  Stream<List<BatchModel>> getBatchesStream() {
    return _batchesRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => BatchModel.fromFirestore(d)).toList());
  }

  Future<int> getBatchesCount() async {
    try {
      final snapshot = await _batchesRef.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      // Fallback if aggregate count fails (e.g. offline)
      final snapshot = await _safeGet(_batchesRef);
      return snapshot.docs.length;
    }
  }

  Future<Map<String, int>> getBatchStatusCounts() async {
    final snapshot = await _safeGet(_batchesRef);
    final counts = <String, int>{
      'collecting': 0,
      'dispatched': 0,
      'arrived': 0,
    };

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['status'] as String? ?? '';
      counts[status] = (counts[status] ?? 0) + 1;
    }

    return counts;
  }


  Future<BatchModel?> getBatchById(String id) async {
    final doc = await _safeGetDoc(_batchesRef.doc(id));
    if (!doc.exists) return null;
    return BatchModel.fromFirestore(doc);
  }

  /// Creates a batch using WriteBatch instead of Transaction.
  /// WriteBatch queues writes locally when offline and syncs on reconnect.
  Future<String> createBatch({
    required String name,
    required String destinationCity,
    required List<String> packageIds,
    required String adminEmail,
    DateTime? startDate,
    DateTime? expiryDate,
  }) async {
    final batchRef = _batchesRef.doc();
    final writeBatch = _firestore.batch();

    // Create batch document
    writeBatch.set(batchRef, {
      'name': name,
      'destinationCity': destinationCity,
      'status': BatchStatus.collecting.value,
      'packageIds': packageIds,
      'createdBy': adminEmail,
      'createdAt': FieldValue.serverTimestamp(),
      if (startDate != null) 'startDate': Timestamp.fromDate(startDate),
      if (expiryDate != null) 'expiryDate': Timestamp.fromDate(expiryDate),
    });

    // Update each package: assign batchId
    for (final pkgId in packageIds) {
      writeBatch.update(_packagesRef.doc(pkgId), {
        'batchId': batchRef.id,
        'updatedBy': adminEmail,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await writeBatch.commit();
    return batchRef.id;
  }

  Future<void> updateBatch({
    required String id,
    required String name,
    required String destinationCity,
    required String adminEmail,
    DateTime? startDate,
    DateTime? expiryDate,
  }) async {
    final batchRef = _batchesRef.doc(id);
    await batchRef.update({
      'name': name,
      'destinationCity': destinationCity,
      'updatedBy': adminEmail,
      'updatedAt': FieldValue.serverTimestamp(),
      'startDate': startDate != null ? Timestamp.fromDate(startDate) : FieldValue.delete(),
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate) : FieldValue.delete(),
    });
  }

  Future<void> addPackagesToBatch({
    required String batchId,
    required List<String> packageIds,
    required String adminEmail,
  }) async {
    if (packageIds.isEmpty) return;
    
    final writeBatch = _firestore.batch();
    
    writeBatch.update(_batchesRef.doc(batchId), {
      'packageIds': FieldValue.arrayUnion(packageIds),
    });
    
    for (final pkgId in packageIds) {
      final pkgRef = _packagesRef.doc(pkgId);
      writeBatch.update(pkgRef, {
        'batchId': batchId,
        'currentStatus': PackageStatus.inBox.value,
        'updatedBy': adminEmail,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      writeBatch.set(pkgRef.collection('statusHistory').doc(), {
        'status': PackageStatus.inBox.value,
        'note': 'Paket dimasukkan ke dalam kontainer/box',
        'updatedBy': adminEmail,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
    
    await writeBatch.commit();
  }

  /// Dispatches a batch using WriteBatch for offline support.
  Future<void> dispatchBatch({
    required String batchId,
    required List<String> packageIds,
    required String adminEmail,
  }) async {
    final writeBatch = _firestore.batch();

    writeBatch.update(_batchesRef.doc(batchId), {
      'status': 'dispatched',
      'dispatchedAt': FieldValue.serverTimestamp(),
    });

    for (final pkgId in packageIds) {
      writeBatch.update(_packagesRef.doc(pkgId), {
        'currentStatus': PackageStatus.inTransit.value,
        'updatedBy': adminEmail,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await writeBatch.commit();

    // Status history entries (also queued offline)
    for (final pkgId in packageIds) {
      await _packagesRef.doc(pkgId).collection('statusHistory').add({
        'status': PackageStatus.inTransit.value,
        'note': 'Batch dikirim ke tujuan',
        'updatedBy': adminEmail,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Marks batch as arrived and cascades status to all packages inside.
  Future<void> arriveBatch({
    required String batchId,
    required List<String> packageIds,
    required String adminEmail,
  }) async {
    final writeBatch = _firestore.batch();

    writeBatch.update(_batchesRef.doc(batchId), {
      'status': BatchStatus.arrived.value,
      'arrivedAt': FieldValue.serverTimestamp(),
    });

    for (final pkgId in packageIds) {
      writeBatch.update(_packagesRef.doc(pkgId), {
        'currentStatus': PackageStatus.arrived.value,
        'updatedBy': adminEmail,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await writeBatch.commit();

    for (final pkgId in packageIds) {
      await _packagesRef.doc(pkgId).collection('statusHistory').add({
        'status': PackageStatus.arrived.value,
        'note': 'Box tiba di tujuan',
        'updatedBy': adminEmail,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Removes a package from a batch and reverts its status to transit.
  Future<void> removePackageFromBatch({
    required String batchId,
    required String packageId,
    required String adminEmail,
  }) async {
    final writeBatch = _firestore.batch();

    // Remove packageId from batch's array
    writeBatch.update(_batchesRef.doc(batchId), {
      'packageIds': FieldValue.arrayRemove([packageId]),
    });

    // Reset package: clear batchId, revert status to transit
    final pkgRef = _packagesRef.doc(packageId);
    writeBatch.update(pkgRef, {
      'batchId': null,
      'currentStatus': PackageStatus.transit.value,
      'updatedBy': adminEmail,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Log status history
    writeBatch.set(pkgRef.collection('statusHistory').doc(), {
      'status': PackageStatus.transit.value,
      'note': 'Paket dikeluarkan dari kontainer/box',
      'updatedBy': adminEmail,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await writeBatch.commit();
  }
}
