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

  // Tambahan untuk keperluan create
  final String userId;
  final String ticketId;

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
      userId: json['userId'].toString(),
      ticketId: json['ticketId'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'ticketId': ticketId,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'status': status,
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
        return Order.fromJson(jsonDecode(response.body));
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
      final response = await http.post(
        Uri.parse('$_apiUrl/orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(order.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Order.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create order');
      }
    } catch (err) {
      print('createOrder error: $err');
      return null;
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
