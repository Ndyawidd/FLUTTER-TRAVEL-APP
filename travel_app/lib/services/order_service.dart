import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Define the Order model
class Order {
  final String orderId;
  final String userName;
  final String ticketTitle;
  final String image;
  final int quantity;
  final double totalPrice;
  final String status;
  final String date;

  // Changed to int types to match backend validation
  final int userId;
  final int ticketId;

  Order({
    required this.orderId,
    required this.userName,
    required this.ticketTitle,
    required this.image,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.userId,
    required this.ticketId,
    required this.date,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'].toString(),
      userName: json['user']?['name'] ?? '',
      ticketTitle: json['ticket']?['name'] ?? '',
      image: json['ticket']?['image'] ?? '',
      quantity: json['quantity'],
      totalPrice: double.parse(json['totalPrice'].toString()),
      status: json['status'],
      userId: int.parse(json['userId'].toString()),
      ticketId: int.parse(json['ticketId'].toString()),
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId, // Now sends as int
      'ticketId': ticketId, // Now sends as int
      'quantity': quantity,
      // 'totalPrice': totalPrice,
      // 'status': status,
      'date': date, // Added date field to match backend validation
    };
  }
}

class OrderService {
  static final String _apiUrl = dotenv.env['API_URL'] ?? '';

  /// Fetch all orders
  static Future<List<Order>> fetchOrders() async {
    try {
      final response = await http.get(Uri.parse('$_apiUrl/orders'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch orders');
      }
    } catch (err) {
      print('fetchOrders error: $err');
      return [];
    }
  }

  /// Fetch order by ID
  static Future<Order?> fetchOrderById(int id) async {
    try {
      final response = await http.get(Uri.parse('$_apiUrl/orders/$id'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return Order.fromJson(decoded['data']);
      } else {
        throw Exception('Order not found');
      }
    } catch (err) {
      print('fetchOrderById error (ID: $id): $err');
      return null;
    }
  }

  /// Create a new order
  static Future<Order?> createOrder(Order order) async {
    try {
      final jsonData = order.toJson();
      print("JSON being sent: ${jsonEncode(jsonData)}");

      final response = await http.post(
        Uri.parse('$_apiUrl/orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(jsonData),
      );

      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        return Order.fromJson(decoded['data']); // <- AMBIL DATA SAJA
      } else {
        throw Exception('Failed to create order');
      }
    } catch (err) {
      print('createOrder error: $err');
      return null;
    }
  }

  /// Update order status
  static Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await http.put(
        Uri.parse('$_apiUrl/orders/$orderId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      );

      print("Update order status - STATUS CODE: ${response.statusCode}");
      print("Update order status - RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to update order status');
      }
    } catch (err) {
      print('updateOrderStatus error (ID: $orderId, Status: $status): $err');
      return false;
    }
  }

  /// Delete an order
  static Future<bool> deleteOrder(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_apiUrl/orders/$id'));
      return response.statusCode == 200;
    } catch (err) {
      print('deleteOrder error (ID: $id): $err');
      return false;
    }
  }
}
