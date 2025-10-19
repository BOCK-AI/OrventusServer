// lib/screens/drivers_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'customers/users_provider.dart';
import '/models/user_model.dart';

class DriversScreen extends StatelessWidget {
  const DriversScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UsersProvider>();
    final List<UserModel> riders = provider.riders;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Driver List", style: Theme.of(context).textTheme.headlineMedium),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text("Add Driver"),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(color: Color.fromARGB(255, 11, 2, 2), borderRadius: BorderRadius.all(Radius.circular(10))),
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.error != null
                      ? Center(child: Text('Error: ${provider.error}'))
                      : DataTable(
                          columns: const [
                            DataColumn(label: Text("No")),
                            DataColumn(label: Text("Driver Name")),
                            DataColumn(label: Text("Contact")),
                            DataColumn(label: Text("Status")),
                            DataColumn(label: Text("Actions")),
                          ],
                          rows: List.generate(
                            riders.length,
                            (index) {
                              final rider = riders[index];
                              return DataRow(
                                cells: [
                                  DataCell(Text((index + 1).toString())),
                                  DataCell(Text(rider.name ?? 'N/A')),
                                  DataCell(Text(rider.phone ?? 'No contact info')),

                                  // --- THIS IS THE WIRED-UP SWITCH ---
                                  DataCell(
                                    Switch(
                                      value: rider.isActive,
                                      onChanged: (newValue) {
                                        provider.updateUserStatus(rider.id, newValue);
                                      },
                                    ),
                                  ),
                                  // --- END ---

                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(icon: const Icon(Icons.visibility, color: Colors.green), onPressed: () {}),
IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                // --- THIS BUTTON IS NOW WIRED UP ---
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit feature coming soon!')));
                                },
                              ),                                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {}),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}