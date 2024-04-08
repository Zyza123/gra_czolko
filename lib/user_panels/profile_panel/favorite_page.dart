import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_cached_image/firebase_cached_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../login_panels/start.dart';
import '../screens_panel.dart';

class FavoritePage extends ConsumerStatefulWidget {
  const FavoritePage({super.key});

  @override
  ConsumerState<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends ConsumerState<FavoritePage> {

  User? userCredential;
  late Future<List<int>> elements;

  final combinedDataProvider = FutureProvider<List<dynamic>>((ref) async {
    final asyncData = await ref.watch(jsonDataProvider.future);
    final iconData = await ref.watch(pngIconsDataProvider64.future);
    // Przy założeniu, że oba zwracają listę, możesz je połączyć lub obsłużyć inaczej
    return [asyncData, iconData]; // Zwraca listę zawierającą obie odpowiedzi
  });

  @override
  void initState() {
    super.initState();
    userCredential = ref.read(firebaseAuthProvider).currentUser;
    elements = fetchFavorites(userCredential!);
  }

  Future<List<int>> fetchFavorites(User user) async {
    try {
      DocumentReference favoritesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorite') // Upewnij się, że ścieżka jest poprawna
          .doc('favorite');

      DocumentSnapshot snapshot = await favoritesRef.get();

      List<int> favoriteIndexes = [];

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        // Zakładamy, że wartości są przechowywane jako numery (number) i reprezentują ulubione
        data.forEach((key, value) {
              favoriteIndexes.add(value);
        });
        return favoriteIndexes;
      } else {
        print("Dokument ulubionych nie istnieje.");
        return [];
      }
    } catch (e) {
      print("Wystąpił błąd podczas pobierania danych z Firestore: $e");
      return [];
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff2E2E2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10.0, left: 10, right: 10, top: 10),
          child: FutureBuilder<List<int>>(
            future: elements, // elements zawiera przyszłą listę ulubionych indeksów
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Container(
                    height: 60,
                    width: 60,
                    child: LoadingAnimationWidget.dotsTriangle(color: Colors.white, size: 60),
                  ),
                );
              } else if (snapshot.hasError) {
                return Text('Wystąpił błąd: ${snapshot.error}');
              } else if (snapshot.hasData) {
                final favoriteIndexes = snapshot.data!;
                // Teraz, mając listę ulubionych indeksów, możemy dalej pracować z combinedData
                return ref.watch(combinedDataProvider).when(
                  data: (combinedData) {
                    // Filtruj combinedData używając favoriteIndexes, aby wyświetlić tylko ulubione elementy
                    final favoriteData = combinedData[0].where((dataItem) => favoriteIndexes.contains(dataItem['Id'])).toList();
                    List<dynamic> iconsData = [];
                    for (dynamic item in favoriteData){
                      final selectedIconData = combinedData[1].firstWhere(
                            (iconPng) => iconPng['Name'] == item['IconName64'],
                        orElse: () => null,
                      );
                      iconsData.add(selectedIconData);
                    }
                    // Wyświetl dane ulubionych
                    return ListView.separated(
                      itemCount: favoriteData.length,
                      itemBuilder: (context, index) {
                        final dataItem = favoriteData[index];
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          decoration: BoxDecoration(
                            color: Color(int.parse(dataItem['color'])),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                          )),
                          child: Row(children: [
                            Image(
                              image: FirebaseImageProvider(
                                  FirebaseUrl(iconsData[index]['Url'])),
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(width: 25,),
                            Text(dataItem['Name'],
                              style: TextStyle(
                                  fontFamily: "Jaapokki",
                                  fontSize: 25,
                                  color: Colors.white),)
                          ],), // Przykładowe wyświetlenie nazwy
                          // Tu dodaj więcej szczegółów na temat wyświetlania każdego elementu
                        );
                      },
                      separatorBuilder: (context, index) => SizedBox(height: 20),
                    );
                  },
                  loading: () => Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Text('Wystąpił błąd: $error'),
                );
              } else {
                return Text("Brak danych");
              }
            },
          ),
        ),
      ),
    );
  }

}
