import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Define the Ticket model
class Ticket {
  final int ticketId;
  final String name;
  final String location;
  final int price; // Changed to int to match Prisma schema
  final int capacity; // Added from Prisma schema
  final String description; // Added from Prisma schema
  final String image;
  final double latitude; // Added from Prisma schema
  final double longitude; // Added from Prisma schema
  final String? createdAt;
  final String? updatedAt;

  Ticket({
    required this.ticketId,
    required this.name,
    required this.location,
    required this.price,
    required this.capacity,
    required this.description,
    required this.image,
    required this.latitude,
    required this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  // Convert JSON to Ticket object
  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      ticketId: json['ticketId'] as int,
      name: json['name'] as String,
      location: json['location'] as String,
      price: json['price'] as int, // Changed to int
      capacity: json['capacity'] as int,
      description: json['description'] as String,
      image: json['image'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  // Convert Ticket object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'price': price,
      'capacity': capacity,
      'description': description,
      'image': image,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class TicketService {
  static final String _apiUrl = dotenv.env['API_URL'] ?? '';

  /// Fetch all tickets from the backend
  static Future<List<Ticket>> fetchTickets() async {
    try {
      final response = await http.get(Uri.parse('$_apiUrl/tickets'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Ticket.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch tickets');
      }
    } catch (err) {
      print('fetchTickets error: $err');
      return [];
    }
  }

  /// Fetch single ticket by ID
  static Future<Ticket?> fetchTicketById(int id) async {
    try {
      final response = await http.get(Uri.parse('$_apiUrl/tickets/$id'));
      if (response.statusCode == 200) {
        return Ticket.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Ticket not found');
      }
    } catch (err) {
      print('fetchTicketById error (ID: $id): $err');
      return null;
    }
  }

  /// Create a new ticket
  static Future<Ticket?> createTicket(Ticket ticket) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/tickets'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(ticket.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Ticket.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create ticket');
      }
    } catch (err) {
      print('createTicket error: $err');
      return null;
    }
  }

  /// Delete a ticket
  static Future<bool> deleteTicket(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_apiUrl/tickets/$id'));
      return response.statusCode == 200;
    } catch (err) {
      print('deleteTicket error (ID: $id): $err');
      return false;
    }
  }
}
