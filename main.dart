import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'login_page.dart';
import 'signup_page.dart';
import 'home_page.dart';
import 'subject_page.dart';
import 'quiz_page.dart';
import 'quiz_data.dart';
import 'profile_page.dart'; 
import 'notes_page.dart';
import 'quiz_subjects_page.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const EduPlusApp());
}

class EduPlusApp extends StatelessWidget {
  const EduPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    final seed = Colors.blue;
    return MaterialApp(
      title: 'Edu+',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: seed,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFEFF4FF),
        cardTheme: CardThemeData(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
      ),
      initialRoute: '/login',
    routes: {
  '/login': (context) => LoginPage(),
  '/signup': (context) => SignupPage(),
  '/home': (context) => HomePage(),
  '/subjects': (context) => SubjectPage(), // now for notes
  '/quiz_subjects': (context) => QuizSubjectsPage(),
  '/profile': (context) => ProfilePage(),
  '/notes': (context) => NotesPage(),
},


      onGenerateRoute: (settings) {
        if (settings.name == QuizPage.routeName) {
          final args = settings.arguments as QuizPageArgs;
          return MaterialPageRoute(
            builder: (_) => QuizPage(
              subjectName: args.subjectName,
              questions: args.questions,
            ),
          );
        }
        return null;
      },
    );
  }
}
