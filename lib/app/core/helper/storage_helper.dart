import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  StorageHelper._internal();

  static final StorageHelper _instance = StorageHelper._internal();

  factory StorageHelper() => _instance;

  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> writeString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  Future<bool> writeBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  Future<bool> writeInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  String? readString(String key) {
    return _prefs.getString(key);
  }

  bool? readBool(String key) {
    return _prefs.getBool(key);
  }

  int? readInt(String key) {
    return _prefs.getInt(key);
  }

  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  Future<bool> clearAll() async {
    return await _prefs.clear();
  }
}
