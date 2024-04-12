import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_cached_image/firebase_cached_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../../login_panels/start.dart';
import '../../widgets/myElevatedButton.dart';
import 'game_page.dart';

class GenrePickPage extends ConsumerStatefulWidget {
  final int index; // Dodanie zmiennej index

  const GenrePickPage({
    super.key,
    required this.index, // Wymaganie przekazania parametru index
  });

  @override
  ConsumerState<GenrePickPage> createState() => _GenrePickPageState();
}

class _GenrePickPageState extends ConsumerState<GenrePickPage> {

  bool favorite = false;
  User? userCredential;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    initializeFavorites();
  }

  Future<void> initializeFavorites() async {
    userCredential = ref.read(firebaseAuthProvider).currentUser;
    if (userCredential != null) {
      favorite = await checkIfFavorite(userCredential!);
      setState(() {});
    }
  }


  final combinedDataProvider = FutureProvider<List<dynamic>>((ref) async {
    final asyncData = await ref.watch(jsonDataProvider.future);
    final iconData = await ref.watch(pngIconsDataProvider128.future);
    return [asyncData, iconData]; // Zwraca listę zawierającą obie odpowiedzi
  });

  Future<void> addGenreToFavorite(User user) async {
    try {
      DocumentReference favorites = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorite')
          .doc('favorite');

      // Tworzymy nazwę pola, które chcemy dodać lub zaktualizować
      String fieldName = widget.index.toString(); // lub inny sposób formułowania nazwy pola

      // Ustawiamy wartość pola na widget.index, używając merge: true, aby nie nadpisywać innych pól
      await favorites.set({ fieldName: widget.index }, SetOptions(merge: true));

      print("Dodano gatunek do ulubionych.");
    } catch (e) {
      print("Wystąpił błąd podczas zapisywania danych do Firestore: $e");
    }
  }

  Future<void> removeGenreFromFavorite(User user) async {
    try {
      DocumentReference favorites = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorite')
          .doc('favorite');

      // Tworzymy nazwę pola, które chcemy usunąć
      String fieldName = widget.index.toString(); // lub inny sposób formułowania nazwy pola

      // Używamy update z FieldValue.delete() aby usunąć pole
      await favorites.update({ fieldName: FieldValue.delete() });

      print("Usunięto gatunek z ulubionych.");
    } catch (e) {
      print("Wystąpił błąd podczas usuwania danych z Firestore: $e");
    }
  }

  Future<void> toggleFavoriteStatus() async {
    if (userCredential != null) {
      if (favorite) {
        await removeGenreFromFavorite(userCredential!);
      } else {
        await addGenreToFavorite(userCredential!);
      }
      // Po wykonaniu operacji, sprawdzamy na nowo stan ulubionych
      // i aktualizujemy interfejs użytkownika.
      bool newFavoriteStatus = await checkIfFavorite(userCredential!);
      setState(() {
        favorite = newFavoriteStatus;
      });
    }
  }

  Future<bool> checkIfFavorite(User user) async {
    try {
      DocumentReference favorites = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorite')
          .doc('favorite');

      DocumentSnapshot snapshot = await favorites.get();

      if (snapshot.exists) {
        // Uzyskujemy mapę danych z dokumentu
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        // Zakładając, że pola są nazwane jako '1', '2', '3', etc.
        String fieldName = widget.index.toString();

        // Sprawdzamy, czy mapa danych zawiera klucz o nazwie fieldName
        if (data.containsKey(fieldName)) {
          // Jeśli klucz istnieje, to zakładamy, że index jest ulubiony
          print("Element znajduje się w ulubionych.");
          return true;
        } else {
          // Jeśli klucz nie istnieje, to index nie jest ulubiony
          print("Element nie znajduje się w ulubionych.");
          return false;
        }
      } else {
        print("Dokument nie istnieje.");
        return false;
      }
    } catch (e) {
      print("Wystąpił błąd podczas pobierania danych z Firestore: $e");
      return false;
    }
  }



  @override
  Widget build(BuildContext context) {
    final combinedDataAsyncValue = ref.watch(combinedDataProvider);

    return Scaffold(
      backgroundColor: const Color(0xff2E2E2E),
      body: SafeArea(
        child: combinedDataAsyncValue.when(
          data: (combinedData) {
            final selectedGenreData = combinedData[0].firstWhere(
              (genre) => genre['Id'] == widget.index,
              orElse: () => null, // Jeśli nie znajdzie odpowiedniego Id
            );
            final genreKeys = selectedGenreData["Elements"];
            final selectedIconData = combinedData[1].firstWhere(
              (iconPng) => iconPng['Name'] == selectedGenreData['IconName128'],
              orElse: () => null,
            );
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                      height: 230,
                      width: MediaQuery.of(context).size.width * 1.0,
                      decoration: BoxDecoration(
                        color: Color(int.parse(selectedGenreData['color'])),
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(90),
                            bottomRight: Radius.circular(90)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Image(
                            image: FirebaseImageProvider(
                                FirebaseUrl(selectedIconData['Url'])),
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
                      selectedGenreData['description'],
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
                            selectedGenreData['difficulty'],
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
                      padding:
                      EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: MyElevatedButton(
                        width: double.infinity,
                        height: 45,
                        onPressed: () {
                          toggleFavoriteStatus();
                        },
                        borderRadius: BorderRadius.circular(15),
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 300), // Czas trwania animacji
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            // Tutaj można zdefiniować rodzaj animacji, np. fade transition
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: Text(
                            favorite ? "Już w ulubionych!" : "Dodaj do ulubionych!",
                            key: ValueKey<bool>(favorite), // Klucz jest potrzebny, aby AnimatedSwitcher wiedział, kiedy zmienić dziecko
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontFamily: "Jaapokki",
                            ),
                          ),
                        ),
                      ),

                  ),
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
