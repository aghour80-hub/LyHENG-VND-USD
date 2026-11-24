import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NetworkStatus { online, offline, connecting }

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final networkStatusProvider = StreamProvider<NetworkStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.statusStream;
});

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final _controller = StreamController<NetworkStatus>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityService() {
    _init();
  }

  Stream<NetworkStatus> get statusStream => _controller.stream;

  Future<void> _init() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _controller.add(_parseStatus(results));
    } catch (_) {
      _controller.add(NetworkStatus.online);
    }

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _controller.add(_parseStatus(results));
    });
  }

  NetworkStatus _parseStatus(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return NetworkStatus.offline;
    }
    return NetworkStatus.online;
  }

  Future<bool> isConnected() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return !results.contains(ConnectivityResult.none);
    } catch (_) {
      return true;
    }
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
