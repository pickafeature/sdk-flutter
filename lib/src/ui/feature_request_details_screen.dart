import 'package:flutter/material.dart';
import '../pickafeature_config.dart';
import '../services/api_service.dart';
import '../models/comment.dart';
import '../models/feature_request.dart';

class FeatureRequestDetailsScreen extends StatefulWidget {
  final PickAFeatureConfig config;
  final FeatureRequest featureRequest;

  const FeatureRequestDetailsScreen({
    super.key,
    required this.config,
    required this.featureRequest,
  });

  @override
  State<FeatureRequestDetailsScreen> createState() =>
      _FeatureRequestDetailsScreenState();
}

class _FeatureRequestDetailsScreenState
    extends State<FeatureRequestDetailsScreen> {
  late final ApiService _apiService;
  final _commentController = TextEditingController();
  List<Comment> _comments = [];
  bool _loadingComments = true;
  bool _submittingComment = false;

  // Dynamic height management for the feature request card
  double? _cardHeight;
  double? _maxCardHeight; // Will be set to 30% of screen height
  final GlobalKey _cardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(
      baseUrl: widget.config.apiBaseUrl,
      apiKey: widget.config.apiKey,
    );

    // Add listener to rebuild widget when comment text changes
    _commentController.addListener(() {
      setState(() {
        // This will trigger a rebuild when the text changes
      });
    });

    _loadComments();

    // Calculate max card height as 30% of screen height
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mediaQuery = MediaQuery.of(context);
      _maxCardHeight = mediaQuery.size.height * 0.4;
      _calculateCardHeight();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    try {
      setState(() {
        _loadingComments = true;
      });

      final comments = await _apiService.getComments(widget.featureRequest.id);
      // Sort comments by createdAt descending (newest first)
      comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (mounted) {
        setState(() {
          _comments = comments;
          _loadingComments = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingComments = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading comments: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final commentText = _commentController.text.trim();

    setState(() {
      _submittingComment = true;
    });

    try {
      final newComment = await _apiService.addComment(
        featureRequestId: widget.featureRequest.id,
        content: commentText,
      );

      if (mounted) {
        setState(() {
          _comments.insert(0, newComment); // Add to the top of the list
        });
        _commentController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding comment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _submittingComment = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  void _calculateCardHeight() {
    if (_cardKey.currentContext != null && _maxCardHeight != null) {
      final RenderBox renderBox =
          _cardKey.currentContext!.findRenderObject() as RenderBox;
      final double actualHeight = renderBox.size.height;

      setState(() {
        if (actualHeight > _maxCardHeight!) {
          _cardHeight = _maxCardHeight;
        } else {
          _cardHeight = null; // Let it size naturally
        }
      });
    } else {
      // If context or maxCardHeight is not available yet, try again after a short delay
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _calculateCardHeight();
        }
      });
    }
  }

  Widget _buildCardContent(
    String title,
    int upvotes,
    String description,
    DateTime createdAt,
    Color textColor,
    Color primaryColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fixed header section (title and upvotes)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'packages/pickafeature/assets/thumb_up.png',
                  width: 18,
                  height: 18,
                  color: primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '$upvotes',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Description section
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: textColor.withValues(alpha: 0.7),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        // Fixed footer section (creation date)
        Text(
          'Created ${_formatDate(createdAt)}',
          style: TextStyle(
            fontSize: 11,
            color: textColor.withValues(alpha: 0.4),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildScrollableCardContent(
    String title,
    int upvotes,
    String description,
    DateTime createdAt,
    Color textColor,
    Color primaryColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fixed header section (title and upvotes)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'packages/pickafeature/assets/thumb_up.png',
                  width: 18,
                  height: 18,
                  color: primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '$upvotes',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Scrollable description section
        Expanded(
          child: SingleChildScrollView(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: textColor.withValues(alpha: 0.7),
                height: 1.4,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Fixed footer section (creation date)
        Text(
          'Created ${_formatDate(createdAt)}',
          style: TextStyle(
            fontSize: 12,
            color: textColor.withValues(alpha: 0.5),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDark ? Color(0xFF000000) : Color.fromARGB(255, 252, 254, 255);
    final cardColor = isDark ? Color(0xFF111111) : Color(0xFFFFFFFF);
    final textColor = isDark ? Colors.white : Colors.black;
    final primaryColor = config.primaryColor;

    final featureRequest = widget.featureRequest;
    final title = featureRequest.title;
    final description = featureRequest.description;
    final upvotes = featureRequest.upvotes;
    final createdAt = featureRequest.createdAt;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        title: Text(
          'Feature Details',
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
      body: SafeArea(
        child: Column(
          children: [
            // Feature Request Details
            Container(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Upvotes Card
                    Container(
                      key: _cardKey,
                      height: _cardHeight, // Apply dynamic height
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isDark
                                  ? Color(0xFF222222)
                                  : Color.fromARGB(255, 240, 240, 240),
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
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child:
                            _cardHeight != null
                                ? _buildScrollableCardContent(
                                  title,
                                  upvotes,
                                  description,
                                  createdAt,
                                  textColor,
                                  primaryColor,
                                )
                                : _buildCardContent(
                                  title,
                                  upvotes,
                                  description,
                                  createdAt,
                                  textColor,
                                  primaryColor,
                                ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Comments Section Header
                    Row(
                      children: [
                        Text(
                          'Comments',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _comments.isEmpty
                            ? Container()
                            : Text(
                              '${_comments.length}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textColor.withValues(alpha: 0.7),
                              ),
                            ),
                      ],
                    ),

                    // const SizedBox(height: 6),
                  ],
                ),
              ),
            ),

            // Comments List
            Expanded(
              child:
                  _loadingComments
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Loading comments...',
                              style: TextStyle(
                                fontSize: 14,
                                color: textColor.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                      : _comments.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 48,
                              color: textColor.withValues(alpha: 0.2),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No comments yet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textColor.withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Be the first to share your thoughts!',
                              style: TextStyle(
                                fontSize: 13,
                                color: textColor.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    isDark
                                        ? Color(0xFF222222)
                                        : Color.fromARGB(255, 240, 240, 240),
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
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'User',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatDate(comment.createdAt),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: textColor.withValues(alpha: 0.5),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    comment.content,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: textColor.withValues(alpha: 0.8),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),

            // Add Comment Section
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Comment Field
                  Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: textColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _commentController,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor,
                        height: 1.4,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Share your thoughts about this feature request...',
                        hintStyle: TextStyle(
                          color: textColor.withValues(alpha: 0.4),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed:
                          _submittingComment ||
                                  _commentController.text.trim().isEmpty
                              ? null
                              : _submitComment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child:
                          _submittingComment
                              ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Text(
                                'Add Comment',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
