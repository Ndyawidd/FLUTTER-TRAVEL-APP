class Ticket {
  final int ticketId;
  final String name;
  final String location;
  final int price;
  final int capacity;
  final String description;
  final String image;
  final double latitude;
  final double longitude;
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

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      ticketId: json['ticketId'],
      name: json['name'],
      location: json['location'],
      price: json['price'],
      capacity: json['capacity'],
      description: json['description'],
      image: json['image'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() => {
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
