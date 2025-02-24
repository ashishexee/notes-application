import 'package:flutter/material.dart';

// ignore: camel_case_types
class newnoteview extends StatefulWidget {
  const newnoteview({super.key});

  @override
  State<newnoteview> createState() => _newnoteviewState();
}

// ignore: camel_case_types
class _newnoteviewState extends State<newnoteview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'New Note',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Text('Enter your new note here'),
    );
  }
}
