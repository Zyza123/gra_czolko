import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:gra_czolko/user_panels/play_panel/play_page.dart';
import 'package:gra_czolko/user_panels/profile_panel/profile_page.dart';
import '../login_panels/start.dart';
import 'home_page.dart';
import 'package:http/http.dart' as http;


class ScreensPanel extends ConsumerStatefulWidget {
  const ScreensPanel({super.key});


  @override
  ConsumerState<ScreensPanel> createState() => _ScreensPanelState();
}


final userDataProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, uid) async {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  DocumentReference<Object?> user = users.doc(uid).collection('account').doc('account');
  final docSnapshot = await user.get();

  if (docSnapshot.exists) {
    return docSnapshot.data() as Map<String, dynamic>;
  } else {
    // Zwracamy pusty obiekt, jeśli dokument nie istnieje.
    return {};
  }

});

final jsonUserGenreProvider = FutureProvider.family<List<dynamic>, String>((ref, uid) async {
  return await fetchJsonUserGenreFromFirebaseStorage(uid);
});


Future<List<dynamic>> fetchJsonUserGenreFromFirebaseStorage(String uid) async {
  final ref = FirebaseStorage.instance.ref("uzytkownicy/$uid");
  final ListResult result = await ref.listAll();
  List<Future<dynamic>> jsonFetches = result.items.map((item) async {
    var downloadURL = await item.getDownloadURL();
    var response = await http.get(Uri.parse(downloadURL));

    if (response.statusCode == 200) {
      // Deserializacja i zwrócenie danych JSON
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      print('Błąd podczas pobierania pliku: ${item.fullPath}');
      return null; // Możesz zwrócić null lub jakąś domyślną wartość w przypadku błędu
    }
  }).toList();

  // Filtruj null-e i czekaj na zakończenie wszystkich przyszłości
  var results = await Future.wait(jsonFetches);
  return results.where((element) => element != null).toList();
}


class _ScreensPanelState extends ConsumerState<ScreensPanel> {

  int currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomePage(),
      PlayPage(),
      ProfilePage(),
    ];
    final uid = ref.read(uidProvider);
    ref.read(jsonUserGenreProvider(uid!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff2E2E2E),
      body: SafeArea(
        child: IndexedStack(
          index: currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Container(

        color: const Color(0xff2E2E2E),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: GNav(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            color: Colors.grey.shade300,
            activeColor: Color(0xff2E2E2E),
            tabBackgroundColor: Colors.grey.shade300,
            duration: Duration(milliseconds: 300),
            gap: 8,
            iconSize: 23,
            padding: EdgeInsets.symmetric(vertical: 8,horizontal: 12),
            onTabChange: (index){
              setState(() {
                currentIndex = index;
              });
            },
            tabs: const [
              GButton(
                icon: Icons.home,
                text: 'Dom',
                textStyle: TextStyle(fontSize: 18,),
              ),
              GButton(
                icon: Icons.videogame_asset_sharp,
                text: 'Gra',
                textStyle: TextStyle(fontSize: 18,),
              ),
              GButton(
                icon: Icons.person_rounded,
                text: 'Profil',
                textStyle: TextStyle(fontSize: 18,),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
