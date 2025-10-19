import 'package:flutter/material.dart';
import '/models/dashboard_stats_model.dart';

class SummaryCard extends StatelessWidget {
  final TodaySummary summary;
  const SummaryCard({Key? key, required this.summary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InfoCard(
          title: "Total Revenue",
          value: "₹${summary.totalRevenue.toStringAsFixed(2)}",
          color: Colors.blue,
          icon: Icons.monetization_on,
        ),
        InfoCard(
          title: "Completed Rides",
          value: summary.completedRides.toString(),
          color: Colors.green,
          icon: Icons.check_circle,
        ),
        InfoCard(
          title: "Cancelled Rides",
          value: summary.cancelledRides.toString(),
          color: Colors.red,
          icon: Icons.cancel,
        ),
        InfoCard(
          title: "Total Rides",
          value: summary.totalRides.toString(),
          color: Colors.orange,
          icon: Icons.drive_eta,
        ),
      ],
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const InfoCard({
    Key? key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white),
                ),
                Icon(icon, color: Colors.white),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}