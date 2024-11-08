import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_cached_image/firebase_cached_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gra_czolko/user_panels/play_panel/edit_genre_pick_page.dart';
import 'package:gra_czolko/user_panels/play_panel/genre_pick_page.dart';
import 'package:gra_czolko/user_panels/screens_panel.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../login_panels/start.dart';

class PlayPage extends ConsumerStatefulWidget {
  const PlayPage({super.key});

  @override
  ConsumerState<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends ConsumerState<PlayPage> {

  int editType = 0;

  @override
  void initState() {
    super.initState();
  }

  String dropdownValue = 'sortowanie a-z ';
  final combinedDataProvider = FutureProvider<List<dynamic>>((ref) async {
    final asyncData = await ref.watch(jsonDataProvider.future);
    final iconData = await ref.watch(pngIconsDataProvider64.future);

    // Przy założeniu, że oba zwracają listę, możesz je połączyć lub obsłużyć inaczej
    return [asyncData, iconData]; // Zwraca listę zawierającą obie odpowiedzi
  });

  void sortAZ(List<dynamic> genresData) {
    genresData.sort((a, b) => a['Name'].compareTo(b['Name']));

  }

  void sortZA(List<dynamic> genresData) {
    genresData.sort((a, b) => b['Name'].compareTo(a['Name']));

  }

  void sortIconsDataAZ(List<dynamic> iconsData) {
    iconsData.sort((a, b) => a['Name'].compareTo(b['Name']));
  }

  void sortIconsDataZA(List<dynamic> iconsData) {
    iconsData.sort((a, b) => b['Name'].compareTo(a['Name']));
  }

  @override
  Widget build(BuildContext context) {
    var combinedDataAsyncValue = ref.watch(combinedDataProvider);
    final uid = ref.watch(uidProvider);
    final userDataGenres = ref.watch(jsonUserGenreProvider(uid!));

    return Scaffold(
      backgroundColor: const Color(0xff2E2E2E),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(top: 25.0, left: 15, right: 15, bottom: 10),
          child: Column(
            children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 30),
                    child: Text(
                      'KATEGORIE',
                      style: TextStyle(
                          fontFamily: "Jaapokki",
                          fontSize: 28,
                          color: Colors.white),
                    ),
                  ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Sortowanie',
                    style: TextStyle(
                        fontFamily: "Jaapokki",
                        fontSize: 22,
                        color: Colors.white),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white,width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    child: DropdownButton<String>(
                      value: dropdownValue,
                      dropdownColor: Color(0xFF222222),
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: 20,
                      ),
                      underline: Container(),
                      style: const TextStyle(
                          color: Colors.white, fontFamily: "Jaapokki",fontSize: 20),
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValue = newValue!;
                          switch (dropdownValue) {
                            case 'sortowanie a-z ':
                              editType = 0;
                              break;
                            case 'sortowanie z-a ':
                              editType = 1;
                              break;
                            case 'własne ':
                              editType = 2;
                              break;
                            default:
                              break;
                          }
                        });
                      },
                      items: <String>[
                        'sortowanie a-z ',
                        'sortowanie z-a ',
                        'własne '
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child:Text(value, style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              if (editType == 0 || editType == 1) Expanded(
                child: combinedDataAsyncValue.when(
                  data: (combinedData) {
                    // Użyj GridView.builder
                    var genresData = combinedData[0];
                    var iconsData = combinedData[1];
                    double screenWidth = MediaQuery.of(context).size.width;
                    double desiredItemHeight = 140.0;
                    double itemWidth = (screenWidth - 50) /
                        2; // 30px to suma marginesów pomiędzy elementami i krawędziami ekranu
                    double childAspectRatio = itemWidth / desiredItemHeight;
                    if(editType == 0){
                      sortAZ(genresData);
                      sortIconsDataAZ(iconsData);
                    }
                    else if(editType == 1){
                      sortZA(genresData);
                      sortIconsDataZA(iconsData);
                    }
                    return Column(children: [
                      Expanded(
                          child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Dwa elementy w rzędzie
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemCount: genresData.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: (){
                              Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.fade,
                                    child: GenrePickPage(index: genresData[index]['Id'] ,),
                                    isIos: true,
                                    duration: Duration(milliseconds: 500),
                                    reverseDuration: Duration(milliseconds: 500)
                                ),
                              );
                            },
                            child: Container(
                              height: 140,
                              decoration: BoxDecoration(
                                color:
                                Color(int.parse(genresData[index]['color'])),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Image(
                                    image: FirebaseImageProvider(
                                        FirebaseUrl(iconsData[index]['Url'])),
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                  ),
                                  Text(
                                    genresData[index]['Name'] ?? 'Brak nazwy',
                                    style: TextStyle(
                                        fontFamily: 'Jaapokki',
                                        color: Colors.white,
                                        fontSize: 17),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                      ),
                    ]);
                  },
                  loading: () => Center(
                    child: Container(
                      height: 60,
                      width: 60,
                      child: LoadingAnimationWidget.dotsTriangle(
                          color: Colors.white, size: 60),
                    ),
                  ),
                  error: (error, stack) => Text('Wystąpił błąd: $error'),
                ),
              ),
              if (editType == 2)
                Expanded(
                  child: userDataGenres.when(
                    data: (dataGenres){
                      double screenWidth = MediaQuery.of(context).size.width;
                      double desiredItemHeight = 140.0;
                      double itemWidth = (screenWidth - 50) /
                          2; // 30px to suma marginesów pomiędzy elementami i krawędziami ekranu
                      double childAspectRatio = itemWidth / desiredItemHeight;
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Dwa elementy w rzędzie
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemCount: dataGenres.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: (){
                              Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.fade,
                                    child: EditGenrePickPage(genreName: dataGenres[index]['Name'] ,),
                                    isIos: true,
                                    duration: Duration(milliseconds: 500),
                                    reverseDuration: Duration(milliseconds: 500)
                                ),
                              );
                            },
                            child: Container(
                              height: 140,
                              decoration: BoxDecoration(
                                color: Color(dataGenres[index]['color']),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Image.asset(
                                    "assets/user_panels/user64.png",
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                  ),
                                  Text(
                                    dataGenres[index]['Name'] ?? 'Brak nazwy',
                                    style: TextStyle(
                                        fontFamily: 'Jaapokki',
                                        color: Colors.white,
                                        fontSize: 17),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => Center(
                      child: Container(
                        height: 60,
                        width: 60,
                        child: LoadingAnimationWidget.dotsTriangle(
                            color: Colors.white, size: 60),
                      ),
                    ),
                    error: (error, stack) => Text('Wystąpił błąd: $error'),),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
