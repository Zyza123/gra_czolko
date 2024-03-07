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

  void _navigateWithScrollEffect(BuildContext context, Widget page) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Animacja wejścia dla strony Register
        var enterAnimation = Tween(begin: Offset(0.0, 1.0), end: Offset.zero).animate(animation);
        // Animacja wyjścia (przewijania do góry) dla obecnej strony
        var exitAnimation = Tween(begin: Offset.zero, end: Offset(0.0, -1.0)).animate(secondaryAnimation);

        return Stack(
          children: [
            SlideTransition(
              position: exitAnimation,
              child: widget, // Obecna strona
            ),
            SlideTransition(
              position: enterAnimation,
              child: child, // Nowa strona (Register)
            ),
          ],
        );
      },
      transitionDuration: Duration(milliseconds: 500),
      reverseTransitionDuration: Duration(milliseconds: 500),
    ));
  }

  @override
  void initState() {
    super.initState();
    _registerTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        _navigateWithScrollEffect(context,const Register());
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
            padding: const EdgeInsets.only(left: 20.0, right: 20, top: 50, bottom: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
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
                Spacer(), // Daje elastyczne wypełnienie, które zajmuje dostępną przestrzeń
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: MyElevatedButton(
                      width: double.infinity,
                      height: 60,
                      onPressed: () {
                        _navigateWithScrollEffect(context,const Login());
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Text('Zaloguj',style: TextStyle(color: Colors.white,fontSize: 25),),
                    )
                ),
                SizedBox(height: 25), // Odstęp między przyciskami
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
                SizedBox(height: 25),
                RichText(
                  text: TextSpan(
                      text: 'Nie posiadasz konta? ',
                      style: TextStyle(
                        fontFamily: 'JaapokkiEnhance',
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      children: [
                        TextSpan(
                          text: 'Zarejestruj się',
                          style: TextStyle(
                            fontFamily: 'JaapokkiEnhance',
                            fontSize: 18,
                            color: Color(0xffE76151),
                          ),
                          recognizer: _registerTapRecognizer,
                        )
                      ]
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}