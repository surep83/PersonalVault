import 'dart:typed_data';

class VaultItem {
  final String id;
  final String type; // password, document, contact, event, custom
  final String folder;
  final Map<String, dynamic> fields;
  final Uint8List envelope;
  final int version;
  final int lastModified;
  final List<String> tags;
  final Uint8List? thumbnail;
  final String localState; // created, updated, synced

  VaultItem({
    required this.id,
    required this.type,
    required this.folder,
    required this.fields,
    required this.envelope,
    required this.version,
    required this.lastModified,
    this.tags = const [],
    this.thumbnail,
    this.localState = 'created',
  });
}
