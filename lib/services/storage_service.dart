import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Handles all local offline persistence using SharedPreferences
class StorageService {
  static const _kAuth = 'rkcnl_auth';
  static const _kPending = 'rkcnl_pending';
  static const _kSynced = 'rkcnl_synced';
  static const _kSyncTime = 'rkcnl_sync_time';
  static const _kHistory = 'rkcnl_sync_history';
  static const _kDarkMode = 'rkcnl_dark_mode';

  static String _respondentsKey(String surveyId) => 'rkcnl_resp_$surveyId';

  final SharedPreferences _prefs;
  StorageService(this._prefs);

  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // ── AUTH ──
  Map<String, dynamic>? getAuth() {
    final s = _prefs.getString(_kAuth);
    if (s == null) return null;
    return jsonDecode(s) as Map<String, dynamic>;
  }
  Future<void> saveAuth(Map<String, dynamic> data) =>
      _prefs.setString(_kAuth, jsonEncode(data));
  Future<void> clearAuth() => _prefs.remove(_kAuth);

  // ── RESPONDENTS ──
  List<Respondent> getRespondents(String surveyId) {
    final s = _prefs.getString(_respondentsKey(surveyId));
    if (s == null) return [];
    final list = jsonDecode(s) as List;
    return list.map((e) => Respondent.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveRespondent(String surveyId, Respondent respondent) async {
    final list = getRespondents(surveyId);
    final idx = list.indexWhere((r) => r.id == respondent.id);
    if (idx >= 0) {
      list[idx] = respondent;
    } else {
      list.add(respondent);
    }
    await _prefs.setString(
        _respondentsKey(surveyId), jsonEncode(list.map((r) => r.toJson()).toList()));
  }

  // ── PENDING SYNC ──
  List<Map<String, dynamic>> getPending() {
    final s = _prefs.getString(_kPending);
    if (s == null) return [];
    return (jsonDecode(s) as List).cast<Map<String, dynamic>>();
  }

  Future<void> addPending(Map<String, dynamic> item) async {
    final list = getPending();
    list.add(item);
    await _prefs.setString(_kPending, jsonEncode(list));
  }

  Future<void> clearPending() => _prefs.remove(_kPending);

  Future<void> savePending(List<Map<String, dynamic>> items) =>
      _prefs.setString(_kPending, jsonEncode(items));

  // ── SYNCED HISTORY ──
  List<Map<String, dynamic>> getSynced() {
    final s = _prefs.getString(_kSynced);
    if (s == null) return [];
    return (jsonDecode(s) as List).cast<Map<String, dynamic>>();
  }

  Future<void> addSynced(List<Map<String, dynamic>> items) async {
    final list = getSynced();
    list.addAll(items);
    await _prefs.setString(_kSynced, jsonEncode(list));
  }

  int? getLastSyncTime() => _prefs.getInt(_kSyncTime);
  Future<void> setLastSyncTime(int ts) => _prefs.setInt(_kSyncTime, ts);

  List<SyncHistoryItem> getSyncHistory() {
    final s = _prefs.getString(_kHistory);
    if (s == null) return [];
    return (jsonDecode(s) as List)
        .map((e) => SyncHistoryItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addSyncHistory(SyncHistoryItem item) async {
    final list = getSyncHistory();
    list.add(item);
    await _prefs.setString(_kHistory, jsonEncode(list.map((h) => h.toJson()).toList()));
  }

  // ── SETTINGS ──
  bool getDarkMode() => _prefs.getBool(_kDarkMode) ?? false;
  Future<void> setDarkMode(bool v) => _prefs.setBool(_kDarkMode, v);

  int storageUsedBytes() {
    int total = 0;
    for (final key in _prefs.getKeys()) {
      if (key.startsWith('rkcnl')) {
        total += _prefs.getString(key)?.length ?? 0;
      }
    }
    return total;
  }

  Future<void> clearCache() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith('rkcnl_resp')).toList();
    for (final k in keys) await _prefs.remove(k);
  }
}
