import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


/// Simple SQLite service to store credential entries.
class SQLiteService {
	static final SQLiteService _instance = SQLiteService._internal();
	factory SQLiteService() => _instance;
	SQLiteService._internal();

	Database? _db;
	// In-memory fallback for unsupported platforms (web) or when sqlite isn't available.
	final List<Map<String, dynamic>> _inMemoryRows = [];
	bool _useInMemory = false;

	Future<void> init() async {
		if (_db != null) return;
		// On web and some test environments, `sqflite` and `path_provider` are not available.
		if (kIsWeb) {
			_useInMemory = true;
			// load persisted rows from SharedPreferences if available
			try {
				final prefs = await SharedPreferences.getInstance();
				final s = prefs.getString('credentials');
				if (s != null) {
					final List<dynamic> decoded = jsonDecode(s);
					_inMemoryRows.clear();
					for (final e in decoded) {
						_inMemoryRows.add(Map<String, dynamic>.from(e as Map));
					}
				}
			} catch (_) {
				// ignore
			}
			return;
		}
        
		try {
			final documentsDirectory = await getApplicationDocumentsDirectory();
			final path = join(documentsDirectory.path, 'personal_vault.db');
            
			_db = await openDatabase(
				path,
				version: 1,
				onCreate: (db, version) async {
					await db.execute('''
						CREATE TABLE credentials(
							id INTEGER PRIMARY KEY AUTOINCREMENT,
							user_id TEXT NOT NULL,
							password TEXT NOT NULL,
							url TEXT,
							created_at INTEGER NOT NULL
						)
					''');
				},
			);
		} catch (_) {
			// If any platform-specific call fails, fall back to in-memory storage to avoid blocking the UI.
			_useInMemory = true;
		}
	}

	Future<int> insertCredential({required String userId, required String password, String? url}) async {
		await init();
		final now = DateTime.now().millisecondsSinceEpoch;
		if (_useInMemory) {
			final id = (_inMemoryRows.isEmpty ? 1 : (_inMemoryRows.first['id'] as int) + 1);
			final row = {
				'id': id,
				'user_id': userId,
				'password': password,
				'url': url,
				'created_at': now,
			};
			_inMemoryRows.insert(0, row);
			// persist to SharedPreferences when on web
			if (kIsWeb) {
				try {
					final prefs = await SharedPreferences.getInstance();
					await prefs.setString('credentials', jsonEncode(_inMemoryRows));
				} catch (_) {}
			}
			return id;
		}
        
		final id = await _db!.insert('credentials', {
			'user_id': userId,
			'password': password,
			'url': url,
			'created_at': now,
		});
		return id;
	}

	/// Compatibility shim used by background sync; returns empty list.
	Future<List<dynamic>> getPendingItems() async {
		return <dynamic>[];
	}

	/// Compatibility shim for `updateItem` used by background sync.
	Future<void> updateItem(dynamic item) async {
		// No-op for now.
		return;
	}

	Future<List<Map<String, dynamic>>> getAllCredentials() async {
		await init();
		if (_useInMemory) {
			return List<Map<String, dynamic>>.from(_inMemoryRows);
		}
		final rows = await _db!.query('credentials', orderBy: 'created_at DESC');
		return rows;
	}

	Future<void> close() async {
		await _db?.close();
		_db = null;
	}
}
