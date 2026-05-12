import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../models/comment.dart';
import '../models/feature_request.dart';
import 'user_manager.dart';

/// Service for handling API communication with PickAFeature backend
class ApiService {
  final String baseUrl;
  final String? apiKey;
  final http.Client _client;

  ApiService({
    required this.baseUrl,
    this.apiKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Get headers with API key
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (apiKey != null) 'x-api-key': apiKey!,
  };

  /// Build an [ApiException] from a non-2xx [response]. Reads the JSON body's
  /// `error` field if present, falls back to a status-based message, and
  /// honors `Retry-After` on 429 responses.
  ApiException _errorFromResponse(http.Response response, String fallback) {
    String message = fallback;
    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      if (body is Map && body['error'] is String) {
        message = body['error'] as String;
      }
    } catch (_) {
      // Body wasn't JSON — keep fallback.
    }

    int? retryAfter;
    if (response.statusCode == 429) {
      final header = response.headers['retry-after'];
      if (header != null) {
        retryAfter = int.tryParse(header);
      }
    }

    return ApiException(message, response.statusCode, retryAfter: retryAfter);
  }

  /// Helper method to ensure user exists (create if needed)
  Future<PickAFeatureUser> _ensureUserExists({String? userEmail}) async {
    final userManager = PickAFeatureUserManager();
    final currentUser = await userManager.loadUser();

    if (currentUser != null) {
      return currentUser;
    }

    final newUser = PickAFeatureUser(
      email: userEmail,
      customId: Uuid().v4(),
      lastUpdated: DateTime.now(),
    );

    await userManager.saveUser(newUser);
    return newUser;
  }

  /// Submit a feedback request
  Future<Map<String, dynamic>> submitFeedback({
    required String title,
    required String description,
    String? userEmail,
  }) async {
    try {
      final userManager = PickAFeatureUserManager();
      final results = await Future.wait([
        _ensureUserExists(userEmail: userEmail),
        userManager.getDeviceId(),
      ]);
      final userToUse = results[0] as PickAFeatureUser;
      final deviceId = results[1] as String;

      final response = await _client.post(
        Uri.parse('$baseUrl/feedback'),
        headers: _headers,
        body: jsonEncode({
          'title': title,
          'description': description,
          'email': userEmail ?? userToUse.email,
          'deviceId': deviceId,
          'userId': userToUse.customId,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      throw _errorFromResponse(response, 'Failed to submit feedback');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e', 0);
    }
  }

  /// Get all feature requests (approved + completed)
  Future<List<FeatureRequest>> getFeedbackRequests({String? status}) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/feedback'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final list = data['featureRequests'] ?? [];
        return (list as List)
            .map((json) => FeatureRequest.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw _errorFromResponse(response, 'Failed to load feature requests');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e', 0);
    }
  }

  /// Upvote a feature request
  Future<Map<String, dynamic>> upvoteFeedback(String feedbackId) async {
    return _vote(feedbackId, 'up');
  }

  /// Downvote (remove upvote) a feature request
  Future<Map<String, dynamic>> downvoteFeedback(String feedbackId) async {
    return _vote(feedbackId, 'down');
  }

  Future<Map<String, dynamic>> _vote(String feedbackId, String direction) async {
    try {
      final userManager = PickAFeatureUserManager();
      final results = await Future.wait([
        _ensureUserExists(),
        userManager.getDeviceId(),
      ]);
      final userToUse = results[0] as PickAFeatureUser;
      final deviceId = results[1] as String;

      final response = await _client.post(
        Uri.parse('$baseUrl/vote'),
        headers: _headers,
        body: jsonEncode({
          'featureRequestId': feedbackId,
          'deviceId': deviceId,
          'userId': userToUse.customId,
          'direction': direction,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      throw _errorFromResponse(response, 'Failed to vote');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e', 0);
    }
  }

  /// Test the API connection
  Future<bool> testConnection() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/feedback'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get comments for a specific feature request
  Future<List<Comment>> getComments(String featureRequestId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/comments?featureRequestId=$featureRequestId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final commentsList = data['comments'] ?? [];
        return commentsList.map<Comment>((json) => Comment.fromJson(json)).toList();
      }
      throw _errorFromResponse(response, 'Failed to load comments');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e', 0);
    }
  }

  /// Add a comment to a feature request
  Future<Comment> addComment({
    required String featureRequestId,
    required String content,
  }) async {
    try {
      final userManager = PickAFeatureUserManager();
      final results = await Future.wait([
        _ensureUserExists(),
        userManager.getDeviceId(),
      ]);
      final userToUse = results[0] as PickAFeatureUser;
      final deviceId = results[1] as String;

      final response = await _client.post(
        Uri.parse('$baseUrl/comments'),
        headers: _headers,
        body: jsonEncode({
          'featureRequestId': featureRequestId,
          'text': content,
          'deviceId': deviceId,
          'userId': userToUse.customId,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return Comment.fromJson(data);
      }
      throw _errorFromResponse(response, 'Failed to add comment');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e', 0);
    }
  }

  /// Update user information
  Future<void> updateUser(PickAFeatureUser user) async {
    // User creation is handled automatically when submitting feedback or voting
    // No separate endpoint needed
  }

  /// Get user information
  Future<PickAFeatureUser?> getUser() async {
    final userManager = PickAFeatureUserManager();
    return await userManager.loadUser();
  }

  /// Dispose the HTTP client
  void dispose() {
    _client.close();
  }
}

/// Thrown when the pick a feature API returns a non-2xx response or the
/// network call fails. Inspect [statusCode] for HTTP status (0 = network
/// error), [isAuthError]/[isRateLimit] for common cases, and [retryAfter]
/// to honor server-side rate limiting.
class ApiException implements Exception {
  final String message;
  final int statusCode;

  /// When [isRateLimit] is true, the number of seconds the server asked the
  /// client to wait before retrying (from the `Retry-After` header). Null
  /// otherwise.
  final int? retryAfter;

  ApiException(this.message, this.statusCode, {this.retryAfter});

  /// True for 401/403 — bad/missing API key or revoked access.
  bool get isAuthError => statusCode == 401 || statusCode == 403;

  /// True for 429 — too many requests. See [retryAfter].
  bool get isRateLimit => statusCode == 429;

  /// True when the request never reached the server (DNS, no internet, etc.).
  bool get isNetworkError => statusCode == 0;

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}
