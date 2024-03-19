import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../user_panels/screens_panel.dart';
import '/login_panels/register.dart';
import 'package:flutter/material.dart';
import 'package:gra_czolko/login_panels/register.dart';
import '../widgets/myElevatedButton.dart';
import '/login_panels/login.dart';
import 'package:flutter/gestures.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  _StartPageState createState() => _StartPageState();
}

const List<String> scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
];

GoogleSignIn _googleSignIn = GoogleSignIn(
  // Optional clientId
  // clientId: 'your-client_id.apps.googleusercontent.com',
  scopes: scopes,
);

class _StartPageState extends State<StartPage> {

  late TapGestureRecognizer _registerTapRecognizer;
  late CollectionReference users;
  late User? _user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool showSignAnimation = false;
  bool remember_me = false;


  @override
  void initState() {
    _loadRememberMe();
    users = FirebaseFirestore.instance.collection('users');
    _auth.authStateChanges().listen((event) {setState(() {
      _user = event;
    });});
    super.initState();
   _registerTapRecognizer = TapGestureRecognizer()
     ..onTap = () {
       Navigator.push(
         context,
         PageTransition(
             type: PageTransitionType.rightToLeft,
             child: const Register(),
             isIos: true,
             duration: Duration(milliseconds: 500),
             reverseDuration: Duration(milliseconds: 500)
         ),
       );
     };
  }

  Future<void> signInWithEmailPassword(String email, String password) async {
    setState(() {
      showSignAnimation = true; // Pokaż animację
    });
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;

      if (user != null && !user.emailVerified) {
        // Użytkownik nie potwierdził swojego adresu email
        if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Adres email nie został potwierdzony. Sprawdź swoją skrzynkę pocztową.')),
          );
        }
      } else {
        // Użytkownik zalogowany i potwierdzony
        if(mounted) {
          String? uid = user?.uid;
          if (uid != null) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => ScreensPanel(uid: user!.uid!)), // używamy operatora wykrzyknika, ponieważ już sprawdziliśmy, że uid nie jest null
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(
                'Nie znaleziono użytkownika z tym adresem email.')),);
        }
      } else if (e.code == 'wrong-password') {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nieprawidłowe hasło.')),
          );
        }
      }
    }
    finally {
      setState(() {
        showSignAnimation = false; // Ukryj animację po zakończeniu procesu
      });
    }
  }

  Future<void> _loadRememberMe() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      remember_me = prefs.getBool('remember_me') ?? false;
    });
  }

  Future<void> addDataToFirestore(String email) async {

    final DocumentReference userRef = users.doc(email);
    final DocumentSnapshot userDoc = await userRef.get();
    if (!userDoc.exists) {
      // Użytkownik nie istnieje, więc dodajemy jego dane
      try {
        await userRef.set({"exists": true});
        await userRef.collection('account').doc('account').set({
          "username": "User", // Tutaj możesz użyć rzeczywistej nazwy użytkownika, jeśli jest dostępna
          "email": email,
          "theme": "dark",
        });
        await userRef.collection('favorite').doc('favorite').set({});
        await userRef.collection('created').doc('created').set({});

        print("Dane zostały pomyślnie zapisane do Firestore.");
      } catch (e) {
        print("Wystąpił błąd podczas zapisywania danych do Firestore: $e");
      }
    } else {
      // Użytkownik już istnieje, nie trzeba dodawać danych
      print("Użytkownik już istnieje w Firestore.");
    }
  }

  Future<User?> signInWithGoogle() async {
    setState(() {
      showSignAnimation = true; // Pokaż animację
    });
    final GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount
            .authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(
            credential);
        final User? user = userCredential.user;

        // W tym punkcie, jeśli użytkownik nie jest null, oznacza to, że logowanie się powiodło.
        if (user != null) {
          print("Logowanie przez Google się powiodło: ${user.uid}");
          // Tutaj masz dostęp do emaila użytkownika
          String? email = user.email;
          if (email != null) {
            await addDataToFirestore(email);
            return user;
          }
        }
      }
    } catch (error) {
      print(error);
      return null;
    }
    finally {
      setState(() {
        showSignAnimation = false; // Ukryj animację po zakończeniu procesu
      });
    }
    return null;
  }

  @override
  void dispose() {
    _registerTapRecognizer.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2E2E2E),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Spacer(flex: 1,),
                    Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Image.asset('assets/login_panels/start_graph.png'), // Upewnij się, że ścieżka do obrazka jest prawidłowa
                        Padding(
                          padding: const EdgeInsets.only(top: 100.0),
                          child: Column(
                            children: [
                              Container(
                                height: 70,
                                child: RichText(
                                  text: TextSpan(
                                    text: 'CZÓŁKO',
                                    style: TextStyle(
                                      fontFamily: 'JaapokkiEnhance',
                                      fontSize: 64,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  text: 'Twój partner w imprezach',
                                  style: TextStyle(
                                    fontFamily: 'JaapokkiEnhance',
                                    fontSize: 22,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Spacer(flex: 3,), // Daje elastyczne wypełnienie, które zajmuje dostępną przestrzeń
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: MyElevatedButton(
                          width: double.infinity,
                          height: 60,
                          borderRadius: BorderRadius.circular(20),
                          onPressed: () async {
                            if(remember_me){
                              final SharedPreferences prefs = await SharedPreferences.getInstance();
                              String email = prefs.getString('email') ?? "";
                              String password = prefs.getString('password') ?? "";
                              signInWithEmailPassword(email, password);
                            }
                            else {
                              Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.rightToLeft,
                                    child: const Login(),
                                    isIos: true,
                                    duration: Duration(milliseconds: 500),
                                    reverseDuration: Duration(milliseconds: 500)
                                ),
                              );
                            }
                          },
                          child: Text('Zaloguj',style: TextStyle(color: Colors.white,fontSize: 25),),
                        )
                    ),
                    SizedBox(height: 30), // Odstęp między przyciskami
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          final User? user = await signInWithGoogle();
                          if (user != null && user.email != null) {
                            // Bezpośrednie przekazanie user.email do ScreensPanel, ponieważ już sprawdziliśmy, że nie jest null
                            String? uid = user?.uid;
                            if (uid != null) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => ScreensPanel(uid: user!.uid!)), // używamy operatora wykrzyknika, ponieważ już sprawdziliśmy, że uid nie jest null
                              );
                            }
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Zaloguj się z   ',style: TextStyle(fontFamily: "Jaapokki")),
                            Image.asset('assets/login_panels/google.png'),
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Color(0xff414141), // Kolor tekstu przycisku
                          textStyle: TextStyle(fontSize: 25),
                          minimumSize: Size(double.infinity, 60), // Maksymalna szerokość i wysokość 70
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25), // Tu ustawiasz zaokrąglenie rogów
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                          text: 'Nie posiadasz konta? ',
                          style: TextStyle(
                            fontFamily: 'JaapokkiEnhance',
                            fontSize: 21,
                            color: Colors.white,
                          ),
                          children: [
                            TextSpan(
                              text: 'Zarejestruj się',
                              style: TextStyle(
                                fontFamily: 'JaapokkiEnhance',
                                fontSize: 21,
                                color: Color(0xffE76151),
                              ),
                              recognizer: _registerTapRecognizer,
                            )
                          ]
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: showSignAnimation,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Color(0x80000000),
                  child: Center(
                    child: Lottie.asset('assets/animations/anim_login.json'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}