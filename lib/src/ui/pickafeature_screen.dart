import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../pickafeature_config.dart';
import '../services/api_service.dart';
import '../models/feature_request.dart';
import 'feature_request_screen.dart';
import 'feature_request_details_screen.dart';

class PickAFeatureScreen extends StatefulWidget {
  final PickAFeatureConfig config;
  const PickAFeatureScreen({super.key, this.config = const PickAFeatureConfig()});

  @override
  State<PickAFeatureScreen> createState() => _PickAFeatureScreenState();
}

class _PickAFeatureScreenState extends State<PickAFeatureScreen> {
  late final ApiService _apiService;
  late final String _upvotePrefsKey;
  Set<String> _upvotedIds = {};
  bool _loadingPrefs = true;
  List<FeatureRequest> _featureRequests = [];
  bool _loadingRequests = true;
  final Set<String> _upvotingIds = {}; // Track which items are being upvoted

  // State filtering
  String _selectedStatus = 'approved';
  final List<String> _statusOptions = ['approved', 'completed'];

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(
      baseUrl: widget.config.apiBaseUrl,
      apiKey: widget.config.apiKey,
    );
    _upvotePrefsKey = 'wishkit_upvotes';
    _loadUpvotedIds();
    _loadFeatureRequests();
  }

  Future<void> _loadUpvotedIds() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _upvotedIds = prefs.getStringList(_upvotePrefsKey)?.toSet() ?? {};
      _loadingPrefs = false;
    });
  }

  Future<void> _loadFeatureRequests() async {
    try {
      setState(() {
        _loadingRequests = true;
      });

      // Get all feature requests (we'll filter locally for better UX)
      // If you want server-side filtering, you can pass the status parameter:
      // final requests = await _apiService.getFeedbackRequests(status: _selectedStatus != 'all' ? _selectedStatus : null);
      final requests = await _apiService.getFeedbackRequests();

      if (mounted) {
        setState(() {
          _featureRequests = requests;
          _loadingRequests = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingRequests = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading feature requests: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Get filtered feature requests based on selected status
  List<FeatureRequest> get _filteredFeatureRequests {
    final filtered = _featureRequests.where((request) {
      final status = request.status.toLowerCase();
      return status == _selectedStatus.toLowerCase();
    }).toList();

    // Sort by upvotes in descending order (highest first)
    filtered.sort((a, b) => b.upvotes.compareTo(a.upvotes));

    return filtered;
  }

  // Handle status filter change
  void _onStatusFilterChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedStatus = newValue;
      });
    }
  }

  // Platform-specific status filter widget
  Widget _buildStatusFilter(
    bool isDark,
    Color textColor,
    Color cardColor,
    Color primaryColor,
  ) {
    if (Platform.isIOS) {
      return _buildIOSStatusFilter(isDark, textColor, cardColor, primaryColor);
    } else {
      return _buildAndroidStatusFilter(
        isDark,
        textColor,
        cardColor,
        primaryColor,
      );
    }
  }

  // iOS-specific segmented control
  Widget _buildIOSStatusFilter(
    bool isDark,
    Color textColor,
    Color cardColor,
    Color primaryColor,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF1C1C1E) : Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CupertinoSlidingSegmentedControl<String>(
          groupValue: _selectedStatus,
          children: {
            for (String status in _statusOptions)
              status: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  status
                      .split(' ')
                      .map((word) => word[0].toUpperCase() + word.substring(1))
                      .join(' '),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          },
          onValueChanged: _onStatusFilterChanged,
        ),
      ),
    );
  }

  // Android-specific chip-based filter
  Widget _buildAndroidStatusFilter(
    bool isDark,
    Color textColor,
    Color cardColor,
    Color primaryColor,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              _statusOptions.map((status) {
                final isSelected = _selectedStatus == status;
                return Container(
                  margin: EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(
                      status
                          .split(' ')
                          .map(
                            (word) => word[0].toUpperCase() + word.substring(1),
                          )
                          .join(' '),
                      style: TextStyle(
                        color: isSelected ? Colors.white : textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    backgroundColor: cardColor,
                    selectedColor: primaryColor,
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                      color:
                          isDark
                              ? Color(0xFF222222)
                              : Color.fromARGB(255, 240, 240, 240),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        _onStatusFilterChanged(status);
                      }
                    },
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Future<void> _handleUpvote(String docId) async {
    // Prevent multiple simultaneous upvote operations on the same item
    if (_upvotingIds.contains(docId)) {
      return;
    }

    // Find the index of the item being upvoted
    final itemIndex = _featureRequests.indexWhere((item) => item.id == docId);
    if (itemIndex == -1) return;

    // Store the original upvote count for potential rollback
    final originalUpvotes = _featureRequests[itemIndex].upvotes;
    final wasUpvoted = _upvotedIds.contains(docId);

    try {
      setState(() {
        _upvotingIds.add(docId);
      });

      if (wasUpvoted) {
        // Remove upvote
        await _apiService.downvoteFeedback(docId);
        final prefs = await SharedPreferences.getInstance();
        if (mounted) {
          setState(() {
            _upvotedIds.remove(docId);
            prefs.setStringList(_upvotePrefsKey, _upvotedIds.toList());
            // Update local upvote count by creating new instance
            _featureRequests[itemIndex] = _featureRequests[itemIndex].copyWith(
              upvotes: originalUpvotes - 1,
            );
          });
        }
      } else {
        // Add upvote
        await _apiService.upvoteFeedback(docId);
        final prefs = await SharedPreferences.getInstance();
        if (mounted) {
          setState(() {
            _upvotedIds.add(docId);
            prefs.setStringList(_upvotePrefsKey, _upvotedIds.toList());
            // Update local upvote count by creating new instance
            _featureRequests[itemIndex] = _featureRequests[itemIndex].copyWith(
              upvotes: originalUpvotes + 1,
            );
          });
        }
      }
    } catch (e) {
      // Rollback the local upvote count on error
      if (mounted) {
        setState(() {
          _featureRequests[itemIndex] = _featureRequests[itemIndex].copyWith(
            upvotes: originalUpvotes,
          );
          if (wasUpvoted) {
            _upvotedIds.add(docId);
          } else {
            _upvotedIds.remove(docId);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error ${wasUpvoted ? 'removing' : 'adding'} upvote: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _upvotingIds.remove(docId);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? Color(0xFF111111) : Color(0xFFFFFFFF);
    final textColor = isDark ? Colors.white : Colors.black;
    final primaryColor = config.primaryColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        title: Text(
          config.customTitle ?? 'Feature requests',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        shape: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1.0),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => FeatureRequestScreen(config: config),
              ),
            );
          },
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const CircleBorder(),
          child: Icon(Icons.add, size: 24),
        ),
      ),
      body:
          _loadingPrefs || _loadingRequests
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.6),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  // Status filter
                  _buildStatusFilter(
                    isDark,
                    textColor,
                    cardColor,
                    primaryColor,
                  ),
                  // Feature requests list
                  Expanded(
                    child:
                        _filteredFeatureRequests.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _featureRequests.isEmpty
                                        ? Icons.lightbulb_outline
                                        : Icons.check_circle_outline,
                                    size: 64,
                                    color: textColor.withValues(alpha: 0.2),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    _featureRequests.isEmpty
                                        ? 'No feature requests found'
                                        : 'No $_selectedStatus requests',
                                    style: TextStyle(
                                      color: textColor.withValues(alpha: 0.8),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    _featureRequests.isEmpty
                                        ? 'This project doesn\'t have any feature requests yet.\nCreate the first one to get started.'
                                        : 'There are no feature requests with "$_selectedStatus" status yet.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: textColor.withValues(alpha: 0.5),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : RefreshIndicator(
                              onRefresh: _loadFeatureRequests,
                              child: ListView.builder(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                itemCount: _filteredFeatureRequests.length,
                                itemBuilder: (context, i) {
                                  final data = _filteredFeatureRequests[i];

                                  return _featureRequestCard(
                                    data,
                                    isDark,
                                    primaryColor,
                                    textColor,
                                    cardColor,
                                    () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  FeatureRequestDetailsScreen(
                                                    config: config,
                                                    featureRequest: data,
                                                  ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                  ),
                ],
              ),
    );
  }

  Widget _featureRequestCard(
    FeatureRequest data,
    bool isDark,
    Color primaryColor,
    Color textColor,
    Color cardColor,
    Function() onTap,
  ) {
    final id = data.id;
    final title = data.title;
    final description = data.description;
    final upvotes = data.upvotes;
    final isUpvoted = _upvotedIds.contains(id);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isDark ? Color(0xFF222222) : Color.fromARGB(255, 240, 240, 240),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: [
                // Upvote section
                Column(
                  children: [
                    GestureDetector(
                      onTap:
                          _upvotingIds.contains(id)
                              ? null
                              : () => _handleUpvote(id),
                      child: Container(
                        padding: EdgeInsets.all(4),
                        child:
                            _upvotingIds.contains(id)
                                ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isUpvoted
                                          ? primaryColor
                                          : textColor.withValues(alpha: 0.6),
                                    ),
                                  ),
                                )
                                : Image.asset(
                                  'packages/pickafeature/assets/thumb_up.png',
                                  width: 18,
                                  height: 18,
                                  color:
                                      isUpvoted
                                          ? primaryColor
                                          : textColor.withValues(alpha: 0.6),
                                ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '$upvotes',
                      style: TextStyle(
                        color:
                            isUpvoted
                                ? primaryColor
                                : textColor.withValues(alpha: 0.6),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                SizedBox(width: 12),
                // Content section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (description.isNotEmpty) ...[
                        SizedBox(height: 6),
                        Text(
                          description,
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.7),
                            fontSize: 13,
                            height: 1.3,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                // Arrow indicator
                Icon(
                  Icons.chevron_right_outlined,
                  color: textColor.withValues(alpha: 0.5),
                  size: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
