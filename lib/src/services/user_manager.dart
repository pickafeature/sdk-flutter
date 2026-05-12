import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';

/// Manages user data storage and retrieval
class PickAFeatureUserManager {
  static const String _userDataKey = 'wishkit_user_data';
  static const String _deviceIdKey = 'wishkit_device_id';

  static final PickAFeatureUserManager _instance = PickAFeatureUserManager._internal();
  factory PickAFeatureUserManager() => _instance;
  PickAFeatureUserManager._internal();

  // Cache SharedPreferences instance and deviceId for faster access
  SharedPreferences? _prefs;
  String? _cachedDeviceId;

  Future<SharedPreferences> get _sharedPrefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Store user data locally
  Future<void> saveUser(PickAFeatureUser user) async {
    final prefs = await _sharedPrefs;
    final userData = user.copyWith(lastUpdated: DateTime.now());
    
    await prefs.setString(_userDataKey, jsonEncode(userData.toJson()));
  }
  
  /// Load user data from local storage
  Future<PickAFeatureUser?> loadUser() async {
    try {
      final prefs = await _sharedPrefs;
      final userDataString = prefs.getString(_userDataKey);
      if (userDataString == null) return null;
      
      final userData = jsonDecode(userDataString);
      return PickAFeatureUser.fromJson(userData);
    } catch (e) {
      // If there's an error loading user data, return null
      return null;
    }
  }
  
  /// Clear user data from local storage
  Future<void> clearUser() async {
    final prefs = await _sharedPrefs;
    await prefs.remove(_userDataKey);
  }

  /// Generate or retrieve device ID
  Future<String> getDeviceId() async {
    // Return cached value if available
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }

    final prefs = await _sharedPrefs;
    String? deviceId = prefs.getString(_deviceIdKey);

    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString(_deviceIdKey, deviceId);
    }

    _cachedDeviceId = deviceId;
    return deviceId;
  }
  
  /// Check if user has any data stored
  Future<bool> hasUserData() async {
    final user = await loadUser();
    return user != null && (user.email != null || user.name != null || user.customId != null);
  }

  /// Clear caches (useful for testing)
  void clearCache() {
    _prefs = null;
    _cachedDeviceId = null;
  }
} 