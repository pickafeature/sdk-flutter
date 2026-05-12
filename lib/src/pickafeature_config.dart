import 'package:flutter/material.dart';

/// Configuration class for customizing PickAFeature SDK behavior
class PickAFeatureConfig {
  /// Base URL for the PickAFeature API
  final String apiBaseUrl;

  /// API key/project ID for the Firestore database
  final String? apiKey;

  /// Primary color for the UI theme
  final Color primaryColor;

  /// Secondary color for the UI theme
  final Color secondaryColor;

  /// Background color for dialogs and sheets
  final Color backgroundColor;

  /// Text color for primary text
  final Color textColor;

  /// Border radius for UI elements
  final double borderRadius;

  /// Custom title for the feedback form
  final String? customTitle;

  /// Custom subtitle for the feedback form
  final String? customSubtitle;

  /// Custom placeholder text for the feedback input
  final String? customPlaceholder;

  /// Custom submit button text
  final String? customSubmitText;

  /// Whether to show user email field
  final bool showEmailField;

  /// Demo mode — shows mock data instead of calling the API
  final bool demoMode;

  const PickAFeatureConfig({
    this.apiBaseUrl = 'https://pickafeature.com/api/v1/sdk',
    this.apiKey,
    this.primaryColor = const Color(0xFF6366F1),
    this.secondaryColor = const Color(0xFF8B5CF6),
    this.backgroundColor = Colors.white,
    this.textColor = const Color(0xFF1F2937),
    this.borderRadius = 12.0,
    this.customTitle,
    this.customSubtitle,
    this.customPlaceholder,
    this.customSubmitText,
    this.showEmailField = true,
    this.demoMode = false,
  });

  /// Create a copy of this config with updated values
  PickAFeatureConfig copyWith({
    String? apiBaseUrl,
    String? apiKey,
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    Color? textColor,
    double? borderRadius,
    String? customTitle,
    String? customSubtitle,
    String? customPlaceholder,
    String? customSubmitText,
    bool? showEmailField,
    bool? demoMode,
  }) {
    return PickAFeatureConfig(
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      apiKey: apiKey ?? this.apiKey,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      borderRadius: borderRadius ?? this.borderRadius,
      customTitle: customTitle ?? this.customTitle,
      customSubtitle: customSubtitle ?? this.customSubtitle,
      customPlaceholder: customPlaceholder ?? this.customPlaceholder,
      customSubmitText: customSubmitText ?? this.customSubmitText,
      showEmailField: showEmailField ?? this.showEmailField,
      demoMode: demoMode ?? this.demoMode,
    );
  }

  /// Convert config to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'apiBaseUrl': apiBaseUrl,
      'apiKey': apiKey,
      'primaryColor': primaryColor.toARGB32(),
      'secondaryColor': secondaryColor.toARGB32(),
      'backgroundColor': backgroundColor.toARGB32(),
      'textColor': textColor.toARGB32(),
      'borderRadius': borderRadius,
      'customTitle': customTitle,
      'customSubtitle': customSubtitle,
      'customPlaceholder': customPlaceholder,
      'customSubmitText': customSubmitText,
      'showEmailField': showEmailField,
    };
  }
}
