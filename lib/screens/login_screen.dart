import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trashhdetection/screens/forgotpassword_screen.dart';
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
  bool isUserLogin = true;
  bool _isLoading = false;
  bool _showResend = false;
  bool _obscurePassword = true;

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
        _showResend = false;
      });

      try {
        UserCredential userCredential =
            await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        final User? user = userCredential.user;

        if (user != null && !user.emailVerified) {
          await _auth.signOut();

          setState(() {
            _showResend = true;
            _isLoading = false;
          });

          _showErrorDialog(
              'Your email is not verified. Please verify it before logging in.');
          return;
        }

        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(user!.uid)
            .get();

        if (!userDoc.exists) {
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'User document not found in Firestore',
          );
        }

        Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;

        if (userData == null || !userData.containsKey('username')) {
          throw FirebaseAuthException(
            code: 'missing-username',
            message: '⚠️ Username field is missing in Firestore!',
          );
        }

        String role = userData['role'] ?? 'User';
        String username = userData['username'] ?? 'Unknown User';
        String email = userData['email'] ?? emailController.text.trim();

        if (isUserLogin && role == 'User') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  UserHome(username: username, email: email),
            ),
          );
        } else if (!isUserLogin && role == 'Admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AdminDashboardScreen(username: username, email: email),
            ),
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

  Future<void> _resendVerificationEmail() async {
    try {
      final user = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await user.user?.sendEmailVerification();
      await _auth.signOut();

      _showErrorDialog('Verification email resent! Please check your inbox.');
    } catch (e) {
      _showErrorDialog('Failed to resend verification email.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Notice'),
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

  void navigateToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
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
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter your email' : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) => value!.isEmpty
                            ? 'Please enter your password'
                            : null,
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                          ),
                          child: _isLoading
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Logging in...',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                      if (_showResend) ...[
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: _resendVerificationEmail,
                          child: const Text('Resend Verification Email',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: navigateToForgotPassword,
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
