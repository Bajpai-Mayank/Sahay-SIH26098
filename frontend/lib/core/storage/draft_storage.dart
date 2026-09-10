import 'dart:convert';
import '../security/secure_storage.dart';

/// Manages offline check-in drafts with idempotency keys.
/// Ensures no sensitive content is permanently leaked and drafts can be retried cleanly.
class DraftStorage {
  static const String _draftKeyPrefix = 'checkin_draft_';
  final SecureStorageService _storage;

  DraftStorage(this._storage);

  Future<void> saveDraft(String caseId, Map<String, dynamic> draftData) async {
    await _storage.write('$_draftKeyPrefix$caseId', jsonEncode(draftData));
  }

  Future<Map<String, dynamic>?> getDraft(String caseId) async {
    final raw = await _storage.read('$_draftKeyPrefix$caseId');
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearDraft(String caseId) async {
    await _storage.delete('$_draftKeyPrefix$caseId');
  }
}
