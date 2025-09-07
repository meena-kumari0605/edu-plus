import 'quiz_page.dart';

class Question {
  final String text;
  final List<String> options;
  final int answerIndex;
  const Question({required this.text, required this.options, required this.answerIndex});
}

// Replace/add with your own questions.
// Structure kept simple & consistent across app.
final Map<String, List<Question>> quizBank = {
  'Data Structures': const [
    Question(
      text: 'Which data structure uses FIFO order?',
      options: ['Stack', 'Queue', 'Tree', 'Graph'],
      answerIndex: 1,
    ),
    Question(
      text: 'Time complexity of binary search?',
      options: ['O(n)', 'O(log n)', 'O(n log n)', 'O(1)'],
      answerIndex: 1,
    ),
  ],
  'Algorithms': const [
    Question(
      text: 'Dijkstra’s algorithm is used to find:',
      options: ['MST', 'Shortest path', 'Topological order', 'Maximum flow'],
      answerIndex: 1,
    ),
    Question(
      text: 'Divide and conquer is used in:',
      options: ['Merge Sort', 'Bubble Sort', 'Counting Sort', 'Insertion Sort'],
      answerIndex: 0,
    ),
  ],
  'Operating Systems': const [
    Question(
      text: 'Which is a non-preemptive scheduling algorithm?',
      options: ['SJF', 'Round Robin', 'Priority (preemptive)', 'FCFS'],
      answerIndex: 3,
    ),
    Question(
      text: 'Thrashing is related to:',
      options: ['CPU scheduling', 'Deadlock', 'Paging', 'I/O scheduling'],
      answerIndex: 2,
    ),
  ],
  'Computer Networks': const [
    Question(
      text: 'HTTP works over which layer?',
      options: ['Transport', 'Network', 'Application', 'Data Link'],
      answerIndex: 2,
    ),
    Question(
      text: 'Which device operates at Layer 3?',
      options: ['Switch', 'Repeater', 'Hub', 'Router'],
      answerIndex: 3,
    ),
  ],
};

