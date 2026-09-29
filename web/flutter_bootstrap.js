{{flutter_js}}
{{flutter_build_config}}

// main.dart.js and the asset files (the icon font above all) keep their names
// every build, and Cloudflare caches them for 4h — so a deploy would keep
// serving stale code and a stale icon subset. firebase.json predeploy swaps
// __BUILD__ for the deploy timestamp and copies assets/ under /b/<stamp>/, so
// every deploy loads from URLs no cache has seen. Unstamped (flutter run)
// nothing changes.
const build = "__BUILD__";
const stamped = build !== "__" + "BUILD__";
for (const b of _flutter.buildConfig.builds) {
  if (b.mainJsPath) b.mainJsPath += "?v=" + build;
}
_flutter.loader.load(
  stamped ? { config: { assetBase: "/b/" + build + "/" } } : {},
);
