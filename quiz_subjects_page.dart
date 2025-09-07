import 'package:flutter/material.dart';
import 'quiz_data.dart';
import 'quiz_page.dart';

class QuizSubjectsPage extends StatelessWidget {

  const QuizSubjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final subjects = quizBank.keys.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Subjects')),
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
          final s = subjects[i];
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                final questions = quizBank[s]!;
                Navigator.pushNamed(
                  context,
                  QuizPage.routeName,
                  arguments: QuizPageArgs(subjectName: s, questions: questions),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_iconForSubject(s), color: const Color(0xFF3B82F6), size: 28),
                  ),
                  const Spacer(),
                  Text(s, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text('Tap to practice'),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _iconForSubject(String s) {
    if (s.toLowerCase().contains('data')) return Icons.dataset_outlined;
    if (s.toLowerCase().contains('algo')) return Icons.auto_awesome_motion_outlined;
    if (s.toLowerCase().contains('os')) return Icons.memory_outlined;
    if (s.toLowerCase().contains('net')) return Icons.network_check_outlined;
    return Icons.menu_book_outlined;
  }
}
