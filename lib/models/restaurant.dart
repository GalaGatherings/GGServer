// lib/models/restaurant.dart
class Restaurant {
  final String id;
  final String storeName;
  final int orderCounter;
  final String profilePhoto;
  final String phone;
  final String location;
  final String latitude;
  final String longitude;
  final String distance_km;
  final String category;
  final String sub_category;
  final String description;
  

  Restaurant({
    required this.id,
    required this.storeName,
    required this.orderCounter,
    required this.profilePhoto,
    required this.phone,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.distance_km,
    required this.category,
    required this.sub_category,
    required this.description,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['_id'] ?? '',
      storeName: json['store_name'] ?? '',
      orderCounter: json['order_counter'] ?? 0,
      profilePhoto: json['profile_photo'] ?? '',
      phone: json['phone'] ?? '',
      location: json['current_location']?['area'] ?? '',
      category: json['category']?? '',
      sub_category: json['sub_category']?? '',
      description: json['description']?? '',
      latitude: json['current_location']?['latitude'].toString() ?? '',
      longitude: json['current_location']?['longitude'].toString() ?? '',
      distance_km: json['distance_km']?.toString() ?? '0',
    );
  }
}