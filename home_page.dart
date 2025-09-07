import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? profile;
  bool _loading = true;

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (mounted) {
      setState(() {
        profile = snap.data();
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  // 🔹 Function to pick and upload file (ask details first, then pick file)
  Future<void> _pickAndUploadNote() async {
    final nameController = TextEditingController();
    final collegeController = TextEditingController();
    final topicController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Upload Note"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Your Name"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: collegeController,
                decoration: const InputDecoration(labelText: "College Name"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: topicController,
                decoration: const InputDecoration(labelText: "Topic"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty ||
                  collegeController.text.trim().isEmpty ||
                  topicController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill all fields")),
                );
                return;
              }

              Navigator.pop(context); // close dialog

              // 🔹 Pick file AFTER details
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['jpg', 'png', 'mp4', 'pdf', 'ppt', 'pptx'],
              );

              if (result == null) return; // user canceled
              final file = File(result.files.single.path!);
              final fileName = result.files.single.name;

              final uid = FirebaseAuth.instance.currentUser?.uid ?? "guest";

              // Upload file to Firebase Storage
              final storageRef = FirebaseStorage.instance
                  .ref()
                  .child("notes/$uid/$fileName");

              await storageRef.putFile(file);
              final downloadUrl = await storageRef.getDownloadURL();

              // Save metadata + file URL in Firestore
              await FirebaseFirestore.instance.collection("notes").add({
                "uid": uid,
                "name": nameController.text.trim(),
                "college": collegeController.text.trim(),
                "topic": topicController.text.trim(),
                "fileUrl": downloadUrl,
                "fileName": fileName,
                "timestamp": FieldValue.serverTimestamp(),
              });

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Note uploaded successfully!")),
              );
            },
            child: const Text("Next"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = profile?['name'] ?? 'Student';
    final year = profile?['year']?.toString() ?? '-';
    final sem = profile?['semester']?.toString() ?? '-';
    final bio = profile?['bio'] ?? '';
    final uid = FirebaseAuth.instance.currentUser?.uid ?? "guest";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                // 🔹 Profile Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: const Color(0xFF3B82F6),
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : "?",
                            style: const TextStyle(
                                fontSize: 26,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text("Year $year • Semester $sem",
                                  style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 14)),
                              if (bio.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(bio,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13)),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.edit, color: Color(0xFF3B82F6)),
                          onPressed: () => Navigator.pushNamed(
                                  context, '/edit_profile')
                              .then((_) => _loadProfile()),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 🔹 Hero banner
                Card(
                  color: const Color(0xFF3B82F6),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        const Icon(Icons.school,
                            color: Colors.white, size: 48),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Welcome back, $name 👋',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              Text('Year $year • Semester $sem',
                                  style:
                                      const TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ),
                        FilledButton.tonal(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/subjects'),
                          style: FilledButton.styleFrom(
                              backgroundColor: Colors.white),
                          child: const Text('Start Learning',
                              style: TextStyle(color: Color(0xFF1F58E7))),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 🔹 Quick actions
                Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.menu_book_outlined,
                        title: 'Subjects',
                        subtitle: 'Browse topics',
                        onTap: () =>
                            Navigator.pushNamed(context, '/subjects'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.quiz_outlined,
                        title: 'Quick Quiz',
                        subtitle: 'Test yourself',
                        onTap: () =>
                            Navigator.pushNamed(context, '/quiz_subjects'), // 👈 FIXED
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 🔹 Progress + Uploaded Notes Side by Side
                Row(
                  children: [
                    const Expanded(
                      child: _ActionCard(
                        icon: Icons.insights_outlined,
                        title: 'Progress',
                        subtitle: 'Coming soon',
                        onTap: null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Uploaded Notes",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection("notes")
                                    .where("uid", isEqualTo: uid)
                                    .orderBy("timestamp", descending: true)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  if (!snapshot.hasData ||
                                      snapshot.data!.docs.isEmpty) {
                                    return const Text(
                                      "No notes yet.\nUse + to add.",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    );
                                  }

                                  final notes = snapshot.data!.docs;

                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount:
                                        notes.length > 3 ? 3 : notes.length,
                                    itemBuilder: (context, index) {
                                      final note = notes[index].data()
                                          as Map<String, dynamic>;
                                      return ListTile(
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        leading: const Icon(Icons.note,
                                            size: 20),
                                        title: Text(
                                          note["topic"] ?? "Untitled",
                                          style:
                                              const TextStyle(fontSize: 13),
                                        ),
                                        subtitle: Text(
                                          note["college"] ?? "",
                                          style:
                                              const TextStyle(fontSize: 11),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

      // 🔹 Floating Action Button for uploading notes
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndUploadNote,
        backgroundColor: const Color(0xFF3B82F6),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF3B82F6)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style:
                            const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: TextStyle(color: Colors.grey.shade700)),
                  ]),
            ),
            const Icon(Icons.chevron_right),
          ]),
        ),
      ),
    );
  }
}
