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
  TextEditingController _contentController = TextEditingController();

  Color selectedColor = Colors.blue;

  // Lista predefiniowanych kolorów
  final List<Color> colorOptions = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    // Dodaj więcej kolorów według potrzeb
  ];

  void processData(String uid) {
    String text = _contentController.text; // Pobranie tekstu z kontrolera
    // Filtracja linii, aby usunąć te, które są puste lub zawierają tylko białe znaki
    List<String> lines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();

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
      "Color": selectedColor.value,
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

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(uidProvider);
    return Scaffold(
      backgroundColor: Color(0xFF2E2E2E),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 10,right: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Kolor gatunku:  ",
                    style: TextStyle(
                        fontFamily: 'Jaapokki',
                        fontSize: 26,
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
              decoration: InputDecoration(
                hintText: 'Nazwa',
                hintStyle: TextStyle(color: Colors.grey,fontFamily: 'Jaapokki',),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none, // Usunięcie podświetlenia
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none, // Usunięcie podświetlenia
                ),
              ),
              style: TextStyle(fontSize: 26,color: Colors.white,fontFamily: 'Jaapokki',),
            ),
            Expanded(
              child: TextField(
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
