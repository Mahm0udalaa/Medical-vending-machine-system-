import 'dart:async';
import 'dart:io';

class InternetConnectivityService {
  final _controller = StreamController<bool>.broadcast();

  InternetConnectivityService() {
    // check connection every 5 seconds
    Timer.periodic(const Duration(seconds: 5), (_) async {
      bool isConnected = await _checkInternetConnection();
      _controller.add(isConnected);
    });
  }

  Stream<bool> get onStatusChange => _controller.stream;

  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _controller.close();
  }
}
