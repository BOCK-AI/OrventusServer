class Customer {
  String id;
  String name;
  String email;
  String contact;
  double walletBalance;
  double rating;
  bool isActive;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.contact,
    required this.walletBalance,
    required this.rating,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'contact': contact,
      'walletBalance': walletBalance,
      'rating': rating,
      'isActive': isActive,
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      contact: json['contact'],
      walletBalance: json['walletBalance'],
      rating: json['rating'],
      isActive: json['isActive'] ?? true,
    );
  }
}