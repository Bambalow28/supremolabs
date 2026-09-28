// Saves a CSV through the browser. The web build is the only one that runs
// this; other targets (the VM tests) get a stub that does nothing.
export 'csv_download_stub.dart'
    if (dart.library.js_interop) 'csv_download_web.dart';
