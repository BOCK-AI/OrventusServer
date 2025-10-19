import 'ride_model.dart'; // We will reuse our existing RideModel

class EarningsReportModel {
  final EarningsSummary summary;
  final List<RideModel> transactions;

  EarningsReportModel({
    required this.summary,
    required this.transactions,
  });

  factory EarningsReportModel.fromJson(Map<String, dynamic> json) {
    // Parse the list of transactions from the JSON
    var transactionList = json['transactions'] as List;
    List<RideModel> transactions = transactionList.map((i) => RideModel.fromJson(i)).toList();

    return EarningsReportModel(
      summary: EarningsSummary.fromJson(json['summary']),
      transactions: transactions,
    );
  }
}

class EarningsSummary {
  final double totalFare;
  final double siteCommission;
  final double driverEarnings;
  final double totalDiscount;

  EarningsSummary({
    required this.totalFare,
    required this.siteCommission,
    required this.driverEarnings,
    required this.totalDiscount,
  });

  factory EarningsSummary.fromJson(Map<String, dynamic> json) {
    return EarningsSummary(
      totalFare: (json['totalFare'] as num).toDouble(),
      siteCommission: (json['siteCommission'] as num).toDouble(),
      driverEarnings: (json['driverEarnings'] as num).toDouble(),
      totalDiscount: (json['totalDiscount'] as num).toDouble(),
    );
  }
}