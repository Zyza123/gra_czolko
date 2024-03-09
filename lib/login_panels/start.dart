import 'package:page_transition/page_transition.dart';

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

class _StartPageState extends State<StartPage> {

  late TapGestureRecognizer _registerTapRecognizer;

  @override
  void initState() {
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
          child: Padding(
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
                      onPressed: () {
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
                      },
                      child: Text('Zaloguj',style: TextStyle(color: Colors.white,fontSize: 25),),
                    )
                ),
                SizedBox(height: 30), // Odstęp między przyciskami
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ElevatedButton(
                    onPressed: () {
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
        ),
      ),
    );
  }
}