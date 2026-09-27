{{flutter_js}}
{{flutter_build_config}}

// main.dart.js keeps its name every build and Cloudflare caches .js for 4h,
// so a deploy would keep serving stale code. firebase.json predeploy swaps
// __BUILD__ for the deploy timestamp.
for (const b of _flutter.buildConfig.builds) {
  if (b.mainJsPath) b.mainJsPath += "?v=__BUILD__";
}
_flutter.loader.load();
