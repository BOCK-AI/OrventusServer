// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SettingsProvider(),
      child: Consumer<SettingsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
  return Center(child: Text("Error: ${provider.error}"));
}
          // Use controllers to manage the form fields
          final websiteNameController = TextEditingController(text: provider.settings['WEBSITE_NAME'] ?? '');
          final addressController = TextEditingController(text: provider.settings['ADDRESS'] ?? '');
          final emailController = TextEditingController(text: provider.settings['EMAIL'] ?? '');
          final contactController = TextEditingController(text: provider.settings['CONTACT_NO'] ?? '');
          final siteCommissionController = TextEditingController(text: provider.settings['SITE_COMMISSION_PERCENT'] ?? '');
          final driverCommissionController = TextEditingController(text: provider.settings['DRIVER_COMMISSION_PERCENT'] ?? '');
          final taxController = TextEditingController(text: provider.settings['TAX_PERCENT'] ?? '');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: const Color.fromARGB(255, 10, 3, 3), borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Site Setting', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  _buildTextField(websiteNameController, 'Website Name'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(addressController, 'Address')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField(emailController, 'Email')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(contactController, 'Contact No.'),
                  const SizedBox(height: 24),
                  const Text('Payment Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(siteCommissionController, 'Site Commission %')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField(driverCommissionController, 'Driver Commission %')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField(taxController, 'Tax %')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      final newSettings = {
                        'WEBSITE_NAME': websiteNameController.text,
                        'ADDRESS': addressController.text,
                        'EMAIL': emailController.text,
                        'CONTACT_NO': contactController.text,
                        'SITE_COMMISSION_PERCENT': siteCommissionController.text,
                        'DRIVER_COMMISSION_PERCENT': driverCommissionController.text,
                        'TAX_PERCENT': taxController.text,
                      };
                      provider.updateSettings(newSettings).then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved!')));
                      }).catchError((e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      });
                    },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                    child: const Text('Save Settings', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper to build a consistent text field
  Widget _buildTextField(TextEditingController controller, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}