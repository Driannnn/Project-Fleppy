import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuth {
  LocalAuth._();
  static final LocalAuth instance = LocalAuth._();

  static const _kUsers = 'auth_users'; // Map<String email, String hash>
  static const _kCurrentUser = 'auth_current_user';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  String _hash(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }

  Future<Map<String, String>> _loadUsers() async {
    final p = await _prefs;
    final raw = p.getString(_kUsers);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v as String));
  }

  Future<void> _saveUsers(Map<String, String> users) async {
    final p = await _prefs;
    await p.setString(_kUsers, jsonEncode(users));
  }

  /// Register user baru. Throw jika sudah ada.
  Future<void> register({
    required String email,
    required String password,
  }) async {
    final users = await _loadUsers();
    final key = email.trim().toLowerCase();
    if (users.containsKey(key)) {
      throw LocalAuthException('Email sudah terdaftar.');
    }
    users[key] = _hash(password);
    await _saveUsers(users);
  }

  /// Login; throw kalau user tidak ada / password salah.
  Future<void> login({required String email, required String password}) async {
    final users = await _loadUsers();
    final key = email.trim().toLowerCase();
    if (!users.containsKey(key)) {
      throw LocalAuthException('Email tidak terdaftar.');
    }
    final ok = users[key] == _hash(password);
    if (!ok) {
      throw LocalAuthException('Password salah.');
    }
    final p = await _prefs;
    await p.setString(_kCurrentUser, key);
  }

    /// Cek apakah user dengan email tsb ada.
  Future<bool> userExists(String email) async {
    final users = await _loadUsers();
    final key = email.trim().toLowerCase();
    return users.containsKey(key);
  }

  /// Ganti password user (tanpa validasi password lama; untuk "lupa password").
  Future<void> updatePassword({required String email, required String newPassword}) async {
    final users = await _loadUsers();
    final key = email.trim().toLowerCase();
    if (!users.containsKey(key)) {
      throw LocalAuthException('Email tidak terdaftar.');
    }
    users[key] = _hash(newPassword);
    await _saveUsers(users);
  }

  /// Logout
  Future<void> logout() async {
    final p = await _prefs;
    await p.remove(_kCurrentUser);
  }

  /// Ambil user yang sedang login (jika ada)
  Future<String?> currentUser() async {
    final p = await _prefs;
    return p.getString(_kCurrentUser);
  }
}

class LocalAuthException implements Exception {
  final String message;
  LocalAuthException(this.message);
  @override
  String toString() => message;
}
