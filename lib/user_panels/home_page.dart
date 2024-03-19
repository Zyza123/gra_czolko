import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final String uid;

  const HomePage({super.key, required this.uid});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late CollectionReference users;
  late DocumentReference<Object?> user;

  late CollectionReference base;
  late DocumentReference<Object?> test;

  late Future<List<Map<String, dynamic>>> combinedData;

  Future<Map<String, dynamic>> fetchAccountData() async {
    try {
      final snapshot = await user.get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      } else {
        print("Document does not exist");
        return {}; // Zwróć pustą mapę w przypadku braku danych
      }
    } catch (error) {
      print("Something went wrong: $error");
      return {}; // Zwróć pustą mapę w przypadku błędu
    }
  }

  Future<Map<String, dynamic>> fetchBaseData() async {
    try {
      final snapshot = await test.get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      } else {
        print("Document does not exist");
        return {}; // Zwróć pustą mapę w przypadku braku danych
      }
    } catch (error) {
      print("Something went wrong: $error");
      return {}; // Zwróć pustą mapę w przypadku błędu
    }
  }

  @override
  void initState() {
    // dane dla konta
    users = FirebaseFirestore.instance.collection('users');
    String path = widget.uid;
    user = users.doc(path).collection('account').doc('account');

    // dane bazy
    base = FirebaseFirestore.instance.collection('baza');
    test = base.doc("test");

    combinedData = Future.wait([fetchAccountData(), fetchBaseData()]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: combinedData,
      builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text("Something went wrong: ${snapshot.error}");
        } else {
          var userData = snapshot.data?[0]; // Dane z pierwszego zapytania
          var baseData = snapshot.data?[1]; // Dane z drugiego zapytania

          String userName = userData?['username'] ?? "No Username";
          // Przykład wykorzystania baseData
          String baseTest = baseData?['testowe'] ?? "Nie git";

          return Scaffold(
            backgroundColor: const Color(0xff2E2E2E),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(userName,style: TextStyle(color: Colors.white),),
                    Text(baseTest,style: TextStyle(color: Colors.white),),
                    // Tutaj możesz wykorzystać baseData
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

}
