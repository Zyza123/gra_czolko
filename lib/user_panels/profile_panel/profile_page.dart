import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gra_czolko/user_panels/profile_panel/account_page.dart';
import 'package:gra_czolko/user_panels/profile_panel/favorite_page.dart';
import 'package:gra_czolko/user_panels/screens_panel.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import '../../login_panels/start.dart';
import 'created_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {

  late FirebaseAuth auth;

  @override
  void initState() {
    auth = ref.read(firebaseAuthProvider);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(uidProvider);
    final userDataAsyncValue = ref.watch(userDataProvider(uid!));

    return Scaffold(
      backgroundColor: const Color(0xff2E2E2E),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(bottom: 10.0, left: 20, right: 20, top: 20),
          child: userDataAsyncValue.when(
              data: (userData) {
                return Column(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 90,
                                width: 90,
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(90),
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(90),
                                  child: Image.asset(
                                    "assets/user_panels/profile_pic.jpg",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GradientText(
                                    'KONTO CZÓŁKO',
                                    style: TextStyle(
                                      fontFamily: 'JaapokkiEnhance',
                                      fontSize: 18,
                                    ),
                                    colors: [
                                      Color(0xffD613E7),
                                      Color(0xffED8022)
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    userData['username'],
                                    style: TextStyle(
                                        fontFamily: 'Jaapokki',
                                        fontSize: 24,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 25,),
                          InkWell(
                            onTap: (){
                              Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.fade,
                                    child: const AccountPage(),
                                    isIos: true,
                                    duration: Duration(milliseconds: 500),
                                    reverseDuration:
                                    Duration(milliseconds: 500)),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12,vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Color(0xFF1E1E1E),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Dane konta",
                                    style: TextStyle(
                                        fontFamily: 'Jaapokki',
                                        fontSize: 17,
                                        color: Colors.white),
                                  ),
                                  Icon(Icons.arrow_forward_ios_outlined,
                                    size: 18, color: Colors.white,)
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20,),
                          InkWell(
                            onTap: (){
                              Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.fade,
                                    child: const FavoritePage(),
                                    isIos: true,
                                    duration: Duration(milliseconds: 500),
                                    reverseDuration:
                                    Duration(milliseconds: 500)),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12,vertical: 10),
                              decoration: BoxDecoration(
                               borderRadius: BorderRadius.circular(5),
                                color: Color(0xFF1E1E1E),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Ulubione kategorie",
                                    style: TextStyle(
                                        fontFamily: 'Jaapokki',
                                        fontSize: 17,
                                        color: Colors.white),
                                  ),
                                  Icon(Icons.arrow_forward_ios_outlined,
                                    size: 18, color: Colors.white,)
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20,),
                          InkWell(
                            onTap: (){
                              Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.fade,
                                    child: const CreatedPage(),
                                    isIos: true,
                                    duration: Duration(milliseconds: 500),
                                    reverseDuration:
                                    Duration(milliseconds: 500)),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12,vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Color(0xFF1E1E1E),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Stworzone przez Ciebie",
                                    style: TextStyle(
                                        fontFamily: 'Jaapokki',
                                        fontSize: 17,
                                        color: Colors.white),
                                  ),
                                  Icon(Icons.arrow_forward_ios_outlined,
                                    size: 18, color: Colors.white,)
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20,),
                          InkWell(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12,vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Color(0xFF1E1E1E),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "O nas",
                                    style: TextStyle(
                                        fontFamily: 'Jaapokki',
                                        fontSize: 17,
                                        color: Colors.white),
                                  ),
                                  Icon(Icons.arrow_forward_ios_outlined,
                                    size: 18, color: Colors.white,)
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20,),
                          InkWell(
                            onTap: () async {
                              // Tutaj wywołujesz provider odpowiedzialny za wylogowanie
                              final SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                              await prefs.setString('email', "");
                              await prefs.setString('password', "");
                              await prefs.setBool('remember_me', false);
                              await auth.signOut();
                              // Opcjonalnie, przekieruj użytkownika do strony logowania lub innej
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (_) => StartPage()));
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12,vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Color(0xFF1E1E1E),
                              ),
                              child: Row(

                                children: [
                                  Text(
                                    "Wyloguj się",
                                    style: TextStyle(
                                        fontFamily: 'Jaapokki',
                                        fontSize: 17,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        "Wersja 1.0.0",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                );
              },
              loading: () => Center(
                    child: Container(
                      height: 22,
                      width: 22,
                      child: LoadingAnimationWidget.dotsTriangle(
                          color: Colors.white, size: 22),
                    ),
                  ),
              error: (error, stack) => Text('Wystąpił błąd: $error')),
        ),
      ),
    );
  }
}
