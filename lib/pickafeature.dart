library;

export 'src/pickafeature_config.dart';
export 'src/pickafeature_controller.dart';
export 'src/ui/pickafeature_screen.dart';
export 'src/ui/feature_request_screen.dart';
export 'src/services/api_service.dart';
export 'src/models/user.dart';
export 'src/models/feature_request.dart';
export 'src/models/comment.dart';
export 'src/services/user_manager.dart';

import 'package:pickafeature/src/models/feature_request.dart';
import 'src/pickafeature_config.dart';
import 'src/pickafeature_controller.dart';
import 'src/models/user.dart';
import 'src/services/user_manager.dart';

/// Main entry point for the pick a feature SDK.
///
/// Call [initialize] once at startup, then embed [PickAFeatureScreen] in your
/// app or call the static methods on this class directly.
class PickAFeature {
  static PickAFeatureController? _controller;
  static PickAFeatureConfig? _config;

  /// Initialize the SDK with a [config]. Required before calling any other
  /// method on this class. Pass your API key via [PickAFeatureConfig.apiKey].
  static Future<void> initialize({
    PickAFeatureConfig? config,
  }) async {
    _config = config ?? PickAFeatureConfig();
    _controller = PickAFeatureController(
      config: _config!,
    );

    await _controller!.initialize();
  }

  /// Identify the current user. Stores the values locally; the [email]
  /// is automatically attached to future feedback submissions made through
  /// this SDK so requests can be attributed to a specific user in the
  /// dashboard. [name] is stored locally for app convenience.
  ///
  /// Call once after sign-in. Call [clearUserData] on sign-out.
  static Future<void> updateUser({
    String? email,
    String? name,
  }) async {
    if (_controller == null) {
      throw StateError('PickAFeature not initialized. Call PickAFeature.initialize() first.');
    }

    final userManager = PickAFeatureUserManager();
    final currentUser = await userManager.loadUser();

    final updatedUser = PickAFeatureUser(
      email: email ?? currentUser?.email,
      name: name ?? currentUser?.name,
      customId: currentUser?.customId,
    );

    await userManager.saveUser(updatedUser);
  }

  /// Returns the locally cached user, or null if [updateUser] was never called.
  static Future<PickAFeatureUser?> getCurrentUser() async {
    final userManager = PickAFeatureUserManager();
    return await userManager.loadUser();
  }

  /// Removes all locally cached user data (email, name, custom ID, payment).
  /// The anonymous device ID remains.
  static Future<void> clearUserData() async {
    final userManager = PickAFeatureUserManager();
    await userManager.clearUser();
  }

  /// Returns approved + completed feature requests for the current project.
  static Future<List<FeatureRequest>> getFeedbackRequests() async {
    if (_controller == null) {
      throw StateError('PickAFeature not initialized. Call PickAFeature.initialize() first.');
    }

    return await _controller!.getFeedbackRequests();
  }

  /// Upvotes the feature request with the given [feedbackId].
  static Future<Map<String, dynamic>> upvoteFeedback(String feedbackId) async {
    if (_controller == null) {
      throw StateError('PickAFeature not initialized. Call PickAFeature.initialize() first.');
    }

    return await _controller!.upvoteFeedback(feedbackId);
  }

  /// Pings the backend; returns true if reachable with valid credentials.
  static Future<bool> testConnection() async {
    if (_controller == null) {
      throw StateError('PickAFeature not initialized. Call PickAFeature.initialize() first.');
    }

    return await _controller!.testConnection();
  }

  /// Whether [initialize] has been called.
  static bool get isInitialized => _controller != null && _controller!.isInitialized;

  /// Releases internal resources. Call when your app shuts down.
  static void dispose() {
    _controller?.dispose();
    _controller = null;
    _config = null;
  }
}
