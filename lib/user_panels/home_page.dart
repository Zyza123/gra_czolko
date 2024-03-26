import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_cached_image/firebase_cached_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gra_czolko/user_panels/screens_panel.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../login_panels/start.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  final combinedDataProvider = FutureProvider<List<dynamic>>((ref) async {
    final asyncData = await ref.watch(jsonDataProvider.future);
    final iconData = await ref.watch(pngIconsDataProvider64.future);
    // Przy założeniu, że oba zwracają listę, możesz je połączyć lub obsłużyć inaczej
    return [asyncData, iconData]; // Zwraca listę zawierającą obie odpowiedzi
  });

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
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Witaj, ${userData['username']}!',
                      style: TextStyle(
                          fontFamily: 'Jaapokki',
                          fontSize: 27,
                          color: Colors.white),
                    ),
                  );
                },
                loading: () => Container(),
                error: (error, stack) => Text('Wystąpił błąd: $error'),
              ),
              combinedDataAsyncValue.when(
                data: (combinedData) {
                  var genresData = combinedData[0];
                  // Filtruj i mapuj dane do wybranych gatunków
                  var selectedGenres1 = genresData.length > 4
                      ? genresData.sublist(0, 4)
                      : genresData;
                  var selectedGenres2 = genresData.length > 4
                      ? genresData.sublist(genresData.length - 5, genresData.length - 1)
                      : genresData;
                  var itemWidth = MediaQuery.of(context).size.width / 2 - 25;
                  var iconsData1 = [];
                  for (var itemGenre in selectedGenres1) {
                    for (var itemIcon in combinedData[1]) {
                      if (itemGenre['IconName64'] == itemIcon['Name']) {
                        iconsData1.add(itemIcon['Url']);
                      }
                    }
                  }
                  var iconsData2 = [];
                  for (var itemGenre in selectedGenres2) {
                    for (var itemIcon in combinedData[1]) {
                      if (itemGenre['IconName64'] == itemIcon['Name']) {
                        iconsData2.add(itemIcon['Url']);
                      }
                    }
                  }
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Polecane kategorie',
                            style: TextStyle(
                                fontFamily: 'Jaapokki',
                                fontSize: 22,
                                color: Colors.white),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                                List.generate(selectedGenres1.length, (index) {
                              // Tutaj możesz dostosować wyświetlanie poszczególnych elementów listy
                              return Container(
                                  width: itemWidth,
                                  height: 140,
                                  margin: EdgeInsets.only(
                                      right: index < selectedGenres1.length - 1
                                          ? 20
                                          : 0),
                                  // Dodaj margines tylko między elementami, nie po ostatnim elemencie
                                  padding: EdgeInsets.all(10),
                                  // Padding wewnątrz kontenera
                                  decoration: BoxDecoration(
                                    color: Color(int.parse(
                                        selectedGenres1[index]['color'])),
                                    // Kolor tła kontenera
                                    borderRadius: BorderRadius.circular(
                                        10), // Zaokrąglenie rogów
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Image(
                                        image: FirebaseImageProvider(
                                            FirebaseUrl(iconsData1[index])),
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.cover,
                                      ),
                                      Text(
                                        selectedGenres1[index]['Name'] ??
                                            'Brak nazwy',
                                        style: TextStyle(
                                            fontFamily: 'Jaapokki',
                                            color: Colors.white,
                                            fontSize: 17),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ));
                            }),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Najnowsze kategorie',
                            style: TextStyle(
                                fontFamily: 'Jaapokki',
                                fontSize: 22,
                                color: Colors.white),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                                List.generate(selectedGenres2.length, (index) {
                              // Tutaj możesz dostosować wyświetlanie poszczególnych elementów listy
                              return Container(
                                  width: itemWidth,
                                  height: 140,
                                  margin: EdgeInsets.only(
                                      right: index < selectedGenres2.length - 1
                                          ? 20
                                          : 0),
                                  // Dodaj margines tylko między elementami, nie po ostatnim elemencie
                                  padding: EdgeInsets.all(10),
                                  // Padding wewnątrz kontenera
                                  decoration: BoxDecoration(
                                    color: Color(int.parse(
                                        selectedGenres2[index]['color'])),
                                    // Kolor tła kontenera
                                    borderRadius: BorderRadius.circular(
                                        10), // Zaokrąglenie rogów
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Image(
                                        image: FirebaseImageProvider(
                                            FirebaseUrl(iconsData2[index])),
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.cover,
                                      ),
                                      Text(
                                        selectedGenres2[index]['Name'] ??
                                            'Brak nazwy',
                                        style: TextStyle(
                                            fontFamily: 'Jaapokki',
                                            color: Colors.white,
                                            fontSize: 17),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ));
                            }),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => Expanded(
                  child: Center(
                      child: LoadingAnimationWidget.dotsTriangle(
                          color: Colors.white, size: 60)),
                ),
                error: (error, stack) =>
                    Expanded(child: Text('Wystąpił błąd: $error')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
