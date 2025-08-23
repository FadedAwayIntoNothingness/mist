import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // For context.go

class InitializeScreen extends StatefulWidget {
  static const routeName = 'InitializeScreen';
  static const routePath = '/initialize';

  const InitializeScreen({super.key});

  @override
  State<InitializeScreen> createState() => _InitializeScreenState();
}

class _InitializeScreenState extends State<InitializeScreen> {
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();

    Timer(const Duration(milliseconds: 3610), () {
      setState(() {
        _opacity = 0.0;
      });
    });

    Timer(const Duration(milliseconds: 4500), () {
      context.go('/splash'); // Use GoRouter navigation
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(milliseconds: 500),
            child: Image.asset(
              'assets/initialize.gif',
              width: 200,
              height: 200,
            ),
          ),
        ),
      ),
    );
  }
}
