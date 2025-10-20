import 'package:bank_sha/services/api_client.dart';
import 'package:bank_sha/models/rating_model.dart';

/// Complete Rating Service - User Feedback & Reviews
///
/// Features:
/// - Create rating (POST /api/ratings)
/// - Update rating (PUT /api/ratings/{id})
/// - Delete rating (DELETE /api/ratings/{id})
/// - Get ratings list (GET /api/ratings)
/// - Get rating by ID (GET /api/ratings/{id})
/// - Calculate mitra average rating
/// - Get rating breakdown (distribution)
///
/// Use Cases:
/// - User rates mitra after completed order
/// - View mitra's ratings and reviews
/// - Calculate average rating for display
/// - Manage user's own ratings
///
/// IMPORTANT NOTES:
/// - mitra_id is AUTO-POPULATED by backend from order.mitra_id
/// - Do NOT send mitra_id in request body
/// - Backend validates: order must be completed, user must own order, prevent duplicates
class RatingServiceComplete {
  final ApiClient _apiClient = ApiClient();

  // ========================================
  // CRUD Operations
  // ========================================

  /// Create a new rating for a completed order
  ///
  /// POST /api/ratings
  ///
  /// Parameters:
  /// - [orderId]: ID of the completed order to rate
  /// - [userId]: ID of the user creating the rating
  /// - [score]: Rating score 1-5 stars (required)
  /// - [comment]: Optional review comment
  ///
  /// Backend Auto-Population:
  /// - mitra_id is automatically filled from order.mitra_id
  ///
  /// Backend Validations:
  /// - Order must exist and be completed
  /// - Order must have a mitra assigned
  /// - User must be the owner of the order
  /// - User cannot rate the same order twice
  ///
  /// Returns: Created Rating object (includes mitra_id)
  ///
  /// Example:
  /// ```dart
  /// final rating = await ratingService.createRating(
  ///   orderId: 123,
  ///   userId: 456,
  ///   score: 5,
  ///   comment: 'Excellent service! Very professional.',
  /// );
  /// print('Rated mitra: ${rating.mitraId}'); // Auto-populated
  /// ```
  Future<RatingModel> createRating({
    required int orderId,
    required int userId,
    required int score,
    String? comment,
  }) async {
    try {
      // Validate score
      if (score < 1 || score > 5) {
        throw ArgumentError('Score must be between 1 and 5');
      }

      final body = {
        'order_id': orderId,
        'user_id': userId,
        'score': score,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      };

      print('⭐ Creating rating for Order #$orderId');
      print('   Score: $score/5');
      if (comment != null) {
        print(
          '   Comment: ${comment.substring(0, comment.length > 50 ? 50 : comment.length)}...',
        );
      }

      final response = await _apiClient.postJson('/api/ratings', body);

      final rating = RatingModel.fromJson(response['data']);
      print('✅ Rating created successfully');
      print('   Mitra ID (auto-populated): ${rating.mitraId}');

      return rating;
    } catch (e) {
      print('❌ Error creating rating: $e');

      // Parse backend validation errors
      if (e.toString().contains('already rated')) {
        throw Exception('You have already rated this order');
      } else if (e.toString().contains('must be completed')) {
        throw Exception('Order must be completed before rating');
      } else if (e.toString().contains('no assigned mitra')) {
        throw Exception('Order has no mitra to rate');
      } else if (e.toString().contains('not allowed')) {
        throw Exception('You are not allowed to rate this order');
      }

      rethrow;
    }
  }

  /// Update existing rating
  ///
  /// PUT /api/ratings/{id}
  ///
  /// Parameters:
  /// - [id]: Rating ID to update
  /// - [score]: New rating score 1-5 (optional)
  /// - [comment]: New comment (optional)
  ///
  /// Returns: Updated Rating object
  ///
  /// Example:
  /// ```dart
  /// final updated = await ratingService.updateRating(
  ///   789,
  ///   score: 4,
  ///   comment: 'Updated: Good service overall.',
  /// );
  /// ```
  Future<RatingModel> updateRating(
    int id, {
    int? score,
    String? comment,
  }) async {
    try {
      // Validate score if provided
      if (score != null && (score < 1 || score > 5)) {
        throw ArgumentError('Score must be between 1 and 5');
      }

      final body = <String, dynamic>{};
      if (score != null) body['score'] = score;
      if (comment != null) body['comment'] = comment;

      if (body.isEmpty) {
        throw ArgumentError('At least one field must be provided for update');
      }

      print('⭐ Updating rating #$id');

      final response = await _apiClient.putJson('/api/ratings/$id', body);

      print('✅ Rating updated successfully');
      return RatingModel.fromJson(response['data']);
    } catch (e) {
      print('❌ Error updating rating: $e');
      rethrow;
    }
  }

  /// Delete rating
  ///
  /// DELETE /api/ratings/{id}
  ///
  /// Parameters:
  /// - [id]: Rating ID to delete
  ///
  /// Example:
  /// ```dart
  /// await ratingService.deleteRating(789);
  /// ```
  Future<void> deleteRating(int id) async {
    try {
      print('🗑️ Deleting rating #$id');

      await _apiClient.delete('/api/ratings/$id');

      print('✅ Rating deleted successfully');
    } catch (e) {
      print('❌ Error deleting rating: $e');
      rethrow;
    }
  }

  /// Get list of ratings
  ///
  /// GET /api/ratings
  ///
  /// Parameters:
  /// - [mitraId]: Filter by mitra ID (get all ratings for a mitra)
  /// - [orderId]: Filter by order ID (get rating for specific order)
  /// - [userId]: Filter by user ID (get all ratings by a user)
  /// - [page]: Page number for pagination (default: 1)
  /// - [perPage]: Items per page (default: 20, max: 100)
  ///
  /// Returns: List of Rating objects with relationships loaded
  ///
  /// Example:
  /// ```dart
  /// // Get all ratings for a mitra
  /// final mitraRatings = await ratingService.getRatings(mitraId: 456);
  ///
  /// // Get rating for specific order
  /// final orderRating = await ratingService.getRatings(orderId: 123);
  /// ```
  Future<List<RatingModel>> getRatings({
    int? mitraId,
    int? orderId,
    int? userId,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final query = <String, dynamic>{'page': page, 'per_page': perPage};

      if (mitraId != null) query['mitra_id'] = mitraId;
      if (orderId != null) query['order_id'] = orderId;
      if (userId != null) query['user_id'] = userId;

      print('⭐ Getting ratings');
      if (mitraId != null) print('   Filter: Mitra #$mitraId');
      if (orderId != null) print('   Filter: Order #$orderId');
      if (userId != null) print('   Filter: User #$userId');

      final response = await _apiClient.getJson('/api/ratings', query: query);

      final List<dynamic> data = response['data'] ?? [];
      final ratings = data.map((json) => RatingModel.fromJson(json)).toList();

      print('✅ Found ${ratings.length} ratings');
      return ratings;
    } catch (e) {
      print('❌ Error getting ratings: $e');
      rethrow;
    }
  }

  /// Get rating by ID
  ///
  /// GET /api/ratings/{id}
  ///
  /// Parameters:
  /// - [id]: Rating ID
  ///
  /// Returns: Rating object with relationships
  ///
  /// Example:
  /// ```dart
  /// final rating = await ratingService.getRatingById(789);
  /// print('Score: ${rating.score}/5');
  /// print('Comment: ${rating.comment}');
  /// print('Mitra: ${rating.mitra?.name}');
  /// ```
  Future<RatingModel> getRatingById(int id) async {
    try {
      print('⭐ Getting rating #$id');

      final response = await _apiClient.get('/api/ratings/$id');

      print('✅ Rating found');
      return RatingModel.fromJson(response['data']);
    } catch (e) {
      print('❌ Error getting rating: $e');
      rethrow;
    }
  }

  // ========================================
  // Helper Methods
  // ========================================

  /// Calculate average rating for a mitra
  ///
  /// Parameters:
  /// - [mitraId]: Mitra ID to calculate average for
  ///
  /// Returns: Average rating (0.0 to 5.0) or null if no ratings
  ///
  /// Example:
  /// ```dart
  /// final avgRating = await ratingService.getMitraAverageRating(456);
  /// print('Average: ${avgRating?.toStringAsFixed(1)}/5.0');
  /// ```
  Future<double?> getMitraAverageRating(int mitraId) async {
    try {
      print('⭐ Calculating average rating for Mitra #$mitraId');

      final ratings = await getRatings(mitraId: mitraId, perPage: 100);

      if (ratings.isEmpty) {
        print('   No ratings found');
        return null;
      }

      final totalScore = ratings.fold<int>(
        0,
        (sum, rating) => sum + (rating.score ?? 0),
      );

      final average = totalScore / ratings.length;

      print(
        '✅ Average: ${average.toStringAsFixed(2)}/5.0 (${ratings.length} ratings)',
      );
      return average;
    } catch (e) {
      print('❌ Error calculating average: $e');
      rethrow;
    }
  }

  /// Get rating breakdown/distribution for a mitra
  ///
  /// Parameters:
  /// - [mitraId]: Mitra ID to get breakdown for
  ///
  /// Returns: Map of score -> count
  ///
  /// Example:
  /// ```dart
  /// final breakdown = await ratingService.getRatingBreakdown(456);
  /// print('5 stars: ${breakdown[5] ?? 0}');
  /// print('4 stars: ${breakdown[4] ?? 0}');
  /// print('3 stars: ${breakdown[3] ?? 0}');
  /// print('2 stars: ${breakdown[2] ?? 0}');
  /// print('1 star: ${breakdown[1] ?? 0}');
  /// ```
  Future<Map<int, int>> getRatingBreakdown(int mitraId) async {
    try {
      print('⭐ Getting rating breakdown for Mitra #$mitraId');

      final ratings = await getRatings(mitraId: mitraId, perPage: 100);

      final breakdown = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

      for (final rating in ratings) {
        final score = rating.score ?? 0;
        if (score >= 1 && score <= 5) {
          breakdown[score] = (breakdown[score] ?? 0) + 1;
        }
      }

      print('✅ Breakdown:');
      print('   5⭐: ${breakdown[5]}');
      print('   4⭐: ${breakdown[4]}');
      print('   3⭐: ${breakdown[3]}');
      print('   2⭐: ${breakdown[2]}');
      print('   1⭐: ${breakdown[1]}');

      return breakdown;
    } catch (e) {
      print('❌ Error getting breakdown: $e');
      rethrow;
    }
  }

  /// Check if user has already rated an order
  ///
  /// Parameters:
  /// - [orderId]: Order ID to check
  /// - [userId]: User ID to check
  ///
  /// Returns: true if already rated, false otherwise
  ///
  /// Example:
  /// ```dart
  /// final hasRated = await ratingService.hasUserRatedOrder(123, 456);
  /// if (!hasRated) {
  ///   // Show rating dialog
  /// }
  /// ```
  Future<bool> hasUserRatedOrder(int orderId, int userId) async {
    try {
      final ratings = await getRatings(orderId: orderId, userId: userId);
      return ratings.isNotEmpty;
    } catch (e) {
      print('❌ Error checking if rated: $e');
      return false;
    }
  }

  /// Get user's rating for a specific order
  ///
  /// Parameters:
  /// - [orderId]: Order ID
  /// - [userId]: User ID
  ///
  /// Returns: Rating object or null if not rated
  ///
  /// Example:
  /// ```dart
  /// final myRating = await ratingService.getUserRatingForOrder(123, 456);
  /// if (myRating != null) {
  ///   print('You rated: ${myRating.score}/5');
  /// }
  /// ```
  Future<RatingModel?> getUserRatingForOrder(int orderId, int userId) async {
    try {
      final ratings = await getRatings(orderId: orderId, userId: userId);
      return ratings.isNotEmpty ? ratings.first : null;
    } catch (e) {
      print('❌ Error getting user rating: $e');
      return null;
    }
  }

  /// Get statistics summary for a mitra
  ///
  /// Parameters:
  /// - [mitraId]: Mitra ID
  ///
  /// Returns: Map with statistics
  ///
  /// Example:
  /// ```dart
  /// final stats = await ratingService.getMitraRatingStats(456);
  /// print('Total: ${stats['total']}');
  /// print('Average: ${stats['average']}');
  /// print('5-star percentage: ${stats['percentage_5']}%');
  /// ```
  Future<Map<String, dynamic>> getMitraRatingStats(int mitraId) async {
    try {
      print('⭐ Getting rating statistics for Mitra #$mitraId');

      final ratings = await getRatings(mitraId: mitraId, perPage: 100);
      final breakdown = await getRatingBreakdown(mitraId);
      final average = await getMitraAverageRating(mitraId);

      final total = ratings.length;

      final stats = {
        'total': total,
        'average': average,
        'breakdown': breakdown,
        'percentage_5': total > 0
            ? ((breakdown[5] ?? 0) / total * 100).toStringAsFixed(1)
            : '0',
        'percentage_4': total > 0
            ? ((breakdown[4] ?? 0) / total * 100).toStringAsFixed(1)
            : '0',
        'percentage_3': total > 0
            ? ((breakdown[3] ?? 0) / total * 100).toStringAsFixed(1)
            : '0',
        'percentage_2': total > 0
            ? ((breakdown[2] ?? 0) / total * 100).toStringAsFixed(1)
            : '0',
        'percentage_1': total > 0
            ? ((breakdown[1] ?? 0) / total * 100).toStringAsFixed(1)
            : '0',
      };

      print('✅ Statistics calculated');
      return stats;
    } catch (e) {
      print('❌ Error getting stats: $e');
      rethrow;
    }
  }

  /// Validate if order is eligible for rating
  ///
  /// This is a client-side validation. Backend will do final validation.
  ///
  /// Parameters:
  /// - [orderId]: Order ID to validate
  /// - [userId]: User ID
  ///
  /// Returns: Error message if not eligible, null if eligible
  ///
  /// Example:
  /// ```dart
  /// final error = await ratingService.validateRatingEligibility(123, 456);
  /// if (error != null) {
  ///   showDialog(context, error);
  /// } else {
  ///   // Show rating form
  /// }
  /// ```
  Future<String?> validateRatingEligibility(int orderId, int userId) async {
    try {
      // Check if already rated
      final hasRated = await hasUserRatedOrder(orderId, userId);
      if (hasRated) {
        return 'You have already rated this order';
      }

      // Backend will validate:
      // - Order exists and is completed
      // - Order has mitra assigned
      // - User owns the order

      return null; // Eligible
    } catch (e) {
      return 'Error validating eligibility: $e';
    }
  }
}
