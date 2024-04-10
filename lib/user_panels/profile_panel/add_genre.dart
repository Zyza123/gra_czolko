import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../login_panels/start.dart';
import '../../widgets/myElevatedButton.dart';
import '../screens_panel.dart';

class AddGenre extends ConsumerStatefulWidget {
  const AddGenre({super.key});

  @override
  ConsumerState<AddGenre> createState() => _AddGenreState();
}


class _AddGenreState extends ConsumerState<AddGenre> {

  TextEditingController _titleController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  Color selectedColor = Color(0xFF8B0000);

  // Lista predefiniowanych kolorów
  final List<Color> colorOptions = [
     const Color(0xFF8B0000), const Color(0xFF6A1B9A),const Color(0xFFFF8F00), const Color(0xFF795548),
      const Color(0xFFBA68C8), const Color(0xFF222222), const Color(0xFFDDAA00), const Color(0xFF6a67CE),
      const Color(0xFF42A5F5), const Color(0xFF7B3F00), const Color(0xFF4169E1), const Color(0xFF5AA17F),
      const Color(0xFFFFC0CB), const Color(0xFFF39C12)
    // Dodaj więcej kolorów według potrzeb
  ];

  void processData(String uid) {
    String text = _contentController.text; // Pobranie tekstu z kontrolera
    // Filtracja linii, aby usunąć te, które są puste lub zawierają tylko białe znaki
    List<String> lines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();

    if(lines.length < 8){
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ilość haseł musi wynosić co najmniej 8, a najlepiej w granicach 80.')),
        );
      }
      return ;
    }
    // Tutaj masz listę 'lines', gdzie każdy element to jedna linia tekstu
    for (String line in lines) {
      print(line); // Możesz zrobić coś z każdą linią, na przykład wysłać do Firestore
    }
    // Przykład użycia
    addGenreToFirebaseStorage(lines, uid); // Wywołanie funkcji z poprzedniego przykładu
  }


  Future<void> addGenreToFirebaseStorage(List<String> elements, String Uuid) async {
    final String uid = Uuid; // Uzyskaj uid użytkownika z Firebase Auth lub innego źródła
    final fileName = '${_titleController.text.toLowerCase().replaceAll(' ', '')}.json'; // Formatowanie nazwy pliku
    final path = 'uzytkownicy/$uid/$fileName';

    final List<Map<String, dynamic>> elementsJson = elements.asMap().entries.map((entry) {
      int idx = entry.key + 1; // Id zaczyna się od 1
      String name = entry.value;
      return {
        "Id": idx,
        "Name": name,
      };
    }).toList();

    final data = jsonEncode({
      "Name": _titleController.text,
      "color": int.parse("0x${selectedColor.value.toRadixString(16)}"),
      "description": _descController.text,
      "difficulty": dropdownValue,
      "Elements": elementsJson,
    });

    try {
      // Utworzenie referencji do miejsca w Storage
      final ref = FirebaseStorage.instance.ref().child(path);
      // Ustawienie metadanych, w tym contentType
      final metadata = SettableMetadata(contentType: 'application/json');
      // Dodanie danych jako plik tekstowy z metadanymi
      await ref.putString(data, metadata: metadata);
      print("Pomyślnie dodano gatunek.");
      if(mounted){
      Navigator.pop(context,true);
      }
    } catch (e) {
      print("Wystąpił błąd podczas dodawania gatunku: $e");
    }
  }

  void changeColor(Color color) {
    setState(() => selectedColor = color);
  }

  void showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Wybierz kolor'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: selectedColor,
              availableColors: colorOptions,
              onColorChanged: changeColor,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Gotowe'),
              onPressed: () {
                setState(() => selectedColor = selectedColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  String dropdownValue = "łatwy ";

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(uidProvider);
    return Scaffold(
      backgroundColor: Color(0xFF2E2E2E),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 12,right: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Kolor gatunku:  ",
                            style: TextStyle(
                                fontFamily: 'Jaapokki',
                                fontSize: 22,
                                color: Colors.white),),
                          InkWell(
                            onTap: (){
                              showColorPicker(context);
                            },
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: selectedColor,
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(width: 1,color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    TextField(
                      controller: _titleController,
                      maxLength: 20,
                      decoration: InputDecoration(
                        counterText: "",
                        hintText: 'Nazwa',
                        hintStyle: TextStyle(color: Colors.grey,fontFamily: 'Jaapokki',),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none, // Usunięcie podświetlenia
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none, // Usunięcie podświetlenia
                        ),
                      ),
                      style: TextStyle(fontSize: 22,color: Colors.white,fontFamily: 'Jaapokki',),
                    ),
                    Row(
                      children: [
                        SizedBox(width: 12,),
                        Text(
                          'Trudność',
                          style: TextStyle(
                              fontFamily: "Jaapokki",
                              fontSize: 22,
                              color: Colors.white),
                        ),
                        SizedBox(width: 15,),
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
                              });
                            },
                            items: <String>[
                              'łatwy ',
                              'średni ',
                              'trudny '
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
                    TextField(
                      controller: _descController,
                      maxLines: 3,
                      maxLength: 150,
                      decoration: InputDecoration(
                        hintText: 'opis',
                        hintStyle: TextStyle(color: Colors.grey,fontFamily: 'Jaapokki',),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none, // Usunięcie podświetlenia
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none, // Usunięcie podświetlenia
                        ),
                      ),
                      style: TextStyle(fontSize: 20,color: Colors.white,fontFamily: 'Jaapokki',),
                    ),
                    TextField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        hintText: 'hasła gatunku',
                        hintStyle: TextStyle(color: Colors.grey),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none, // Usunięcie podświetlenia
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none, // Usunięcie podświetlenia
                        ),
                      ),
                      style: TextStyle(fontSize: 20,height: 1.5,color: Colors.white),
                      maxLines: null, // Pozwala na wielolinijkowy tekst
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: MyElevatedButton(
                width: double.infinity,
                height: 45,
                onPressed: () {
                  if(_titleController.text.isNotEmpty && _contentController.text.isNotEmpty){
                    processData(uid!);
                  }
                },
                borderRadius: BorderRadius.circular(15),
                child: Text(
                  "Dodaj gatunek",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: "Jaapokki",
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
