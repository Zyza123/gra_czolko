import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_cached_image/firebase_cached_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gra_czolko/user_panels/screens_panel.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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

  final combinedDataProvider = FutureProvider<List<dynamic>>((ref) async {
    final asyncData = await ref.watch(jsonDataProvider.future);
    final iconData = await ref.watch(pngIconsDataProvider.future);
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
                  return Padding(
                    padding: EdgeInsets.only(bottom: 30),
                    child: Text(
                      'KATEGORIE',
                      style: TextStyle(
                          fontFamily: "Jaapokki",
                          fontSize: 26,
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
                    var iconsData = [];
                    for(var item in combinedData[1]){
                      if(item['name'].endsWith("64.png")) {
                        iconsData.add(item);
                      }
                    }
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
                      itemCount: genresData.length,
                      itemBuilder: (context, index) {
                        return Container(
                          height: 140,
                          decoration: BoxDecoration(
                            color: Color(int.parse(
                                genresData[index]['color'])),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Image(
                                image: FirebaseImageProvider(
                                    FirebaseUrl(iconsData[index]['url'])),
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
