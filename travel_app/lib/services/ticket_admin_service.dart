import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:travel_app/models/ticket.dart'; // <-- ⬅️ Impor model

class TicketAdminService {
  static final String _apiUrl = dotenv.env['API_URL'] ?? '';

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

  // etc...
}
