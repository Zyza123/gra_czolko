import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

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
  empty,
  right,
  wrong,
  end,
}

class _PlayPageState extends State<PlayPage> {
  int start_seconds = 5;
  int between_seconds = 1;
  Timer? _timer;
  late Action action;
  late int typeTime;
  late List<String> chosenWords;
  late List<int> points;
  int question = 0;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  void setTime() {
    if (widget.type == 0 || widget.type == 1) {
      typeTime = 59;
    } else if (widget.type == 2) {
      typeTime = 119;
    } else {
      typeTime = 179;
    }
  }
  String formatSeconds(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
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
      setState(() {
        action = Action.end;
      });
    }
  }

  Future<void> betweenQuestions() async {
    _timer?.cancel();
    between_seconds = 1;
    await betweenTimer();
    nextQuestion();
  }

  Widget columnGuess(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(chosenWords[index],
            textAlign: TextAlign.center,
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
          Text(formatSeconds((typeTime+1)),
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
      ),
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
  double? lastX;
  double? lastY;
  double? lastZ;
  late AudioPlayer player;

  @override
  void initState() {
    super.initState();
    // Wymuszenie orientacji poziomej
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    player = AudioPlayer();
    chosenWords = chooseWatchwords();
    points = List<int>.filled(chosenWords.length, 0);
    initGame();
    _streamSubscriptions.add(
        accelerometerEventStream().listen((AccelerometerEvent event) {
          if (lastX == null) {
            lastX = event.x;
            lastY = event.y;
            lastZ = event.z;
          } else {
            checkTilt(event.x,event.y,event.z);
            //print("kat x: " + event.x.toString());
            //print("kat y: " + event.y.toString());
            //print("kat z: " + event.z.toString());
          }
        },
          onError: (e) {
            showDialog(
                context: context,
                builder: (context) {
                  return const AlertDialog(
                    title: Text("Czujnik nie znaleziony"),
                    content: Text(
                        "Wygląda na to, że twoje urządzenie nie obsługuje akcelerometru."),
                  );
                });
          },
          cancelOnError: true,)
    );
  }

  void checkTilt(double currentX, double currentY, double currentZ) {
    if ((currentY.abs() < thresholdY) && (currentZ.abs() < thresholdZ)) {
      if (currentX < 5.5) {
        // Telefon przechylony!
        if (action == Action.guessing) {
          setState(() async {
            action = Action.right;
            points[question] = 1;
            await player.play(AssetSource("sounds/correct.mp3"));
          });
          betweenQuestions();
        }
      }
    }
    lastX = currentX;
  }

  double thresholdY = 1.0; // próg, powyżej którego ignorujesz zmianę
  double thresholdZ = 1.0;

  int calculateFontSize(String text) {
    if (text.length <= 22) {
      return 30;
    } else {
      int extraChars = text.length - 22;
      int sizeDecrease = (extraChars / 5).floor() * 2;
      int finalSize = 30 - sizeDecrease;
      return finalSize > 10 ? finalSize : 10; // A minimum font size limit
    }
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
    precacheImage(AssetImage("assets/user_panels/bg6.jpg"), context);
    // Możesz tutaj umieścić inne operacje wymagające kontekstu
  }

  @override
  void dispose() {
    // Przywrócenie do domyślnych orientacji (opcjonalnie)
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    action = Action.counting_start;
    _timer?.cancel();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: InkWell(
        onTap: () async {
          if (action == Action.guessing) {
            setState(() {
              action = Action.right;
            });
            await player.play(AssetSource("sounds/correct.mp3"));
            points[question] = 1;
            betweenQuestions();
          }
        },
        onDoubleTap: () async {
          if (action == Action.guessing) {
            setState(() {
              action = Action.wrong;
            });
            await player.play(AssetSource("sounds/wrong.mp3"));
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
                 (start_seconds+1).toString(),
                style: const TextStyle(
                    fontFamily: "Jaapokki", fontSize: 50, color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 2.0,
                      color: Colors.black,
                      offset: Offset(1.0, 1.0),
                    ),
                  ],),
              )),
            if (action == Action.guessing) Center(child: columnGuess(question)),
            if(action == Action.end)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5,bottom: 5),
                  child: Column(
                    children: [
                      Text("Podsumowanie",
                        style: TextStyle(
                          fontSize: 50.0,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 2.0,
                              color: Colors.black,
                              offset: Offset(1.0, 1.0),
                            ),
                          ],
                        ),),
                      SizedBox(height: 10,),
                      Expanded( // Zawijamy ListView.builder w widget Expanded
                        child: ListView.builder(
                          itemCount: chosenWords.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                chosenWords[index],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: calculateFontSize(chosenWords[index]).toDouble(),
                                  fontWeight: points[index] == 1 ? FontWeight.bold : FontWeight.normal,
                                  color: points[index] == 1 ? Color(0xFF5CE600) : Color(0xFFE60000),
                                  shadows: [
                                    Shadow(
                                      blurRadius: 1.0,
                                      color: Colors.black,
                                      offset: Offset(1.0, 1.0),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 5,),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          '   Koniec   ',
                          style: TextStyle(
                            color: Colors.white, // Biała czcionka
                            fontSize: 30
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white,width: 2), // Biały obramowanie
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),), // Zaokrąglone rogi
                        ),
                      ),
                    ],
                  ),
                ),
              )
          ],
        ),
      )),
    );
  }
}
