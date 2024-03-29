import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlayPage extends StatefulWidget {
  final int type;
  final String bg;
  final dynamic genreKeys;

  const PlayPage(
      {super.key,
      required this.type,
      required this.bg,
      required this.genreKeys});

  @override
  State<PlayPage> createState() => _PlayPageState();
}

enum Action {
  counting_start,
  counting_between,
  guessing,
  end,
  right,
  wrong,
}

class _PlayPageState extends State<PlayPage> {
  int start_seconds = 5;
  int between_seconds = 2;
  Timer? _timer;
  late Action action;
  late int typeTime;
  late List<String> chosenWords;
  int question = 0;

  void setTime() {
    if (widget.type == 0 || widget.type == 1) {
      typeTime = 10;
    } else if (widget.type == 2) {
      typeTime = 120;
    } else {
      typeTime = 180;
    }
  }

  Future<void> startTimer() async {
    Completer<void> completer = Completer(); // Utworzenie Completera
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (start_seconds > 0) {
        setState(() {
          start_seconds--;
        });
      } else {
        _timer?.cancel();
        if (!completer.isCompleted) {
          completer
              .complete(); // Zakończenie Future, gdy timer dojdzie do końca
        }
      }
    });
    return completer
        .future; // Zwrócenie Future, który zakończy się po zakończeniu timera
  }

  Future<void> normalTimer() async {
    Completer<void> completer = Completer(); // Utworzenie Completera
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (typeTime > 0) {
        setState(() {
          typeTime--;
        });
      } else {
        _timer?.cancel();
        if (!completer.isCompleted) {
          completer
              .complete(); // Zakończenie Future, gdy timer dojdzie do końca
          setState(() {
            action = Action.wrong;
            betweenQuestions();
          });
        }
      }
    });
    return completer
        .future; // Zwrócenie Future, który zakończy się po zakończeniu timera
  }

  Future<void> betweenTimer() async {
    Completer<void> completer = Completer(); // Utworzenie Completera
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (between_seconds > 0) {
        setState(() {
          between_seconds--;
        });
      } else {
        _timer?.cancel();
        if (!completer.isCompleted) {
          completer
              .complete(); // Zakończenie Future, gdy timer dojdzie do końca
        }
      }
    });
    return completer
        .future; // Zwrócenie Future, który zakończy się po zakończeniu timera
  }

  Future<void> initGame() async {
    action = Action.counting_start;
    await startTimer();
    setTime();
    setState(() {
      action = Action.guessing;
    });
    await normalTimer();
  }

  Future<void> nextQuestion() async {
    _timer?.cancel();
    setTime();
    if (question < 7){
      setState(() {
        question += 1;
        action = Action.guessing;
      });
      await normalTimer();
    }
    else{
      // kod kończący podsumowujący
    }
  }

  Future<void> betweenQuestions() async {
    _timer?.cancel();
    between_seconds = 2;
    await betweenTimer();
    nextQuestion();
  }

  Widget columnGuess(int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(chosenWords[index],
          style: TextStyle(
            fontSize: 60.0,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 2.0,
                color: Colors.black,
                offset: Offset(1.0, 1.0),
              ),
            ],
          ),),
        Text(typeTime.toString(),
            style: TextStyle(
              fontSize: 45.0,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 2.0,
                  color: Colors.black,
                  offset: Offset(1.0, 1.0),
                ),
              ],
            )),
      ],
    );
  }

  List<String> chooseWatchwords() {
    List<String> words = [];
    dynamic genreKeysCopy = widget.genreKeys;

    // Krok 1: Stworzenie listy indeksów
    List<int> indices = List.generate(genreKeysCopy.length, (index) => index);

    // Krok 2: Losowanie unikalnych indeksów
    indices.shuffle(); // Tasowanie listy indeksów

    for (int i = 0; i < min(8, indices.length); i++) {
      // Używamy 'min' dla bezpieczeństwa, aby uniknąć błędu, gdy lista ma mniej niż 8 elementów
      int chosenIndex = indices[i];
      words.add(genreKeysCopy[chosenIndex]['Name']);
    }

    return words;
  }

  @override
  void initState() {
    super.initState();
    // Wymuszenie orientacji poziomej
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    chosenWords = chooseWatchwords();
    initGame();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(AssetImage("assets/user_panels/bg0.jpg"), context);
    precacheImage(AssetImage("assets/user_panels/bg1.jpg"), context);
    precacheImage(AssetImage("assets/user_panels/bg2.jpg"), context);
    precacheImage(AssetImage("assets/user_panels/bg3.jpg"), context);
    precacheImage(AssetImage("assets/user_panels/bg4.jpg"), context);
    precacheImage(AssetImage("assets/user_panels/bg5.jpg"), context);
    // Możesz tutaj umieścić inne operacje wymagające kontekstu
  }

  @override
  void dispose() {
    // Przywrócenie do domyślnych orientacji (opcjonalnie)
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    action = Action.counting_start;
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: InkWell(
        onTap: () {
          if (action == Action.guessing) {
            setState(() {
              action = Action.right;
            });
            betweenQuestions();
          }
        },
        onDoubleTap: () {
          if (action == Action.guessing) {
            setState(() {
              action = Action.wrong;
            });
            betweenQuestions();
          }
        },
        child: Stack(
          children: [
            Image.asset(
              action.index < 4
                  ? widget.bg
                  : "assets/user_panels/bg" + action.index.toString() + ".jpg",
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
            if (action.index == 4)
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Dobrze",
                      style: TextStyle(
                        fontSize: 60.0,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 2.0,
                            color: Colors.black,
                            offset: Offset(1.0, 1.0),
                          ),
                        ],
                      ),),
                    SizedBox(width: 50,),
                    Icon(Icons.check, size: 120, color: Colors.white, shadows: [
                      Shadow(
                        blurRadius: 2.0,
                        color: Colors.black,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],),
                  ],
                ),
              ),
            if (action.index == 5)
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Nie udało się",
                      style: TextStyle(
                        fontSize: 60.0,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 2.0,
                            color: Colors.black,
                            offset: Offset(1.0, 1.0),
                          ),
                        ],
                      ),),
                    SizedBox(
                      width: 50,
                    ),
                    Icon(Icons.close,size: 120, color: Colors.white,shadows: [
                      Shadow(
                        blurRadius: 2.0,
                        color: Colors.black,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],),
                  ],
                ),
              ),
            if (action == Action.counting_start)
              Center(
                  child: Text(
                start_seconds.toString(),
                style: TextStyle(
                    fontFamily: "Jaapokki", fontSize: 35, color: Colors.white),
              )),
            if (action == Action.guessing) Center(child: columnGuess(question)),
          ],
        ),
      )),
    );
  }
}
