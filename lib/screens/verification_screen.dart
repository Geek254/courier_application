import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

final DateTime currentDateTime = DateTime.now();

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _idController = TextEditingController();
  final _packageContentController = TextEditingController();
  bool _isVerified = false;
  bool _isLoading = false;

  Future<void> _submitVerification() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.submitVerification(_idController.text.trim(), _packageContentController.text.trim());
      final isVerified = await authService.isVerified(user.uid);
      setState(() => _isVerified = isVerified);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isVerified ? 'Verification approved!' : 'Verification submitted for review')),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            elevation: 12,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.white.withOpacity(0.95),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Account Verification',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _idController,
                    decoration: InputDecoration(
                      labelText: 'ID Number',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _packageContentController,
                    decoration: InputDecoration(
                      labelText: 'Package Contents',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[700],
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Submit Verification', style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                  if (_isVerified)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        'Your account is verified!',
                        style: TextStyle(fontSize: 16, color: Colors.green),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _packageContentController.dispose();
    super.dispose();
  }
}