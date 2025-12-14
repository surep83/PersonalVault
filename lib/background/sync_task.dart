import 'dart:typed_data';
import '../storage/sqlite_service.dart';
import '../sync/drive_sync.dart';
import '../crypto/vault_crypto.dart';
import '../crypto/thumbnail_generator.dart';
import '../models/item.dart';

void syncBackgroundTask() async {
  final sqlite = SQLiteService();
  await sqlite.init();

  final vaultCrypto = VaultCrypto();
  await vaultCrypto.initDb();

  final driveSync = DriveSync();
  await driveSync.init();

  // Fetch pending items
  final pendingItems = await sqlite.getPendingItems(); // localState: created/updated

  for(final item in pendingItems) {
    // Generate thumbnail if missing and type is document/image
    Uint8List? thumb = item.thumbnail;
    if((item.type=='document' || item.type=='image') && thumb == null) {
      thumb = await ThumbnailGenerator.generateThumbnail(item);
    }

    final newItem = VaultItem(
      id: item.id,
      type: item.type,
      folder: item.folder,
      fields: item.fields,
      envelope: item.envelope,
      version: item.version,
      lastModified: item.lastModified,
      tags: item.tags,
      thumbnail: thumb,
      localState: 'synced'
    );

    // Update SQLite with thumbnail and synced state
    await sqlite.updateItem(newItem);

    // Upload to Google Drive
    await driveSync.incrementalSyncItem(newItem.id, newItem.envelope, newItem.version, newItem.lastModified, type: newItem.type, tags: newItem.tags);
  }
}
