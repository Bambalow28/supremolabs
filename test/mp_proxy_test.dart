import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supremolabs/products/marketpulse/mp_proxy.dart';

void main() {
  test(
    'MPClient passes through unset, skips own hosts, reroutes the rest',
    () async {
      final seen = <Uri>[];
      final headers = <Map<String, String>>[];
      Future<void> hit(String url) async {
        await http.runWithClient(
          () => http.get(Uri.parse(url), headers: {'User-Agent': 'MP/1'}),
          () => MPClient(
            inner: MockClient((r) async {
              seen.add(r.url);
              headers.add(r.headers);
              return http.Response('', 200);
            }),
          ),
        );
      }

      MPProxy.url = '';
      await hit('https://www.cnbc.com/rss');
      expect(seen.last.host, 'www.cnbc.com');

      MPProxy.url = 'https://p.example.workers.dev';
      await hit('https://www.cnbc.com/rss');
      expect(seen.last.host, 'p.example.workers.dev');
      expect(seen.last.queryParameters['url'], 'https://www.cnbc.com/rss');
      expect(headers.last['x-forward-ua'], 'MP/1');

      await hit('https://firestore.googleapis.com/x');
      expect(seen.last.host, 'firestore.googleapis.com');
      await hit(
        'https://notsupremolabs.com/x',
      ); // suffix without a dot is not ours
      expect(seen.last.host, 'p.example.workers.dev');
      MPProxy.url = '';
    },
  );
}
