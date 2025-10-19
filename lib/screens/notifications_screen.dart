import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notifications/notifications_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NotificationsProvider(),
      child: Consumer<NotificationsProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration( // Removed const
                color: const Color.fromARGB(255, 11, 5, 5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Send Push Notification', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  _SendNotificationForm(), // Use the stateful form
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text('Notification History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.error != null
                      ? Center(child: Text("Error: ${provider.error}"))
                      : DataTable(
                          columns: const [
                            DataColumn(label: Text('No')),
                            DataColumn(label: Text('Type')),
                            DataColumn(label: Text('Title')),
                            DataColumn(label: Text('Message')),
                            DataColumn(label: Text('Time')),
                          ],
                          rows: provider.notifications.asMap().entries.map((entry) {
                            final index = entry.key;
                            final notif = entry.value;
                            return DataRow(cells: [
                              DataCell(Text('${index + 1}')),
                              DataCell(Text(notif.type)),
                              DataCell(Text(notif.title)),
                              DataCell(Text(notif.message)),
                              DataCell(Text(notif.createdAt.toLocal().toString().split('.')[0])),
                            ]);
                          }).toList(),
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SendNotificationForm extends StatefulWidget {
  @override
  _SendNotificationFormState createState() => _SendNotificationFormState();
}

class _SendNotificationFormState extends State<_SendNotificationForm> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _notificationType = 'All Users';
  bool _isSending = false;

  void _sendNotification() async {
    final provider = Provider.of<NotificationsProvider>(context, listen: false);
    setState(() => _isSending = true);
    try {
      await provider.sendNotification(
        type: _notificationType,
        title: _titleController.text,
        message: _messageController.text,
      );
      _titleController.clear();
      _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification sent successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isSending = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown('Notification Type', ['All Users', 'All Drivers']),
        const SizedBox(height: 16),
        _buildTextField(_titleController, 'Title'),
        const SizedBox(height: 16),
        _buildTextField(_messageController, 'Message', maxLines: 4),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isSending ? null : _sendNotification,
          child: _isSending ? const CircularProgressIndicator() : const Text('Send', style: TextStyle(fontSize: 16)),
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
        ),
      ],
    );
  }

  // --- THESE ARE THE CORRECTED HELPER METHODS ---
  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
        ),
      ],
    );
  }
  
  Widget _buildDropdown(String label, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _notificationType,
          decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: (value) {
            if (value != null) setState(() => _notificationType = value);
          },
        ),
      ],
    );
  }
}