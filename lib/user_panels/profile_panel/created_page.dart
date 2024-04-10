import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gra_czolko/user_panels/profile_panel/add_genre.dart';
import 'package:gra_czolko/user_panels/screens_panel.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:page_transition/page_transition.dart';

import '../../login_panels/start.dart';
import '../../widgets/myElevatedButton.dart';
import 'edit_genre.dart';

class CreatedPage extends ConsumerStatefulWidget {
  const CreatedPage({super.key});

  @override
  ConsumerState<CreatedPage> createState() => _CreatedPageState();
}

class _CreatedPageState extends ConsumerState<CreatedPage> {

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(uidProvider);
    var userDataGenres = ref.watch(jsonUserGenreProvider(uid!));

    void navigateToAddEditGenre(String fn) async {
      if(fn.isEmpty){
        final result = await Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.fade,
              child: const AddGenre(),
              isIos: true,
              duration: Duration(milliseconds: 500),
              reverseDuration: Duration(milliseconds: 500)),
        );
        if (result == true) {
          // Tutaj odśwież dane, np. wywołując provider ponownie
          userDataGenres = ref.refresh(jsonUserGenreProvider(uid));
        }
      }
      else{
        final result = await Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.fade,
              child: EditGenre(genreName: fn),
              isIos: true,
              duration: Duration(milliseconds: 500),
              reverseDuration: Duration(milliseconds: 500)),
        );
        if (result == true) {
          // Tutaj odśwież dane, np. wywołując provider ponownie
          userDataGenres = ref.refresh(jsonUserGenreProvider(uid));
        }
      }
    }

    return Scaffold(
      backgroundColor: Color(0xFF2E2E2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Text(
                  "Edytor gatunków",
                  style:TextStyle(
                      fontFamily: "Jaapokki",
                      fontSize: 25,
                      color: Colors.white),
                ),
              ),
              SizedBox(height: 15,),
              Text(
                "Nowe gatunki posiadają domyślną ikonę, działają na tej samej zasadzie"
                    " co reszta gatunków. Ponadto, możesz udostępnić komuś stworzony przez "
                    "siebie gatunek. ",
                style:TextStyle(
                    fontFamily: "Jaapokki",
                    fontSize: 19,
                    color: Colors.white),
              ),
              SizedBox(height: 25,),
              MyElevatedButton(
                width: double.infinity,
                height: 45,
                onPressed: () {
                  navigateToAddEditGenre("");
                },
                borderRadius: BorderRadius.circular(15),
                child: Text(
                  "Dodaj nowy gatunek",
                   style: TextStyle(
                   color: Colors.white,
                   fontSize: 19,
                   fontFamily: "Jaapokki",
                  ),
                ),
              ),
              SizedBox(height: 25,),
              Align(
                alignment: Alignment.topCenter,
                child: Text(
                  "Edytuj stworzone gatunki",
                  style:TextStyle(
                      fontFamily: "Jaapokki",
                      fontSize: 25,
                      color: Colors.white),
                ),
              ),
              SizedBox(height: 25,),
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
                            navigateToAddEditGenre(dataGenres[index]['Name']);
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
