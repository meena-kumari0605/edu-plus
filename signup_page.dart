import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _bio = TextEditingController();
  String? _year;
  String? _semester;

  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _bio.dispose();
    super.dispose();
  }

  // ✅ Email validation
  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter email';
    final re = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!re.hasMatch(v.trim())) return 'Enter valid email';
    return null;
  }

  // ✅ Strong password validation
  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Enter password';
    if (v.length < 8) return 'Password must be at least 8 characters';
    final regex =
        RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$');
    if (!regex.hasMatch(v)) {
      return 'Password must include:\n• Uppercase\n• Lowercase\n• Number\n• Special character';
    }
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'Confirm password';
    if (v != _password.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _signup() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_year == null || _semester == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Select year & semester')));
      return;
    }
    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
        'uid': cred.user!.uid,
        'name': _name.text.trim(),
        'email': _email.text.trim(),
        'year': _year,
        'semester': _semester,
        'bio': _bio.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created! Please login.')));
      Navigator.pushReplacementNamed(context, '/login');
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Signup failed')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Row(
                      children: const [
                        Icon(Icons.person_add_alt_1, color: Color(0xFF3B82F6)),
                        SizedBox(width: 8),
                        Text(
                          'Let’s get you started',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Full Name
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Enter name' : null,
                    ),
                    const SizedBox(height: 12),

                    // Email
                    TextFormField(
                      controller: _email,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 12),

                    // Year + Semester dropdowns
                    Row(children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _year,
                          decoration: const InputDecoration(
                            labelText: 'Year',
                            prefixIcon: Icon(Icons.calendar_month),
                          ),
                          items: const [
                            DropdownMenuItem(value: '1st', child: Text('1st Year')),
                            DropdownMenuItem(value: '2nd', child: Text('2nd Year')),
                            DropdownMenuItem(value: '3rd', child: Text('3rd Year')),
                            DropdownMenuItem(value: '4th', child: Text('4th Year')),
                          ],
                          onChanged: (v) => setState(() => _year = v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _semester,
                          decoration: const InputDecoration(
                            labelText: 'Semester',
                            prefixIcon: Icon(Icons.layers_outlined),
                          ),
                          items: const [
                            DropdownMenuItem(value: '1', child: Text('Semester 1')),
                            DropdownMenuItem(value: '2', child: Text('Semester 2')),
                            DropdownMenuItem(value: '3', child: Text('Semester 3')),
                            DropdownMenuItem(value: '4', child: Text('Semester 4')),
                            DropdownMenuItem(value: '5', child: Text('Semester 5')),
                            DropdownMenuItem(value: '6', child: Text('Semester 6')),
                            DropdownMenuItem(value: '7', child: Text('Semester 7')),
                            DropdownMenuItem(value: '8', child: Text('Semester 8')),
                          ],
                          onChanged: (v) => setState(() => _semester = v),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),

                    // Bio
                    TextFormField(
                      controller: _bio,
                      minLines: 2,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Bio (optional)',
                        prefixIcon: Icon(Icons.info_outline),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Password
                    TextFormField(
                      controller: _password,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                          icon: Icon(_obscure
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                      ),
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 12),

                    // Confirm Password
                    TextFormField(
                      controller: _confirm,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      obscureText: _obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_reset),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _obscureConfirm = !_obscureConfirm),
                          icon: Icon(_obscureConfirm
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                      ),
                      validator: _validateConfirm,
                    ),
                    const SizedBox(height: 16),

                    // Create Account button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _loading ? null : _signup,
                        child: _loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Create Account'),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Back to login
                    TextButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/login'),
                      child: const Text('Back to Login'),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
