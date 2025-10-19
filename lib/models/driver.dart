class Driver {
  String id;
  String name;
  String email;
  String contact;
  int totalVehicles;
  double rating;
  int totalTrips;
  bool isActive;
  bool isApproved;

  Driver({
    required this.id,
    required this.name,
    required this.email,
    required this.contact,
    required this.totalVehicles,
    required this.rating,
    required this.totalTrips,
    this.isActive = true,
    this.isApproved = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'contact': contact,
      'totalVehicles': totalVehicles,
      'rating': rating,
      'totalTrips': totalTrips,
      'isActive': isActive,
      'isApproved': isApproved,
    };
  }

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      contact: json['contact'],
      totalVehicles: json['totalVehicles'],
      rating: json['rating'],
      totalTrips: json['totalTrips'],
      isActive: json['isActive'] ?? true,
      isApproved: json['isApproved'] ?? true,
    );
  }
}