import 'package:flutter/material.dart';
import '/models/document.dart';
import '../data/repository/document_repository.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({Key? key}) : super(key: key);
  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final DocumentRepository _repo = DocumentRepository();
  Future<List<DocumentType>>? _documentsFuture;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  void _loadDocuments() {
    setState(() {
      _documentsFuture = _repo.getAllDocuments();
    });
  }

  void _showAddEditDialog({DocumentType? document}) {
    final isEditing = document != null;
    final nameController = TextEditingController(text: document?.name ?? '');
    bool requiresExpiry = document?.requiresExpiry ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Document' : 'Add Document'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Document Name'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: requiresExpiry,
                    onChanged: (value) => setDialogState(() => requiresExpiry = value ?? false),
                  ),
                  const Text('Requires Expiry Date'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter document name')));
                  return;
                }
                final newDocument = DocumentType(
                  id: document?.id ?? '', // ID is ignored by backend on create
                  name: nameController.text,
                  requiresExpiry: requiresExpiry,
                  isActive: document?.isActive ?? true,
                );
                try {
                  if (isEditing) {
                    await _repo.updateDocument(document!.id, newDocument);
                  } else {
                    await _repo.addDocument(newDocument);
                  }
                  _loadDocuments(); // Refresh the list
                  Navigator.pop(context); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEditing ? 'Document updated successfully' : 'Document added successfully')),
                  );
                } catch (e) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                }
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteDocument(DocumentType document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Are you sure you want to delete ${document.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                await _repo.deleteDocument(document.id);
                _loadDocuments(); // Refresh the list
                Navigator.pop(context); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Document deleted successfully')),
                );
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
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
          Container(
            padding: const EdgeInsets.all(24),
            color: const Color.fromARGB(255, 9, 2, 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Required Documents List',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddEditDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Document'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 13, 6, 6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FutureBuilder<List<DocumentType>>(
                  future: _documentsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text("No required documents found. Click 'Add Document' to create one."),
                        ),
                      );
                    }
                    final documents = snapshot.data!;
                    return DataTable(
                      columns: const [
                        DataColumn(label: Text('No')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Requires Expiry')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: documents.asMap().entries.map((entry) {
                        final index = entry.key;
                        final doc = entry.value;
                        return DataRow(cells: [
                          DataCell(Text('${index + 1}')),
                          DataCell(Text(doc.name)),
                          DataCell(
                            Switch(
                              value: doc.requiresExpiry,
                              onChanged: (value) async {
                                final updatedDocument = DocumentType(
                                  id: doc.id,
                                  name: doc.name,
                                  requiresExpiry: value,
                                  isActive: doc.isActive,
                                );
                                try {
                                  await _repo.updateDocument(doc.id, updatedDocument);
                                  _loadDocuments();
                                } catch (e) {
                                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                }
                              },
                            ),
                          ),
                          DataCell(Row(
                            children: [
                              IconButton(icon: const Icon(Icons.edit, size: 18, color: Colors.blue), onPressed: () => _showAddEditDialog(document: doc)),
                              IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: () => _deleteDocument(doc)),
                            ],
                          )),
                        ]);
                      }).toList(),
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