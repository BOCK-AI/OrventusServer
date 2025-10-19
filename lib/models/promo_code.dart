// lib/models/promo_code.dart
class PromoCode {
  String id;
  String code;
  int usageLimit;
  int totalUsed;
  String expiryDate;
  double discountValue;
  String discountType;
  bool isActive;

  PromoCode({
    required this.id,
    required this.code,
    required this.usageLimit,
    required this.totalUsed,
    required this.expiryDate,
    required this.discountValue,
    required this.discountType,
    this.isActive = true,
  });

  factory PromoCode.fromJson(Map<String, dynamic> json) {
    return PromoCode(
      id: json['id'].toString(),
      code: json['code'],
      usageLimit: json['usageLimit'],
      totalUsed: json['totalUsed'],
      expiryDate: json['expiryDate'],
      discountValue: (json['discountValue'] as num).toDouble(),
      discountType: json['discountType'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'usageLimit': usageLimit,
      'expiryDate': expiryDate,
      'discountValue': discountValue,
      'discountType': discountType,
      'isActive': isActive,
    };
  }
}