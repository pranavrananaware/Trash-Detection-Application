import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trashhdetection/screens/user/user_home.dart';
import 'package:trashhdetection/screens/admin/admin_dashboard.dart';
import 'package:trashhdetection/screens/signup_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isUserLogin = true; // Toggle between User and Admin Login
  bool _isLoading = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void toggleLoginForm(bool isUser) {
    setState(() {
      isUserLogin = isUser;
    });
  }

 Future<void> handleLogin() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'User document not found in Firestore',
        );
      }

      Map<String, dynamic>? userData =
          userDoc.data() as Map<String, dynamic>?; // Type casting

      if (userData == null || !userData.containsKey('username')) {
        throw FirebaseAuthException(
          code: 'missing-username',
          message: '⚠️ Username field is missing in Firestore! Check Signup Code.',
        );
      }

      // ✅ Debugging: Print Firestore data
      print("Firestore User Data: $userData");

      String role = userData['role'] ?? 'User';
      String username = userData['username'] ?? 'Unknown User';
      String email = userData['email'] ?? emailController.text.trim();

      if (isUserLogin && role == 'User') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserHome(username: username, email: email),
          ),
        );
      } else if (!isUserLogin && role == 'Admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboardScreen(username: '', email: '',)),
        );
      } else {
        throw FirebaseAuthException(
          code: 'wrong-role',
          message: 'Incorrect role selected',
        );
      }
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(e.message ?? 'Login failed. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Login Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void navigateToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignupScreen()),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => toggleLoginForm(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isUserLogin
                            ? Colors.blue.shade700
                            : Colors.grey,
                      ),
                      child: const Text('User Login',
                          style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () => toggleLoginForm(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !isUserLogin
                            ? Colors.blue.shade700
                            : Colors.grey,
                      ),
                      child: const Text('Admin Login',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty
                            ? 'Please enter your email'
                            : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty
                            ? 'Please enter your password'
                            : null,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('Login', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {},
                  child: Text('Forgot Password?',
                      style: TextStyle(color: Colors.blue.shade700)),
                ),
                TextButton(
                  onPressed: navigateToSignup,
                  child: Text("Don't have an account? Sign Up",
                      style: TextStyle(color: Colors.blue.shade700)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
