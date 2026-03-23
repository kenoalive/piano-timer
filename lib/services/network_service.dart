import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  final Connectivity _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();

  Stream<bool> get onNetworkChange => _controller.stream;
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  NetworkService() {
    _init();
  }

  Future<void> _init() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus([result]);

    _connectivity.onConnectivityChanged.listen((result) {
      _updateStatus([result]);
    });
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    _isOnline = results.isNotEmpty &&
        results.any((r) => r != ConnectivityResult.none);

    if (wasOnline != _isOnline) {
      _controller.add(_isOnline);
    }
  }

  Future<bool> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus([result]);
    return _isOnline;
  }

  void dispose() {
    _controller.close();
  }
}
