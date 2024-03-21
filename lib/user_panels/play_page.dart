import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PlayPage extends StatefulWidget {
  const PlayPage({super.key});

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff2E2E2E),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "123",
                style: TextStyle(color: Colors.white),
              ),
              Text(
                "456",
                style: TextStyle(color: Colors.white),
              ),
              // Tutaj możesz wykorzystać baseData
            ],
          ),
        ),
      ),
    );
  }
}
