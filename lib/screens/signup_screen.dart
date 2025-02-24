import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trashhdetection/screens/login_screen.dart'; // Import the LoginScreen

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  String? selectedRole;

  Future<void> handleSignup() async {
    if (selectedRole == null) {
      _showErrorDialog("Please select a role (User or Admin)");
      return;
    }

    if (usernameController.text.trim().isEmpty) {
      _showErrorDialog("Username cannot be empty.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if email already exists
      List<String> signInMethods =
          // ignore: deprecated_member_use
          await _auth.fetchSignInMethodsForEmail(emailController.text.trim());

      if (signInMethods.isNotEmpty) {
        _showErrorDialog("Email already exists. Use a different email.");
        setState(() => _isLoading = false);
        return;
      }

      // Create new user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      print("User created successfully: ${userCredential.user!.uid}");

      // Store user data in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'role': selectedRole,
        'uid': userCredential.user!.uid,
      });

      print("User data stored in Firestore");

      setState(() {
        _isLoading = false;
      });

      // Navigate to LoginScreen after a successful sign up
      if (mounted) {
        // Ensure that the navigator is pushed after the async task is complete
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (e.code == 'email-already-in-use') {
        _showErrorDialog("This email is already registered. Try logging in.");
      } else {
        _showErrorDialog(e.message ?? "Signup failed. Try again.");
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Signup Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.water_damage,
                  size: 100,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(height: 20),
                Text(
                  'Water Trash Detection',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 30),
                // Username Input
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                // Email Input
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                // Password Input
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                // Role Selection Dropdown
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: "Select Role",
                    border: OutlineInputBorder(),
                  ),
                  items: ['User', 'Admin'].map((role) {
                    return DropdownMenuItem(value: role, child: Text(role));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value;
                    });
                  },
                ),
                const SizedBox(height: 30),
                // Sign Up Button
                ElevatedButton(
                  onPressed: _isLoading ? null : handleSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Sign Up', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 20),
                // Navigate to Login
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Already have an account? Login',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
