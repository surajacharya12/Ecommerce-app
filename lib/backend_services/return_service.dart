import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:client/config/api.dart';

// Return Model
class ReturnRequest {
  final String id;
  final String returnNumber;
  final String orderID;
  final String orderNumber;
  final String userID;
  final DateTime returnDate;
  final String returnStatus;
  final String returnType;
  final String returnReason;
  final String returnDescription;
  final List<ReturnItem> items;
  final double returnAmount;
  final String refundMethod;
  final Address? pickupAddress;
  final List<ReturnImage> images;
  final String? adminNotes;
  final DateTime? processedAt;
  final DateTime? refundedAt;

  ReturnRequest({
    required this.id,
    required this.returnNumber,
    required this.orderID,
    required this.orderNumber,
    required this.userID,
    required this.returnDate,
    required this.returnStatus,
    required this.returnType,
    required this.returnReason,
    required this.returnDescription,
    required this.items,
    required this.returnAmount,
    required this.refundMethod,
    this.pickupAddress,
    required this.images,
    this.adminNotes,
    this.processedAt,
    this.refundedAt,
  });

  factory ReturnRequest.fromJson(Map<String, dynamic> json) {
    return ReturnRequest(
      id: json['_id'] ?? '',
      returnNumber: json['returnNumber'] ?? '',
      orderID: json['orderID'] is String
          ? json['orderID']
          : json['orderID']['_id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      userID: json['userID'] ?? '',
      returnDate: DateTime.parse(
        json['returnDate'] ?? DateTime.now().toIso8601String(),
      ),
      returnStatus: json['returnStatus'] ?? 'requested',
      returnType: json['returnType'] ?? 'refund',
      returnReason: json['returnReason'] ?? '',
      returnDescription: json['returnDescription'] ?? '',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => ReturnItem.fromJson(item))
              .toList() ??
          [],
      returnAmount: (json['returnAmount'] ?? 0).toDouble(),
      refundMethod: json['refundMethod'] ?? 'original_payment',
      pickupAddress: json['pickupAddress'] != null
          ? Address.fromJson(json['pickupAddress'])
          : null,
      images:
          (json['images'] as List<dynamic>?)
              ?.map((img) => ReturnImage.fromJson(img))
              .toList() ??
          [],
      adminNotes: json['adminNotes'],
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'])
          : null,
      refundedAt: json['refundedAt'] != null
          ? DateTime.parse(json['refundedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderID': orderID,
      'orderNumber': orderNumber,
      'userID': userID,
      'returnType': returnType,
      'returnReason': returnReason,
      'returnDescription': returnDescription,
      'items': items.map((item) => item.toJson()).toList(),
      'refundMethod': refundMethod,
      if (pickupAddress != null) 'pickupAddress': pickupAddress!.toJson(),
      'images': images.map((img) => img.toJson()).toList(),
    };
  }
}

class ReturnItem {
  final String productID;
  final String productName;
  final int quantity;
  final double price;
  final String? variant;
  final int returnQuantity;
  final String condition;

  ReturnItem({
    required this.productID,
    required this.productName,
    required this.quantity,
    required this.price,
    this.variant,
    required this.returnQuantity,
    required this.condition,
  });

  factory ReturnItem.fromJson(Map<String, dynamic> json) {
    return ReturnItem(
      productID: json['productID'] is String
          ? json['productID']
          : json['productID']['_id'] ?? '',
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      variant: json['variant'],
      returnQuantity: json['returnQuantity'] ?? 0,
      condition: json['condition'] ?? 'used',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productID': productID,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      if (variant != null) 'variant': variant,
      'returnQuantity': returnQuantity,
      'condition': condition,
    };
  }
}

class ReturnImage {
  final String url;
  final String? description;

  ReturnImage({required this.url, this.description});

  factory ReturnImage.fromJson(Map<String, dynamic> json) {
    return ReturnImage(
      url: json['url'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'url': url, if (description != null) 'description': description};
  }
}

class Address {
  final String? phone;
  final String? street;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;

  Address({
    this.phone,
    this.street,
    this.city,
    this.state,
    this.postalCode,
    this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      phone: json['phone'],
      street: json['street'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postalCode'],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (phone != null) 'phone': phone,
      if (street != null) 'street': street,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (postalCode != null) 'postalCode': postalCode,
      if (country != null) 'country': country,
    };
  }
}

class ReturnService {
  final String baseUrl = API_URL;

  // Create a new return request
  Future<ReturnRequest> createReturn(ReturnRequest returnRequest) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/returns/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(returnRequest.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return ReturnRequest.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to create return request');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to create return request',
        );
      }
    } catch (e) {
      throw Exception('Error creating return request: $e');
    }
  }

  // Get all returns for a user
  Future<List<ReturnRequest>> getUserReturns(
    String userID, {
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      String url = '$baseUrl/returns/user/$userID?page=$page&limit=$limit';
      if (status != null) {
        url += '&status=$status';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((item) => ReturnRequest.fromJson(item))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch returns');
        }
      } else {
        throw Exception('Failed to fetch returns: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching returns: $e');
    }
  }

  // Get return details by ID
  Future<ReturnRequest> getReturnDetails(String returnID) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/returns/$returnID'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return ReturnRequest.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch return details');
        }
      } else {
        throw Exception(
          'Failed to fetch return details: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching return details: $e');
    }
  }

  // Cancel return request
  Future<ReturnRequest> cancelReturn(String returnID, String userID) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/returns/$returnID/cancel'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userID': userID}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return ReturnRequest.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to cancel return');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to cancel return');
      }
    } catch (e) {
      throw Exception('Error cancelling return: $e');
    }
  }

  // Get return reasons
  static List<Map<String, String>> getReturnReasons() {
    return [
      {'value': 'defective_product', 'label': 'Defective Product'},
      {'value': 'wrong_item_received', 'label': 'Wrong Item Received'},
      {'value': 'size_issue', 'label': 'Size Issue'},
      {'value': 'quality_issue', 'label': 'Quality Issue'},
      {'value': 'not_as_described', 'label': 'Not as Described'},
      {'value': 'damaged_in_shipping', 'label': 'Damaged in Shipping'},
      {'value': 'changed_mind', 'label': 'Changed Mind'},
      {'value': 'other', 'label': 'Other'},
    ];
  }

  // Get delivered orders for return creation
  Future<List<Map<String, dynamic>>> getDeliveredOrders(String userID) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/returns/user/$userID/delivered-orders'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data'] ?? []);
        } else {
          throw Exception(
            data['message'] ?? 'Failed to fetch delivered orders',
          );
        }
      } else {
        throw Exception(
          'Failed to fetch delivered orders: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching delivered orders: $e');
    }
  }

  // Get return status display text
  static String getStatusDisplayText(String status) {
    switch (status) {
      case 'requested':
        return 'Requested';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'picked_up':
        return 'Picked Up';
      case 'processing':
        return 'Processing';
      case 'refunded':
        return 'Refunded';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.toUpperCase();
    }
  }
}
