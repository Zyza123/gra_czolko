import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../login_panels/start.dart';
import '../screens_panel.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {

  late FirebaseAuth auth;
  User? userCredential;

  @override
  void initState() {
    auth = ref.read(firebaseAuthProvider);
    userCredential = ref.read(firebaseAuthProvider).currentUser;
    super.initState();
  }

  Future<void> _resetRemembering() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me',false);
    await prefs.setString('email', "");
    await prefs.setString('password', "");
  }


  Future<void> changeUserEmail(String newEmail,BuildContext context) async {
    try {
      // Uzyskaj dostęp do obecnie zalogowanego użytkownika
      var user = auth.currentUser;

      // Zaktualizuj adres e-mail i wyślij e-mail weryfikacyjny
      await user?.verifyBeforeUpdateEmail(newEmail);

      // Opcjonalnie: Informuj użytkownika, że na nowy adres e-mail wysłano wiadomość z linkiem weryfikacyjnym
      _resetRemembering();
      if(context.mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Adres email nie został potwierdzony. Sprawdź swoją skrzynkę pocztową.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Obsługa wyjątków związanych z Firebase Authentication
      if(context.mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Wystąpił błąd przy zmianie adresu e-mail: ${e.code}')),
        );
      }
    } catch (e) {
      // Obsługa innych wyjątków
      if(context.mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wystąpił nieoczekiwany błąd')),
        );
      }
    }
  }

  void updateUsername(BuildContext context, String uid, String newUsername) async {
    try {
      // Uzyskaj dostęp do instancji FirebaseAuth
      var user = FirebaseAuth.instance.currentUser;

      // Zaktualizuj nazwę użytkownika w Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).collection('account').doc('account').update({'username': newUsername});

      // Invalidacja providera, aby odświeżyć dane

    } catch (e) {
      print("Wystąpił błąd podczas aktualizacji nazwy użytkownika: $e");
    }
  }

  void _showChangeEmailDialog(BuildContext context) {
    final TextEditingController _emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF2E2E2E),
          title: Text(
            'Zmień adres e-mail',
            style: TextStyle(
                fontFamily: "Jaapokki",
                color: Colors.white),
          ),
          content: TextField(
            controller: _emailController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Nowy adres e-mail",
              hintStyle: TextStyle(
                  fontFamily: "Jaapokki",
                  color: Colors.grey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.orange),
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: <Widget>[
            TextButton(
              child: Text(
                'Anuluj',
                style: TextStyle(
                    fontFamily: "Jaapokki",
                    fontSize: 18,
                    color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Zmień',
                style:TextStyle(
                    fontFamily: "Jaapokki",
                    fontSize: 18,
                    color: Colors.white),
              ),
              onPressed: () {
                if (_emailController.text.isNotEmpty) {
                  // Tutaj możesz dodać logikę zmiany adresu e-mail
                  changeUserEmail(_emailController.text,context).then((_) {
                    Navigator.of(context).pop();
                  }).catchError((error) {
                    print("Błąd zmiany adresu e-mail: $error");
                    // Można tu wyświetlić błąd w dialogu lub snackbarze
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> changeUsername(WidgetRef ref, User user, String newName) async {
    try {
      DocumentReference userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('account')
          .doc('account');

      await userDocRef.update({
        'username': newName,
      });

      print("Nazwa użytkownika została zaktualizowana.");
      // Unieważnienie providera, aby wymusić ponowne pobranie danych
      ref.invalidate(userDataProvider(user.uid));
    } catch (e) {
      print("Wystąpił błąd podczas aktualizacji nazwy użytkownika w Firestore: $e");
    }
  }

  void _showChangeUsernameDialog(BuildContext context) {
    final TextEditingController _usernameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF2E2E2E),
          title: Text(
            'Zmień nazwę użytkownika',
            style: TextStyle(
                fontFamily: "Jaapokki",
                color: Colors.white),
          ),
          content: TextField(
            controller: _usernameController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Nowa nazwa",
              hintStyle: TextStyle(
                  fontFamily: "Jaapokki",
                  color: Colors.grey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.orange),
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: <Widget>[
            TextButton(
              child: Text(
                'Anuluj',
                style: TextStyle(
                    fontFamily: "Jaapokki",
                    fontSize: 18,
                    color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Zmień',
                style:TextStyle(
                    fontFamily: "Jaapokki",
                    fontSize: 18,
                    color: Colors.white),
              ),
              onPressed: () {
                if (_usernameController.text.isNotEmpty) {
                  // Tutaj możesz dodać logikę zmiany adresu e-mail
                  changeUsername(ref, userCredential!,_usernameController.text).then((_) {
                    Navigator.of(context).pop();
                  }).catchError((error) {
                    print("Błąd zmiany adresu e-mail: $error");
                    // Można tu wyświetlić błąd w dialogu lub snackbarze
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(uidProvider);
    final userDataAsyncValue = ref.watch(userDataProvider(uid!));

    return Scaffold(
      backgroundColor: const Color(0xff2E2E2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: userDataAsyncValue.when(
              data: (userData) {
                // Wyświetl dane użytkownika
                return Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          'Dane konta',
                          style: TextStyle(
                              fontFamily: 'Jaapokki',
                              fontSize: 26,
                              color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          'Nazwa użytkownika',
                          style: TextStyle(
                              fontFamily: 'Jaapokki',
                              fontSize: 20,
                              color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color(0xFF1E1E1E),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              userData['username'],
                              style: TextStyle(
                                  fontFamily: 'Jaapokki',
                                  fontSize: 20,
                                  color: Colors.white),
                            ),
                            InkWell(
                              onTap: () {
                                  _showChangeUsernameDialog(context);
                },
                              child: Icon(
                                Icons.settings_sharp,
                                size: 20,
                                color: Colors.white,
                              ),
                            )

                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          'Adres e-mail',
                          style: TextStyle(
                              fontFamily: 'Jaapokki',
                              fontSize: 20,
                              color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color(0xFF1E1E1E),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              userData['email'],
                              style: TextStyle(
                                  fontFamily: 'Jaapokki',
                                  fontSize: 20,
                                  color: Colors.white),
                            ),
                            InkWell(
                              onTap: () => _showChangeEmailDialog(context),
                              child: Icon(
                                Icons.settings_sharp,
                                size: 20,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          'Motyw',
                          style: TextStyle(
                              fontFamily: 'Jaapokki',
                              fontSize: 20,
                              color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color(0xFF1E1E1E),
                        ),
                        child: Row(
                          children: [
                            Expanded( // Dodano widget Expanded
                              child: Text(
                                userData['theme'],
                                style: TextStyle(
                                    fontFamily: 'Jaapokki',
                                    fontSize: 20,
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => Container(),
              error: (error, stack) => Text('Wystąpił błąd: $error'),
            ),
          ),
        ),
      ),
    );
  }
}
