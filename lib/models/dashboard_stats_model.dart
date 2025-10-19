// lib/data/models/dashboard_stats_model.dart

class DashboardStatsModel {
  final TodaySummary todaySummary;
  final Map<String, int> totalOrderByServices;

  DashboardStatsModel({
    required this.todaySummary,
    required this.totalOrderByServices,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      todaySummary: TodaySummary.fromJson(json['todaySummary']),
      // Convert the dynamic map from JSON to a Map<String, int>
totalOrderByServices: Map<String, int>.from(json['totalOrderByServices']),    );
  }
}

class TodaySummary {
  final double totalRevenue;
  final int completedRides;
  final int cancelledRides;
  final int totalRides;

  TodaySummary({
    required this.totalRevenue,
    required this.completedRides,
    required this.cancelledRides,
    required this.totalRides,
  });

  factory TodaySummary.fromJson(Map<String, dynamic> json) {
    // Handle potential double/int type issues from JSON
    return TodaySummary(
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      completedRides: json['completedRides'] as int,
      cancelledRides: json['cancelledRides'] as int,
      totalRides: json['totalRides'] as int,
    );
  }
}