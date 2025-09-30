import 'package:finalsalesrep/offline/offlineformmodel.dart';
import 'package:flutter/material.dart';
import 'package:finalsalesrep/offline/localdb.dart';

class SavedFormsScreen extends StatefulWidget {
  const SavedFormsScreen({super.key});

  @override
  State<SavedFormsScreen> createState() => _SavedFormsScreenState();
}

class _SavedFormsScreenState extends State<SavedFormsScreen> {
  late Future<List<LocalCustomerForm>> _formsFuture;

  @override
  void initState() {
    super.initState();
    _loadForms();
  }

  void _loadForms() {
    _formsFuture = LocalDb().getPendingForms().then(
      (list) => list.map((e) => LocalCustomerForm.fromDb(e)).toList(),
    );
  }

  Future<void> _deleteForm(int id) async {
    final db = await LocalDb().database;
    await db.delete('customer_forms', where: 'id = ?', whereArgs: [id]);
    setState(() => _loadForms());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Form deleted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Forms')),
      body: FutureBuilder<List<LocalCustomerForm>>(
        future: _formsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final forms = snapshot.data ?? [];
          if (forms.isEmpty) {
            return const Center(child: Text('No saved forms'));
          }

          return ListView.builder(
            itemCount: forms.length,
            itemBuilder: (context, index) {
              final form = forms[index];
              final name = form.formData['family_head_name'] ?? 'Unnamed';
              final date = form.formData['date'] ?? 'Unknown';
              final mobile = form.formData['mobile_number'] ?? 'N/A';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(name),
                  subtitle: Text("Date: $date\nMobile: $mobile"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteForm(form.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
