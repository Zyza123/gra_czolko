import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import '../widgets/myElevatedButton.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool remember_me = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2E2E2E),
      body: SafeArea(
        child: Padding(
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
                        // Kolor znacznika
                        activeColor: Colors.white,
                        // Kolor tła przy zaznaczeniu
                        value: remember_me,
                        // Zmienna stanu przechowująca zaznaczenie
                        onChanged: (value) {
                          setState(() {
                            remember_me =
                                !remember_me; // Zmiana stanu zaznaczenia
                          });
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
                  onPressed: () {},
                  borderRadius: BorderRadius.circular(25),
                  child: Text(
                    'LECIMY!',
                    style: TextStyle(color: Colors.white, fontSize: 25),
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
