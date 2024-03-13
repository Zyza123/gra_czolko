import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import '../user_panels/home_panel.dart';
import '../widgets/myElevatedButton.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool remember_me = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool showSignAnimation = false;

  Future<void> signInWithEmailPassword() async {
    String email = emailController.text;
    String password = passwordController.text;
    setState(() {
      showSignAnimation = true; // Pokaż animację
    });
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
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
          if(remember_me){
            final SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('email', email);
            await prefs.setString('password', password);
          }
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePanel()), // Przejście do Home
          );
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2E2E2E),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 50,
                    ),
                    Container(
                      height: 70,
                      child: GradientText(
                        'CZÓŁKO',
                        style: TextStyle(
                          fontFamily: 'JaapokkiEnhance',
                          fontSize: 64,
                        ),
                        colors: [Color(0xffD613E7), Color(0xffED8022)],
                      ),
                    ),
                    SizedBox(
                      height: 90,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Email',
                          style: TextStyle(
                              fontFamily: 'Jaapokki',
                              fontSize: 30,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Container(
                            height: 60,
                            child: TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                                fillColor: Color(0xff2E2E2E),
                                filled: true,
                                contentPadding: EdgeInsets.only(
                                    left: 75, right: 10, top: 21, bottom: 21),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                      width: 2, color: Color(0xffE76151)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  // Gdy pole tekstowe jest dostępne, ale nie ma focusa
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                      width: 2, color: Color(0xffE76151)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  // Gdy pole tekstowe jest zaznaczone (ma focus)
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                      width: 2, color: Color(0xffE76151)),
                                ),
                              ),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: 'Jaapokki',
                                  letterSpacing: 2),
                            ),
                          ),
                        ),
                        Container(
                          width: 75,
                          height: 75,
                          decoration: BoxDecoration(
                            color: Color(0xff2E2E2E),
                            border: Border.all(color: Color(0xffE76151), width: 2),
                            borderRadius: BorderRadius.all(Radius.circular(90)),
                          ),
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 35,
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 50),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Password',
                          style: TextStyle(
                              fontFamily: 'Jaapokki',
                              fontSize: 30,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Container(
                            height: 60,
                            child: TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                fillColor: Color(0xff2E2E2E),
                                filled: true,
                                contentPadding: EdgeInsets.only(
                                    left: 75, right: 10, top: 21, bottom: 21),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                      width: 2, color: Color(0xffE76151)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  // Gdy pole tekstowe jest dostępne, ale nie ma focusa
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                      width: 2, color: Color(0xffE76151)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  // Gdy pole tekstowe jest zaznaczone (ma focus)
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                      width: 2, color: Color(0xffE76151)),
                                ),
                              ),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: 'Jaapokki',
                                  letterSpacing: 2),
                            ),
                          ),
                        ),
                        Container(
                          width: 75,
                          height: 75,
                          decoration: BoxDecoration(
                            color: Color(0xff2E2E2E),
                            border: Border.all(color: Color(0xffE76151), width: 2),
                            borderRadius: BorderRadius.all(Radius.circular(90)),
                          ),
                          child: Icon(
                            Icons.lock,
                            color: Colors.white,
                            size: 35,
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        'Nie pamiętam hasła',
                        style: TextStyle(
                            fontFamily: 'Jaapokki',
                            fontSize: 21,
                            color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 50),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // Centruje elementy w pionie
                      children: [
                        Theme(
                          data: Theme.of(context).copyWith(
                            unselectedWidgetColor: Colors.white,
                          ),
                          child: Checkbox(
                            checkColor: Color(0xFF5E0087),
                            activeColor: Colors.white,
                            value: remember_me,
                            onChanged: (bool? value) async {
                              setState(() {
                                remember_me = value!;
                              });
                              final SharedPreferences prefs = await SharedPreferences.getInstance();
                              await prefs.setBool('remember_me', remember_me);
                            },
                          ),
                        ),
                        SizedBox(width: 10), // Odstęp między checkboxem a tekstem
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(
                            'Zapamiętaj mnie!',
                            style: TextStyle(
                              fontFamily: 'Jaapokki',
                              fontSize: 21,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    MyElevatedButton(
                      width: double.infinity,
                      height: 60,
                      onPressed: signInWithEmailPassword,
                      borderRadius: BorderRadius.circular(25),
                      child: Text(
                        'LECIMY!',
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
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
    );
  }
}
