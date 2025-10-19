// lib/screens/customers_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'customers/users_provider.dart';
import '/models/user_model.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // We use watch here so the UI rebuilds when the user list changes
    final provider = context.watch<UsersProvider>();
    final List<UserModel> customers = provider.customers;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Customer List", style: Theme.of(context).textTheme.headlineMedium),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text("Add Customer"),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 10, 1, 1) ,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.error != null
                      ? Center(child: Text('Error: ${provider.error}'))
                      : DataTable(
                          columnSpacing: 38.0,
                          columns: const [
                            DataColumn(label: Text("No")),
                            DataColumn(label: Text("Customer Name")),
                            DataColumn(label: Text("Contact No.")),
                            DataColumn(label: Text("Status")),
                            DataColumn(label: Text("Actions")),
                          ],
                          rows: List.generate(
                            customers.length,
                            (index) {
                              final customer = customers[index];
                              return DataRow(
                                cells: [
                                  DataCell(Text((index + 1).toString())),
                                  DataCell(Text(customer.name ?? 'N/A')),
                                  DataCell(Text(customer.phone ?? 'No contact info')),
                                  
                                  // --- THIS IS THE WIRED-UP SWITCH ---
                                  DataCell(
                                    Switch(
                                      value: customer.isActive, // Use the real value
                                      onChanged: (newValue) {
                                        // Call the provider to update the status
                                        provider.updateUserStatus(customer.id, newValue);
                                      },
                                    ),
                                  ),
                                  // --- END ---

                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                // --- THIS BUTTON IS NOW WIRED UP ---
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit feature coming soon!')));
                                },
                              ),
                              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {}),
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