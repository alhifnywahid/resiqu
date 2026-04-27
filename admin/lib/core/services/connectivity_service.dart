import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

/// Global connectivity service that monitors network state.
/// Firestore automatically queues writes offline and syncs on reconnect.
/// This service provides UI feedback about connectivity status.
class ConnectivityService extends GetxService {
  final _connectivity = Connectivity();
  final RxBool isOnline = true.obs;
  final RxBool hasPendingWrites = false.obs;
  StreamSubscription? _sub;

  @override
  void onInit() {
    super.onInit();
    _checkInitial();
    _sub = _connectivity.onConnectivityChanged.listen(_onChanged);
  }

  Future<void> _checkInitial() async {
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);
  }

  void _onChanged(List<ConnectivityResult> results) {
    _updateStatus(results);

    // When coming back online, Firestore auto-syncs pending writes
    if (isOnline.value) {
      FirebaseFirestore.instance.enableNetwork();
    }
  }

  void _updateStatus(List<ConnectivityResult> results) {
    isOnline.value = results.any((r) => r != ConnectivityResult.none);
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
