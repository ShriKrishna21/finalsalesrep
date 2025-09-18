import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class ConnectivityHelper {
  static final ConnectivityHelper _instance = ConnectivityHelper._internal();
  factory ConnectivityHelper() => _instance;
  ConnectivityHelper._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;

  void startListening(void Function(bool isOnline) onChange) {
    _sub = _connectivity.onConnectivityChanged.listen((resList) async {
      final anyConnected = resList.any((r) => r != ConnectivityResult.none);
      onChange(anyConnected);
    });
  }

  Future<bool> checkInternet() async {
    var res = await _connectivity.checkConnectivity();
    if (res == ConnectivityResult.none) return false;
    return true;
  }

  void dispose() {
    _sub?.cancel();
  }
}
