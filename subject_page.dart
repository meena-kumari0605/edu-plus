import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class SubjectPage extends StatelessWidget {
  const SubjectPage({super.key});

  final Map<String, List<String>> departments = const {
    "CSE": [
      "Data Structures",
      "DBMS",
      "Operating Systems",
      "Computer Networks",
      "AI & ML",
    ],
    "ECE": [
      "Digital Electronics",
      "VLSI",
      "Signal Processing",
    ],
    "MECH": [
      "Thermodynamics",
      "Fluid Mechanics",
      "Machine Design",
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Departments')),
      body: ListView.builder(
        itemCount: departments.keys.length,
        itemBuilder: (context, index) {
          final deptName = departments.keys.elementAt(index);
          final subjects = departments[deptName]!;

          return Card(
            child: ListTile(
              title: Text(deptName,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        SubjectListPage(department: deptName, subjects: subjects),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class SubjectListPage extends StatelessWidget {
  final String department;
  final List<String> subjects;

  const SubjectListPage({
    super.key,
    required this.department,
    required this.subjects,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$department Subjects")),
      body: GridView.builder(
        padding: const EdgeInsets.all(18),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.1,
        ),
        itemCount: subjects.length,
        itemBuilder: (context, i) {
          final subject = subjects[i];
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotesListPage(subjectName: subject),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.menu_book_outlined,
                          color: Color(0xFF3B82F6), size: 28),
                    ),
                    const Spacer(),
                    Text(subject,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    const Text('Tap to view notes'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class NotesListPage extends StatelessWidget {
  final String subjectName;

  const NotesListPage({super.key, required this.subjectName});

  Future<void> _openFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(subjectName)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("notes")
            .where("topic", isEqualTo: subjectName)
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No notes uploaded yet."));
          }

          final notes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.note, color: Colors.blue),
                  title: Text(note["fileName"] ?? "Untitled"),
                  subtitle: Text(
                      "${note["college"] ?? ""} • Uploaded by ${note["name"] ?? ""}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.open_in_new, color: Colors.blue),
                    onPressed: () => _openFile(note["fileUrl"]),
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
