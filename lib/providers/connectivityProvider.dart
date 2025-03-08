import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkProvider with ChangeNotifier {
  bool _isOnline = false;
  bool get isOnline => _isOnline;

  NetworkProvider() {
    _checkConnectivity();
  }

  void _checkConnectivity() async {
    try {
      // Initial check with a small delay
      await Future.delayed(Duration(seconds: 1)); // Add a slight delay
      var connectivityResult = await Connectivity().checkConnectivity();
      print("trexing");
      print(connectivityResult);
      _updateConnectionStatus(connectivityResult);

      // Listening for future connectivity changes
      Connectivity().onConnectivityChanged.listen((result) {
        _updateConnectionStatus(result);
      });
    } catch (e) {
      print("Error checking connectivity: $e");
      _isOnline = false; // Assume offline if there's an error
      notifyListeners();
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    bool newStatus = result[0] != ConnectivityResult.none;
    if (_isOnline != newStatus) {
      _isOnline = newStatus;
      notifyListeners();
      print(_isOnline ? "Online" : "Offline"); // Debugging output
    }
  }

  @override
  void dispose() {
    // Cancel any subscriptions or listeners here if needed
    super.dispose();
  }
}