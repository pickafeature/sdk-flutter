import 'package:flutter/material.dart';
import 'package:pickafeature/src/models/feature_request.dart';
import 'pickafeature_config.dart';
import 'services/api_service.dart';

/// Main controller for the PickAFeature SDK
class PickAFeatureController {
  final PickAFeatureConfig config;
  
  late ApiService _apiService;
  bool _isInitialized = false;

  PickAFeatureController({
    required this.config,
  });

  /// Get the API service instance
  ApiService get apiService => _apiService;

  /// Initialize the PickAFeature controller
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize services
    _apiService = ApiService(
      baseUrl: config.apiBaseUrl,
      apiKey: config.apiKey,
    );

    _isInitialized = true;
  }

  /// Get all feedback requests
  Future<List<FeatureRequest>> getFeedbackRequests() async {
    if (config.demoMode) return _demoFeatureRequests;
    try {
      return await _apiService.getFeedbackRequests();
    } catch (e) {
      debugPrint('Error getting feedback requests: $e');
      rethrow;
    }
  }

  static final List<FeatureRequest> _demoFeatureRequests = [
    FeatureRequest(id: 'd1', title: 'Add dark mode support', description: 'Would love a dark theme option for the SDK widget so it matches our app theme.', content: '', upvotes: 47, status: 'approved', category: 'UI', createdAt: DateTime.now().subtract(const Duration(days: 2))),
    FeatureRequest(id: 'd2', title: 'Export feedback to CSV', description: 'Need to export all feature requests to a spreadsheet for team review.', content: '', upvotes: 34, status: 'in progress', category: 'Dashboard', createdAt: DateTime.now().subtract(const Duration(days: 3))),
    FeatureRequest(id: 'd3', title: 'Push notifications for new votes', description: 'Get notified when a feature request gets significant traction from users.', content: '', upvotes: 29, status: 'planned', category: 'Notifications', createdAt: DateTime.now().subtract(const Duration(days: 5))),
    FeatureRequest(id: 'd4', title: 'Custom categories for requests', description: 'Allow developers to define their own categories instead of using defaults.', content: '', upvotes: 23, status: 'approved', category: 'Customization', createdAt: DateTime.now().subtract(const Duration(days: 7))),
    FeatureRequest(id: 'd5', title: 'Multi-language support in SDK', description: 'Support for localized strings in the feedback widget for global apps.', content: '', upvotes: 19, status: 'under review', category: 'i18n', createdAt: DateTime.now().subtract(const Duration(days: 4))),
    FeatureRequest(id: 'd6', title: 'Slack integration for new requests', description: 'Post new feature requests to a Slack channel automatically.', content: '', upvotes: 41, status: 'approved', category: 'Integrations', createdAt: DateTime.now().subtract(const Duration(days: 6))),
    FeatureRequest(id: 'd7', title: 'User segmentation for feedback', description: 'Filter requests by user tier (free vs pro) to prioritize better.', content: '', upvotes: 11, status: 'pending', category: 'Analytics', createdAt: DateTime.now().subtract(const Duration(days: 8))),
  ];

  /// Upvote a feedback request
  Future<Map<String, dynamic>> upvoteFeedback(String feedbackId) async {
    try {
      return await _apiService.upvoteFeedback(feedbackId);
    } catch (e) {
      debugPrint('Error upvoting feedback: $e');
      rethrow;
    }
  }

  /// Test API connection
  Future<bool> testConnection() async {
    return await _apiService.testConnection();
  }

  /// Check if SDK is initialized
  bool get isInitialized => _isInitialized;

  /// Dispose resources
  void dispose() {
    // Note: ApiService doesn't have a dispose method yet
    // We'll add it if needed
  }
} 