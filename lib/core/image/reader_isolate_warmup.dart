import 'dart:isolate';

/// Pings a worker isolate so the VM pool is warm before the reader loads images.
/// Heavy image decode still runs on the engine raster path; this only avoids UI jank on first spawn.
Future<void> warmReaderImageWorker() => Isolate.run(() => 1);
