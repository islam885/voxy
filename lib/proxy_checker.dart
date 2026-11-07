import 'dart:async';
import 'dart:io';

class ProxyChecker {
  /// Real TCP Handshake Validator (Timeout: 1000ms)
  static Future<int?> checkTcpPing(String ip, int port, {int timeoutMs = 1200}) async {
    final stopwatch = Stopwatch()..start();
    try {
      final socket = await Socket.connect(
        ip,
        port,
        timeout: Duration(milliseconds: timeoutMs),
      );
      stopwatch.stop();
      socket.destroy();
      return stopwatch.elapsedMilliseconds;
    } catch (_) {
      return null; // Dead / Timeout
    }
  }

  /// Check Google Latency for HTTP Proxies
  static Future<int?> checkGoogleLatency(String ip, int port) async {
    final stopwatch = Stopwatch()..start();
    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(milliseconds: 1500)
        ..findProxy = (uri) => 'PROXY $ip:$port';

      final request = await client.getUrl(Uri.parse('http://google.com/generate_204'));
      final response = await request.close();
      stopwatch.stop();
      client.close(force: true);

      if (response.statusCode == 204 || response.statusCode == 200 || response.statusCode == 301 || response.statusCode == 302) {
        return stopwatch.elapsedMilliseconds;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
