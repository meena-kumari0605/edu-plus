import 'package:flutter/material.dart';
import 'quiz_data.dart';

class QuizPageArgs {
  final String subjectName;
  final List<Question> questions;
  QuizPageArgs({required this.subjectName, required this.questions});
}

class QuizPage extends StatefulWidget {
  static const routeName = '/quiz';
  final String subjectName;
  final List<Question> questions;

  const QuizPage({super.key, required this.subjectName, required this.questions});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _current = 0;
  int _score = 0;
  int? _selected;

  void _next() {
    if (_selected == widget.questions[_current].answerIndex) _score++;
    if (_current < widget.questions.length - 1) {
      setState(() {
        _current++;
        _selected = null;
      });
    } else {
      _showResult();
    }
  }

  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Quiz Completed'),
        content: Text('You scored $_score / ${widget.questions.length}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _current = 0;
                _score = 0;
                _selected = null;
              });
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.questions[_current];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subjectName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            // Progress
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: (_current + 1) / widget.questions.length,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${_current + 1}/${widget.questions.length}'),
              ],
            ),
            const SizedBox(height: 18),

            // Question
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(q.text,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 12),

            // Options
            ...List.generate(q.options.length, (i) {
              final selected = _selected == i;
              return Card(
                child: ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  leading: CircleAvatar(child: Text(String.fromCharCode(65 + i))),
                  title: Text(q.options[i]),
                  trailing: selected ? const Icon(Icons.check_circle, color: Colors.green) : null,
                  onTap: () => setState(() => _selected = i),
                ),
              );
            }),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _selected == null ? null : _next,
                child: Text(_current == widget.questions.length - 1 ? 'Finish' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
