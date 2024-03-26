import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_cached_image/firebase_cached_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gra_czolko/user_panels/screens_panel.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../login_panels/start.dart';

class PlayPage extends ConsumerStatefulWidget {
  const PlayPage({super.key});

  @override
  ConsumerState<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends ConsumerState<PlayPage> {
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
    final uid = ref.watch(uidProvider);
    final userDataAsyncValue = ref.watch(userDataProvider(uid!));
    final combinedDataAsyncValue = ref.watch(combinedDataProvider);

    return Scaffold(
      backgroundColor: const Color(0xff2E2E2E),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(top: 25.0, left: 15, right: 15, bottom: 10),
          child: Column(
            children: [
              userDataAsyncValue.when(
                data: (userData) {
                  // Wyświetl dane użytkownika
                  return Padding(
                    padding: EdgeInsets.only(bottom: 30),
                    child: Text(
                      'KATEGORIE',
                      style: TextStyle(
                          fontFamily: "Jaapokki",
                          fontSize: 28,
                          color: Colors.white),
                    ),
                  );
                },
                loading: () => Container(),
                error: (error, stack) => Text('Wystąpił błąd: $error'),
              ),
              Expanded(
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
                    return Column(children: [
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
                                        sortAZ(genresData);
                                        sortIconsDataAZ(iconsData);
                                      break;
                                    case 'sortowanie z-a ':
                                        sortZA(genresData);
                                        sortIconsDataZA(iconsData);
                                      break;
                                    default:
                                      break;
                                  }
                                });
                              },
                              items: <String>[
                                'sortowanie a-z ',
                                'sortowanie z-a '
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
                          return Container(
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
                          );
                        },
                      ))
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
            ],
          ),
        ),
      ),
    );
  }
}
