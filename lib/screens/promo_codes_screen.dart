// lib/screens/promo_codes_screen.dart
import 'package:flutter/material.dart';
import '/models/promo_code.dart';
import '../data/repository/promo_code_repository.dart';

class PromoCodesScreen extends StatefulWidget {
  const PromoCodesScreen({Key? key}) : super(key: key);
  @override
  State<PromoCodesScreen> createState() => _PromoCodesScreenState();
}

class _PromoCodesScreenState extends State<PromoCodesScreen> {
  final PromoCodeRepository _repo = PromoCodeRepository();
  Future<List<PromoCode>>? _promoCodesFuture;

  @override
  void initState() {
    super.initState();
    _loadPromoCodes();
  }

  void _loadPromoCodes() {
    setState(() {
      _promoCodesFuture = _repo.getAllPromoCodes();
    });
  }

  void _showAddEditDialog({PromoCode? promoCode}) {
    final isEditing = promoCode != null;
    final codeController = TextEditingController(text: promoCode?.code ?? '');
    final limitController = TextEditingController(text: promoCode?.usageLimit.toString() ?? '');
    final valueController = TextEditingController(text: promoCode?.discountValue.toString() ?? '');
    final expiryController = TextEditingController(text: promoCode?.expiryDate ?? '');
    String discountType = promoCode?.discountType ?? 'percentage';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Promo Code' : 'Add Promo Code'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: codeController, decoration: const InputDecoration(labelText: 'Promo Code'), textCapitalization: TextCapitalization.characters),
                TextField(controller: limitController, decoration: const InputDecoration(labelText: 'Usage Limit'), keyboardType: TextInputType.number),
                DropdownButtonFormField<String>(
                  value: discountType,
                  decoration: const InputDecoration(labelText: 'Discount Type'),
                  items: const [
                    DropdownMenuItem(value: 'percentage', child: Text('Percentage (%)')),
                    DropdownMenuItem(value: 'amount', child: Text('Amount (₹)')),
                  ],
                  onChanged: (value) => setDialogState(() => discountType = value!)),
                TextField(controller: valueController, decoration: InputDecoration(labelText: discountType == 'percentage' ? 'Discount Percentage (%)' : 'Discount Amount (₹)'), keyboardType: TextInputType.number),
                TextField(controller: expiryController, decoration: const InputDecoration(labelText: 'Expiry Date (YYYY-MM-DD)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final newPromoCode = PromoCode(
                  id: promoCode?.id ?? '',
                  code: codeController.text.toUpperCase(),
                  usageLimit: int.tryParse(limitController.text) ?? 0,
                  totalUsed: promoCode?.totalUsed ?? 0,
                  expiryDate: expiryController.text,
                  discountValue: double.tryParse(valueController.text) ?? 0,
                  discountType: discountType,
                  isActive: promoCode?.isActive ?? true,
                );

                try {
                  if (isEditing) {
                    await _repo.updatePromoCode(promoCode!.id, newPromoCode);
                  } else {
                    await _repo.addPromoCode(newPromoCode);
                  }
                  _loadPromoCodes();
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                }
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _deletePromoCode(PromoCode promoCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Promo Code'),
        content: Text('Are you sure you want to delete ${promoCode.code}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                await _repo.deletePromoCode(promoCode.id);
                _loadPromoCodes();
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Promocode List", style: Theme.of(context).textTheme.headlineMedium),
              ElevatedButton.icon(
                onPressed: _showAddEditDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add New Promocode'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Color.fromARGB(255, 15, 5, 5), borderRadius: BorderRadius.all(Radius.circular(8))),
              child: FutureBuilder<List<PromoCode>>(
                future: _promoCodesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No promo codes found."));
                  }
                  final promoCodes = snapshot.data!;
                  return SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('No')),
                        DataColumn(label: Text('Promocode')),
                        DataColumn(label: Text('Discount')),
                        DataColumn(label: Text('Usage Limit')),
                        DataColumn(label: Text('Total Used')),
                        DataColumn(label: Text('Expiry Date')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: promoCodes.asMap().entries.map((entry) {
                        final index = entry.key;
                        final promoCode = entry.value;
                        return DataRow(cells: [
                          DataCell(Text('${index + 1}')),
                          DataCell(Text(promoCode.code, style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text(promoCode.discountType == 'percentage'
                              ? '${promoCode.discountValue}%'
                              : '₹${promoCode.discountValue}')),
                          DataCell(Text('${promoCode.usageLimit}')),
                          DataCell(Text('${promoCode.totalUsed}')),
                          DataCell(Text(promoCode.expiryDate)),
                          DataCell(Row(
                            children: [
                              IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showAddEditDialog(promoCode: promoCode)),
                              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deletePromoCode(promoCode)),
                            ],
                          )),
                        ]);
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}