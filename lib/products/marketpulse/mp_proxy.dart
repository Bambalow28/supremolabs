// Browsers block most RSS and price endpoints (no CORS headers), so the
// MarketPulse console can send its fetches through a proxy the user owns.
// The app's own services call `http.get` directly; running the whole site in
// an http.Client zone (see main.dart) reroutes just those calls, untouched.
// Unset, everything passes straight through and the console says so.
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const _prefKey = 'mp_web_proxy_v1';

/// Hosts that must never go through the proxy: the site's own backends and
/// anything that already allows browser calls with the user's key.
const _direct = [
  'googleapis.com',
  'firebaseio.com',
  'firebaseapp.com',
  'gstatic.com',
  'supabase.co',
  'supremolabs.com',
  'anthropic.com',
  'workers.dev',
  'localhost',
];

class MPProxy {
  MPProxy._();

  /// The Worker in tool/mp_proxy_worker.js; it only answers supremolabs.com
  /// and the feed hosts the app reads. Saving an empty field means direct.
  static const defaultUrl = 'https://mp-proxy.joshalanis28.workers.dev';

  static String url = defaultUrl;

  static Future<void> load() async => url =
      (await SharedPreferences.getInstance()).getString(_prefKey) ?? defaultUrl;

  static Future<void> save(String v) async {
    url = v.trim().replaceAll(RegExp(r'/+$'), '');
    await (await SharedPreferences.getInstance()).setString(_prefKey, url);
  }
}

class MPClient extends http.BaseClient {
  final http.Client _inner;
  MPClient({http.Client? inner}) : _inner = inner ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest r) {
    final host = r.url.host;
    if (MPProxy.url.isEmpty ||
        _direct.any((d) => host == d || host.endsWith('.$d'))) {
      return _inner.send(r);
    }
    final routed =
        http.Request(
            r.method,
            Uri.parse(
              '${MPProxy.url}/?url=${Uri.encodeComponent(r.url.toString())}',
            ),
          )
          ..headers.addAll({
            for (final e in r.headers.entries)
              // the browser sets its own UA; the proxy forwards this one instead
              if (e.key.toLowerCase() == 'user-agent')
                'x-forward-ua': e.value
              else
                e.key: e.value,
          })
          ..bodyBytes = r is http.Request ? r.bodyBytes : const [];
    return _inner.send(routed);
  }
}
