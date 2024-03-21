import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../login_panels/start.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final auth = ref.watch(firebaseAuthProvider);

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
          ElevatedButton(
            onPressed: () async {
              // Tutaj wywołujesz provider odpowiedzialny za wylogowanie
              final SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('email', "");
              await prefs.setString('password', "");
              await prefs.setBool('remember_me', false);
              await auth.signOut();
              // Opcjonalnie, przekieruj użytkownika do strony logowania lub innej
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => StartPage()));
            },
            child: Text("Wyloguj"),
          ), // Tutaj możesz wykorzystać baseData
            ],
          ),
        ),
      ),
    );
  }
}
