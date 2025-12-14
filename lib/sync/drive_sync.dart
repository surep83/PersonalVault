import 'dart:typed_data';

/// Minimal DriveSync stub used by background sync.
/// Implement real Drive API integration in this module.
class DriveSync {
	Future<void> init() async {
		// perform auth/setup (stub)
		return;
	}

	Future<void> incrementalSyncItem(String id, Uint8List envelope, int version, int lastModified, {required String? type, List<String>? tags}) async {
		// upload or update item on remote (stub)
		return;
	}
}
