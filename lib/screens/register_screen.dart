import 'package:flutter/material.dart';
import '../api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;

  void _register() async {
    setState(() => _isLoading = true);
    final errorMsg = await apiService.register(_nameCtrl.text.trim(), _emailCtrl.text.trim(), _passwordCtrl.text);
    setState(() => _isLoading = false);
    if (errorMsg == null && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration successful. Please login.')));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration failed: $errorMsg')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 10),
            TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 10),
            TextField(controller: _passwordCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 20),
            _isLoading 
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: _register, child: const Text('Register')),
          ],
        ),
      ),
    );
  }
}
