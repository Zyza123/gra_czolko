import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gra_czolko/user_panels/profile_panel/add_genre.dart';
import 'package:gra_czolko/user_panels/screens_panel.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;
import '../../login_panels/start.dart';
import '../../widgets/myElevatedButton.dart';
import 'edit_genre.dart';

class CreatedPage extends ConsumerStatefulWidget {
  const CreatedPage({super.key});

  @override
  ConsumerState<CreatedPage> createState() => _CreatedPageState();
}

class _CreatedPageState extends ConsumerState<CreatedPage> {

  MobileScannerController cameraController = MobileScannerController();

  String extractFileName(String url) {
    Uri uri = Uri.parse(url);
    List<String> segments = uri.pathSegments;
    String pathofpath = segments.last;  // Zwraca ostatni segment ścieżki, który jest nazwą pliku.
    return pathofpath.split('/').last;
  }

  Future<Map<String, dynamic>> downloadJson(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      if (mounted) {
        var utf8Data = utf8.decode(response.bodyBytes);  // Dekodowanie z UTF-8
        var jsonResponse = json.decode(utf8Data) as Map<String, dynamic>;
        //ScaffoldMessenger.of(context).showSnackBar(
        //  SnackBar(content: Text('Surowe dane: ' + jsonResponse.toString())),
        //);
        print('Surowe dane: ' + jsonResponse.toString());
        return jsonResponse;
      }
      return {};  // Zwraca pustą mapę, jeśli komponent nie jest zamontowany
    } else {
      throw Exception('Failed to download JSON data');
    }
  }

// Funkcja do zapisywania JSON do Firebase Storage
  Future<void> uploadJsonToFirebase(Map<String, dynamic> json, String uid, String url) async {
    final fileName = extractFileName(url);
    //ScaffoldMessenger.of(context).showSnackBar(
    //  SnackBar(content: Text('nazwa: '+ fileName)),
    //);
    final path = 'uzytkownicy/$uid/$fileName';
    //print("uid od nowego tel: " + uid);
    //print("filename: " + fileName);

    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      print("fp: "+FirebaseStorage.instance.ref().child(path).fullPath);
      final metadata = SettableMetadata(contentType: 'application/json');
      await ref.putString(jsonEncode(json), metadata: metadata);
      print("JSON has been uploaded successfully.");
    } catch (e) {
      print("An error occurred while uploading JSON: $e");
    }
  }

// Wywołanie funkcji
  Future<void> handleQRCodeResult(String url, String uid) async {
    try {
      var json = await downloadJson(url);
      await uploadJsonToFirebase(json, uid, url);
    } catch (error) {
      print("Error handling QR code result: $error");
    }
  }


  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(uidProvider);
    var userDataGenres = ref.watch(jsonUserGenreProvider(uid!));

    Future<bool> navigateToAddEditGenre(String fn) async {
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
        print("Result: "+result.toString());
         if(result == true){
           return true;
         }
         else{
           return false;
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
        print("Result: "+result.toString());
        if(result == true){
          return true;
        }
        else{
          return false;
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
                onPressed: () async {
                  await navigateToAddEditGenre("");
                  setState(() {
                    userDataGenres = ref.refresh(jsonUserGenreProvider(uid));
                  });
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
              SizedBox(height: 15,),
              MyElevatedButton(
                width: double.infinity,
                height: 45,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ScannerPage()),
                  ).then((barcodeValue) async {
                    final fileName = extractFileName(barcodeValue);
                    if (barcodeValue != null) {
                      await handleQRCodeResult(barcodeValue, uid);
                      userDataGenres = ref.refresh(jsonUserGenreProvider(uid));
                    }
                  });
                },
                borderRadius: BorderRadius.circular(15),
                child: Text(
                  "Pobierz gatunek kodem QR",
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
                          onTap: ()async {
                            await navigateToAddEditGenre(dataGenres[index]['Name']);
                            print("TEST POWROTU");
                            setState(() {
                              userDataGenres = ref.refresh(jsonUserGenreProvider(uid));
                            });
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

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final MobileScannerController controller = MobileScannerController(facing: CameraFacing.back);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2E2E2E),
      appBar: AppBar(title: const Text('Mobile Scanner')),
      body: MobileScanner(
        controller: controller,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final String? barcodeValue = barcodes.first.rawValue;
            if (barcodeValue != null) {
              debugPrint('Barcode found! $barcodeValue');
              controller.stop();
              Navigator.pop(context, barcodeValue); // Return the barcode value // Return the decoded barcode value
            }
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(controller.torchState.value == TorchState.off ? Icons.flash_off : Icons.flash_on),
        onPressed: () {
          setState(() {
            controller.toggleTorch();  // Przełączanie stanu latarki
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();  // Zwalnianie zasobów kontrolera kamery
    super.dispose();
  }
}
