import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:client/config/api.dart';

class CouponService {
  static final String _baseUrl = API_URL;

  /// Get all active coupons
  static Future<List<Map<String, dynamic>>> getActiveCoupons() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/couponCodes/active/list'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch coupons');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error fetching active coupons: $e');
      return [];
    }
  }

  /// Check if a coupon is valid
  static Future<Map<String, dynamic>?> checkCoupon({
    required String couponCode,
    required double purchaseAmount,
    List<String>? productIds,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/couponCodes/check-coupon'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'couponCode': couponCode,
          'purchaseAmount': purchaseAmount,
          'productIds': productIds,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error checking coupon: $e');
      return {
        'success': false,
        'message': 'Failed to check coupon. Please try again.',
      };
    }
  }

  /// Apply coupon and calculate discount
  static Future<Map<String, dynamic>?> applyCoupon({
    required String couponCode,
    required double purchaseAmount,
    List<String>? productIds,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/couponCodes/apply-coupon'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'couponCode': couponCode,
          'purchaseAmount': purchaseAmount,
          'productIds': productIds,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error applying coupon: $e');
      return {
        'success': false,
        'message': 'Failed to apply coupon. Please try again.',
      };
    }
  }

  /// Calculate discount amount based on coupon
  static double calculateDiscount({
    required Map<String, dynamic> coupon,
    required double purchaseAmount,
  }) {
    final discountType = coupon['discountType'];
    final discountAmount = (coupon['discountAmount'] ?? 0).toDouble();

    if (discountType == 'fixed') {
      return discountAmount;
    } else if (discountType == 'percentage') {
      return (purchaseAmount * discountAmount) / 100;
    }

    return 0.0;
  }

  /// Format coupon for display
  static String formatCouponDiscount(Map<String, dynamic> coupon) {
    final discountType = coupon['discountType'];
    final discountAmount = coupon['discountAmount'];

    if (discountType == 'fixed') {
      return '₹$discountAmount OFF';
    } else if (discountType == 'percentage') {
      return '$discountAmount% OFF';
    }

    return 'DISCOUNT';
  }
}
