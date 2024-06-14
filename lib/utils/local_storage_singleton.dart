import 'dart:async' show Future;
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton class to store and retrieve user preferences
class LocalStorage {
  static late SharedPreferences _prefsInstance;

  static Future<SharedPreferences> init() async {
    _prefsInstance = await SharedPreferences.getInstance();
    return _prefsInstance;
  }

  static Future<bool> clear() async {
    return _prefsInstance.clear();
  }

  // ----------------Getters----------------

  static bool getBool(String key) {
    return _prefsInstance.getBool(key) ?? true;
  }

  static int getInt(String key) {
    return _prefsInstance.getInt(key) ?? 0;
  }

  static double getDouble(
    String key,
  ) {
    return _prefsInstance.getDouble(key) ?? 0.0;
  }

  static String getString(
    String key,
  ) {
    return _prefsInstance.getString(key) ?? "";
  }

  static List<String> getStringList(
    String key,
  ) {
    return _prefsInstance.getStringList(key) ?? [];
  }

  // ----------------Setters----------------

  static Future<bool> setBool(String key, bool value) {
    return _prefsInstance.setBool(key, value);
  }

  static Future<bool> setInt(String key, int value) {
    return _prefsInstance.setInt(key, value);
  }

  static Future<bool> setDouble(String key, double value) {
    return _prefsInstance.setDouble(key, value);
  }

  static Future<bool> setString(String key, String value) async {
    return _prefsInstance.setString(key, value);
  }

  static Future<bool> setStringList(String key, List<String> value) {
    return _prefsInstance.setStringList(key, value);
  }
}
