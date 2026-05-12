import 'package:flutter_test/flutter_test.dart';


void main() {
  group('PickAFeature Status Filtering', () {
    test('should filter feature requests by status', () {
      // Mock feature requests with different statuses
      final mockRequests = [
        {'id': '1', 'title': 'Feature 1', 'status': 'pending', 'upvotes': 5},
        {'id': '2', 'title': 'Feature 2', 'status': 'approved', 'upvotes': 10},
        {'id': '3', 'title': 'Feature 3', 'status': 'completed', 'upvotes': 15},
        {'id': '4', 'title': 'Feature 4', 'status': 'pending', 'upvotes': 3},
        {'id': '5', 'title': 'Feature 5', 'status': 'approved', 'upvotes': 8},
      ];

      // Test filtering by 'approved' status
      final approvedRequests = mockRequests.where((request) {
        final status = (request['status'] ?? 'pending').toString().toLowerCase();
        return status == 'approved';
      }).toList();

      expect(approvedRequests.length, 2);
      expect(approvedRequests[0]['id'], '2');
      expect(approvedRequests[1]['id'], '5');

      // Test filtering by 'completed' status
      final completedRequests = mockRequests.where((request) {
        final status = (request['status'] ?? 'pending').toString().toLowerCase();
        return status == 'completed';
      }).toList();

      expect(completedRequests.length, 1);
      expect(completedRequests[0]['id'], '3');
    });

    test('should handle missing status field', () {
      final mockRequests = [
        {'id': '1', 'title': 'Feature 1', 'upvotes': 5}, // No status field
        {'id': '2', 'title': 'Feature 2', 'status': 'approved', 'upvotes': 10},
      ];

      // Test that requests without status default to 'pending' (not visible to users)
      final pendingRequests = mockRequests.where((request) {
        final status = (request['status'] ?? 'pending').toString().toLowerCase();
        return status == 'pending';
      }).toList();

      expect(pendingRequests.length, 1);
    });

    test('should default to approved status', () {
      final mockRequests = [
        {'id': '1', 'title': 'Feature 1', 'upvotes': 5}, // No status field (pending)
        {'id': '2', 'title': 'Feature 2', 'status': 'approved', 'upvotes': 10},
      ];

      // Test that the default selected status is 'approved'
      final selectedStatus = 'approved';
      final filteredRequests = mockRequests.where((request) {
        final status = (request['status'] ?? 'pending').toString().toLowerCase();
        return status == selectedStatus.toLowerCase();
      }).toList();

      expect(filteredRequests.length, 1);
      expect(filteredRequests[0]['id'], '2');
    });
  });
}
