import 'package:flutter/material.dart';

/// Small "TEAM" pill shown next to requests and comments the project owner
/// posted from the dashboard, so users can tell them from other users' posts.
class TeamBadge extends StatelessWidget {
  final Color color;

  const TeamBadge({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'TEAM',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          height: 1.2,
        ),
      ),
    );
  }
}
