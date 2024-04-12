import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../../login_panels/start.dart';
import '../screens_panel.dart';
import 'game_page.dart';

class EditGenrePickPage extends ConsumerStatefulWidget {
  final String genreName;
  const EditGenrePickPage({required this.genreName, super.key});

  @override
  ConsumerState<EditGenrePickPage> createState() => _EditGenrePickPageState();
}

class _EditGenrePickPageState extends ConsumerState<EditGenrePickPage> {
  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(uidProvider);
    var userDataGenres = ref.watch(jsonUserGenreProvider(uid!));

    return Scaffold(
      backgroundColor: const Color(0xff2E2E2E),
      body: SafeArea(
        child: userDataGenres.when(
          data: (editGenreData) {
            final selectedGenreData = editGenreData.firstWhere(
                  (genre) => genre['Name'] == widget.genreName,
              orElse: () => null, // Jeśli nie znajdzie odpowiedniego Id
            );
            final genreKeys = selectedGenreData["Elements"];
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                      height: 230,
                      width: MediaQuery.of(context).size.width * 1.0,
                      decoration: BoxDecoration(
                        color: Color(selectedGenreData['color']),
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(90),
                            bottomRight: Radius.circular(90)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Image.asset(
                            "assets/user_panels/user128.png",
                            width: 128,
                            height: 128,
                            fit: BoxFit.cover,
                          ),
                          Text(
                            selectedGenreData['Name'],
                            style: TextStyle(
                                fontFamily: "Jaapokki",
                                fontSize: 32,
                                color: Colors.white),
                          ),
                        ],
                      )),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Text(
                      selectedGenreData["description"],
                      style: TextStyle(
                          fontFamily: "Jaapokki",
                          fontSize: 20,
                          color: Colors.white),
                    ),
                  ),
                  Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: Row(
                        children: [
                          GradientText(
                            'Baza haseł:   ',
                            style: TextStyle(fontSize: 20),
                            colors: [
                              Color(0xffD613E7),
                              Color(0xffED8022)
                            ], // Biała czzionka dla przycisku
                          ),
                          Text(
                            genreKeys.length.toString(),
                            style: TextStyle(
                                fontFamily: "Jaapokki",
                                fontSize: 20,
                                color: Colors.white),
                          ),
                        ],
                      )),
                  Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: Row(
                        children: [
                          GradientText(
                            'Trudność:   ',
                            style: TextStyle(fontSize: 20),
                            colors: [
                              Color(0xffD613E7),
                              Color(0xffED8022)
                            ], // Biała czzionka dla przycisku
                          ),
                          Text(
                            selectedGenreData["difficulty"],
                            style: TextStyle(
                                fontFamily: "Jaapokki",
                                fontSize: 20,
                                color: Colors.white),
                          ),
                        ],
                      )),
                  Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: Row(
                        children: [
                          GradientText(
                            'Jak grać?   ',
                            style: TextStyle(fontSize: 20,fontFamily: "Jaapokki",),
                            colors: [
                              Color(0xffD613E7),
                              Color(0xffED8022)
                            ], // Biała czzionka dla przycisku
                          ),
                          GestureDetector(
                            onTap: (){
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: Color(0xFF2E2E2E),
                                      title: Text(
                                        'Zasady gry',
                                        style: TextStyle(
                                            fontFamily: "Jaapokki",
                                            color: Colors.white
                                        ),
                                      ),
                                      content: SingleChildScrollView(
                                        child: ListBody(
                                          children: <Widget>[
                                            Text(
                                              'Gra polega na odgadywaniu haseł na czas. Oto kilka zasad:',
                                              style: TextStyle(color: Colors.white,fontSize: 17),
                                            ),
                                            SizedBox(height: 10),
                                            Row(
                                              children: [
                                                GradientText(
                                                  '1. ',
                                                  style: TextStyle(fontSize: 22, fontFamily: "Jaapokki"),
                                                  colors: [Color(0xffD613E7), Color(0xffED8022)],
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    'Jedna gra składa się z 8 rund, czyli 8 haseł.',
                                                    style: TextStyle(color: Colors.white,fontSize: 17),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10,),
                                            Row(
                                              children: [
                                                GradientText(
                                                  '2. ',
                                                  style: TextStyle(fontSize: 22, fontFamily: "Jaapokki"),
                                                  colors: [Color(0xffD613E7), Color(0xffED8022)],
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    'Czas na odpowiedź zależy od wybranej kategorii gry.',
                                                    style: TextStyle(color: Colors.white,fontSize: 17),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10,),
                                            Row(
                                              children: [
                                                GradientText(
                                                  '3. ',
                                                  style: TextStyle(fontSize: 22, fontFamily: "Jaapokki"),
                                                  colors: [Color(0xffD613E7), Color(0xffED8022)],
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    'Za każdą poprawną odpowiedź kliknij raz, za każdą błędną - dwa razy.',
                                                    style: TextStyle(color: Colors.white,fontSize: 17),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10,),
                                            Row(
                                              children: [
                                                GradientText(
                                                  '4. ',
                                                  style: TextStyle(fontSize: 21, fontFamily: "Jaapokki"),
                                                  colors: [Color(0xffD613E7), Color(0xffED8022)],
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    'Na zakończenie gry wyświetlone zostanie podsumowanie wyników.',
                                                    style: TextStyle(color: Colors.white,fontSize: 18),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      actionsAlignment: MainAxisAlignment.center,
                                      actions: <Widget>[
                                        TextButton(
                                          child: GradientText(
                                            'Super!',
                                            style: TextStyle(fontSize: 20, fontFamily: "Jaapokki"),
                                            colors: [
                                              Color(0xffD613E7),
                                              Color(0xffED8022)
                                            ],
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  }
                              );
                            },
                            child: GradientText(
                              'pomocnik',
                              style: TextStyle(fontSize: 20,fontFamily: "Jaapokki",),
                              colors: [
                                Color(0xffD613E7),
                                Color(0xffED8022)
                              ], // Biała czzionka dla przycisku
                            ),
                          )
                        ],
                      )),
                  Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.fade,
                                        child: PlayPage(type: 0,bg: 'assets/user_panels/bg0.jpg',genreKeys: genreKeys,),
                                        isIos: true,
                                        duration: Duration(milliseconds: 500),
                                        reverseDuration:
                                        Duration(milliseconds: 500)),
                                  );
                                },
                                child: Container(
                                  height: 125,
                                  color: Color(0xFFE47CED),
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Image.asset(
                                        'assets/user_panels/story.png',
                                        width: 64,
                                        height: 64,
                                      ),
                                      Text(
                                        "opowiadanie",
                                        style: TextStyle(
                                            fontFamily: "Jaapokki",
                                            fontSize: 21,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                          Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.fade,
                                        child: PlayPage(type: 1, bg: 'assets/user_panels/bg1.jpg', genreKeys: genreKeys),
                                        isIos: true,
                                        duration: Duration(milliseconds: 500),
                                        reverseDuration:
                                        Duration(milliseconds: 500)),
                                  );
                                },
                                child: Container(
                                  height: 125,
                                  color: Color(0xFFE04392),
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Image.asset(
                                        'assets/user_panels/show.png',
                                        width: 64,
                                        height: 64,
                                      ),
                                      Text(
                                        "Pokazywanie",
                                        style: TextStyle(
                                            fontFamily: "Jaapokki",
                                            fontSize: 21,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                        ],
                      )),
                  Row(
                    children: [
                      Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.fade,
                                    child: PlayPage(type: 2, bg: 'assets/user_panels/bg2.jpg', genreKeys: genreKeys),
                                    isIos: true,
                                    duration: Duration(milliseconds: 500),
                                    reverseDuration: Duration(milliseconds: 500)),
                              );
                            },
                            child: Container(
                              height: 125,
                              color: Color(0xFFE7615B),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Image.asset(
                                    'assets/user_panels/draw.png',
                                    width: 64,
                                    height: 64,
                                  ),
                                  Text(
                                    "Rysowanie",
                                    style: TextStyle(
                                        fontFamily: "Jaapokki",
                                        fontSize: 21,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          )),
                      Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.fade,
                                    child: PlayPage(type: 3, bg: 'assets/user_panels/bg3.jpg', genreKeys: genreKeys),
                                    isIos: true,
                                    duration: Duration(milliseconds: 500),
                                    reverseDuration: Duration(milliseconds: 500)),
                              );
                            },
                            child: Container(
                              height: 125,
                              color: Color(0xFFED7F25),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Image.asset(
                                    'assets/user_panels/ear.png',
                                    width: 64,
                                    height: 64,
                                  ),
                                  Text(
                                    "głuchy telefon",
                                    style: TextStyle(
                                        fontFamily: "Jaapokki",
                                        fontSize: 21,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ],
                  )
                ],
              ),
            );
          },
          loading: () => Center(
            child: SizedBox(
              height: 60,
              width: 60,
              child: LoadingAnimationWidget.dotsTriangle(
                  color: Colors.white, size: 60),
            ),
          ),
          error: (error, stack) => Text('Wystąpił błąd: $error'),
        ),
      ),
    );
  }
}
