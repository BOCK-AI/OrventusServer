// lib/screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dashboard_provider.dart';
import 'components/header.dart';
import 'components/summary_card.dart';
import 'components/total_order_services_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // We get the provider that was created in main.dart
    final provider = Provider.of<DashboardProvider>(context);

    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Header(title: "Dashboard"),
            const SizedBox(height: 16.0),
            
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (provider.error != null)
              Center(child: Text('Error: ${provider.error}'))
            else if (provider.stats != null)
              Column(
                children: [
                  SummaryCard(summary: provider.stats!.todaySummary),
                  const SizedBox(height: 16.0),
                  TotalOrderServicesCard(orderServices: provider.stats!.totalOrderByServices),
                ],
              )
            else
              const Center(child: Text('No data found.')),
          ],
        ),
      ),
    );
  }
}