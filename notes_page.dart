import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final _firestore = FirebaseFirestore.instance;

  Future<void> _openAddNoteDialog() async {
    final _formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final collegeController = TextEditingController();
    final topicController = TextEditingController();
    final notesController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Upload Note"),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Your Name"),
                    validator: (val) =>
                        val == null || val.isEmpty ? "Required" : null,
                  ),
                  TextFormField(
                    controller: collegeController,
                    decoration:
                        const InputDecoration(labelText: "College Name"),
                    validator: (val) =>
                        val == null || val.isEmpty ? "Required" : null,
                  ),
                  TextFormField(
                    controller: topicController,
                    decoration: const InputDecoration(labelText: "Topic"),
                    validator: (val) =>
                        val == null || val.isEmpty ? "Required" : null,
                  ),
                  TextFormField(
                    controller: notesController,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: "Notes"),
                    validator: (val) =>
                        val == null || val.isEmpty ? "Required" : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Upload"),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await _firestore.collection("notes").add({
                    "name": nameController.text.trim(),
                    "college": collegeController.text.trim(),
                    "topic": topicController.text.trim(),
                    "notes": notesController.text.trim(),
                    "timestamp": FieldValue.serverTimestamp(),
                  });
                  Navigator.pop(context); // close dialog
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Uploaded Notes")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection("notes")
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading notes"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notes = snapshot.data!.docs;

          if (notes.isEmpty) {
            return const Center(child: Text("No notes uploaded yet."));
          }

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final data = notes[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(data['topic'] ?? 'Untitled'),
                  subtitle: Text(
                      "${data['name']} • ${data['college']}\n${data['notes']}"),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddNoteDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
