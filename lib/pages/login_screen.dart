import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: LoginForm(),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _signInWithEmailAndPassword() async {
    try {
      // Sign in with email and password
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Navigate to the home page after successful authentication
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Try again, wrong email/password';
      if (e.code == 'user-not-found') {
        errorMessage = 'Email not found';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password';
      }
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Login Error'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      // Handle other errors
      print('Error signing in: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _signInWithEmailAndPassword, // Call the signIn method
            child: Text('Login'),
          ),
          SizedBox(height: 8),
          TextButton(
            onPressed: () {
              // Navigate to the signup screen
              Navigator.pushReplacementNamed(context, '/signup');
            },
            child: Text('Don\'t have an account? Sign up'),
          ),
        ],
      ),
    );
  }
}
