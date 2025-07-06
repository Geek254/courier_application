import 'package:courier_application/screens/auth/login.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';


final DateTime currentDateTime = DateTime.now();

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final authService = context.read<AuthService>();
    final user = await authService.signUp(
      _emailController.text,
      _passwordController.text,
      _nameController.text,
      _roleController.text,
    );
    if (user != null) {
      if (kDebugMode) print("Sign up successful, redirecting to LoginScreen for UID ${user.id} at $currentDateTime");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      if (kDebugMode) print("Sign up failed for email ${_emailController.text} at $currentDateTime");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign up failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[900]!, Colors.purple[400]!],
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _animation,
            child: Card(
              elevation: 20,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.white.withOpacity(0.95),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.person_add,
                      size: 100,
                      color: Colors.purple,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Join us to get started',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        prefixIcon: const Icon(Icons.person, color: Colors.purple),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email, color: Colors.purple),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock, color: Colors.purple),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            color: Colors.purple,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      obscureText: _obscurePassword,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _roleController,
                      decoration: InputDecoration(
                        labelText: 'Role (admin/traveler/passenger)',
                        prefixIcon: const Icon(Icons.work, color: Colors.purple),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _signUp,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 8,
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}