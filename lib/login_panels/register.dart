import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gra_czolko/login_panels/start.dart';
import 'package:lottie/lottie.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import '../widgets/myElevatedButton.dart';

class Register extends ConsumerStatefulWidget {
  const Register({super.key});

  @override
  ConsumerState<Register> createState() => _RegisterState();
}

class _RegisterState extends ConsumerState<Register> {

  TextEditingController username = TextEditingController();
  bool warningUsername = false;
  TextEditingController email = TextEditingController();
  bool warningEmail = false;
  TextEditingController password = TextEditingController();
  bool warningPassword = false;
  bool hidePassword = true;
  bool showSignAnimation = false;
  bool showFinalInfo = false;
  late CollectionReference users;

  Future<void> registerWithEmailPassword(String email, String password, BuildContext context) async {
    setState(() {
      showSignAnimation = true; // Pokaż animację
    });

    try {
      final UserCredential userCredential = await ref.read(firebaseAuthProvider).createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
        await addDataToFirestore(userCredential.user!);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hasło jest za słabe.')));
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ten adres email jest już powiązany z innym kontem.')));
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        showSignAnimation = false; // Ukryj animację po zakończeniu procesu
        showFinalInfo = true;
      });
      //ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pomyślnie utworzono konto\nZweryfikuj adres email aby się zalogować.')));
    }
  }


  void resetUsername(){
    setState(() {warningUsername = false;});
  }
  void resetEmail(){
    setState(() {warningEmail = false;});
  }
  void resetPassword(){
    setState(() {warningPassword = false;});
  }

  Future<void> addDataToFirestore(User user) async {
    // Ustalamy ścieżkę do dokumentu nadrzędnego
    try {
      // Tworzymy dokument nadrzędny, jeśli nie istnieje
      await users.doc(user.uid).set({"exists": true});

      // Tworzymy lub aktualizujemy poddokument "account" w dokumencie nadrzędnym
      await users.doc(user.uid).collection('account').doc('account').set({
        "username": username.text,
        "email": email.text,
        "password": password.text,
        "theme": "dark",
      });
      await users.doc(user.uid).collection('favorite').doc('favorite').set({});
      await users.doc(user.uid).collection('created').doc('created').set({});

      print("Dane zostały pomyślnie zapisane do Firestore.");
    } catch (e) {
      print("Wystąpił błąd podczas zapisywania danych do Firestore: $e");
    }
  }

  bool validateRegistration(){
    setState(() {
      // checking username
      warningUsername = username.text.isEmpty;
      // checking email
      RegExp emailRegex = RegExp(r'^.+@.+\..+$');
      warningEmail = !(emailRegex.hasMatch(email.text) && email.text.length >= 6);
      // checking password
      warningPassword = !(password.text.length >= 6);
    });
    // odwracam (jesli wszystkie to false to znaczy że po zamianie są wszystkei true to jest poprawnie)
    bool isFormValid = !warningUsername && !warningEmail && !warningPassword;
    return isFormValid;
  }

  @override
  void initState() {
    username.addListener(resetUsername);
    email.addListener(resetEmail);
    password.addListener(resetPassword);
    users = FirebaseFirestore.instance.collection('users');
    super.initState();
  }

  @override
  void dispose() {
    username.dispose();
    username.removeListener(resetUsername);
    email.removeListener(resetEmail);
    password.removeListener(resetPassword);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2E2E2E),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 50,
                    ),
                    Container(
                      height: 70,
                      child: GradientText(
                        'CZÓŁKO',
                        style: TextStyle(
                          fontFamily: 'JaapokkiEnhance',
                          fontSize: 64,
                        ),
                        colors: [Color(0xffD613E7), Color(0xffED8022)],
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Username',
                          style: TextStyle(
                              fontFamily: 'Jaapokki',
                              fontSize: 30,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Container(
                            height: 60,
                            child: TextFormField(
                              controller: username,
                              maxLength: 30,
                              decoration: InputDecoration(
                                counterText: "",
                                fillColor: Color(0xff2E2E2E),
                                filled: true,
                                contentPadding: EdgeInsets.only(
                                    left: 75, right: 10, top: 21, bottom: 21),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                      width: 2, color: Color(0xffE76151)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  // Gdy pole tekstowe jest dostępne, ale nie ma focusa
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                      width: 2, color: Color(0xffE76151)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  // Gdy pole tekstowe jest zaznaczone (ma focus)
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                      width: 2, color: Color(0xffE76151)),
                                ),
                              ),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: 'Jaapokki',
                                  letterSpacing: 2),
                            ),
                          ),
                        ),
                        Container(
                          width: 75,
                          height: 75,
                          decoration: BoxDecoration(
                            color: Color(0xff2E2E2E),
                            border: Border.all(color: Color(0xffE76151), width: 2),
                            borderRadius: BorderRadius.all(Radius.circular(90)),
                          ),
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 35,
                          ),
                        )
                      ],
                    ),
                    if(warningUsername)
                      SizedBox(height: 10),
                    if(warningUsername)
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '* Nazwa użytkownika nie może być pusta.',
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ),
                    SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Email',
                          style: TextStyle(
                              fontFamily: 'Jaapokki',
                              fontSize: 30,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Container(
                            height: 60,
                            child: TextFormField(
                              controller: email,
                              maxLength: 30,
                              decoration: InputDecoration(
                                counterText: "",
                                fillColor: Color(0xff2E2E2E),
                                filled: true,
                                contentPadding: EdgeInsets.only(
                                    left: 75, right: 10, top: 21, bottom: 21),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                      width: 2, color: Color(0xffE76151)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  // Gdy pole tekstowe jest dostępne, ale nie ma focusa
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                      width: 2, color: Color(0xffE76151)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  // Gdy pole tekstowe jest zaznaczone (ma focus)
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                      width: 2, color: Color(0xffE76151)),
                                ),
                              ),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: 'Jaapokki',
                                  letterSpacing: 2),
                            ),
                          ),
                        ),
                        Container(
                          width: 75,
                          height: 75,
                          decoration: BoxDecoration(
                            color: Color(0xff2E2E2E),
                            border: Border.all(color: Color(0xffE76151), width: 2),
                            borderRadius: BorderRadius.all(Radius.circular(90)),
                          ),
                          child: Icon(
                            Icons.mail_outline,
                            color: Colors.white,
                            size: 35,
                          ),
                        )
                      ],
                    ),
                    if(warningEmail)
                      SizedBox(height: 10),
                    if(warningEmail)
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '* Email musi zawierać co najmniej 6 znaków, kropkę i @.',
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ),
                    SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Password',
                          style: TextStyle(
                              fontFamily: 'Jaapokki',
                              fontSize: 30,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              border: Border.all(width: 2, color: Color(0xffE76151))
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: password,
                                    maxLength: 30,
                                    obscureText: hidePassword,
                                    decoration: InputDecoration(
                                      counterText: "",
                                      fillColor: Color(0xff2E2E2E),
                                      filled: true,
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.only(
                                          left: 75, right: 10, top: 21, bottom: 21),
                                    ),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontFamily: 'Jaapokki',
                                        letterSpacing: 2),
                                  ),
                                ),
                                IconButton(
                                  color: Colors.white,
                                  iconSize: 25,
                                  icon: Icon(
                                    hidePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      hidePassword = !hidePassword;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 75,
                          height: 75,
                          decoration: BoxDecoration(
                            color: Color(0xff2E2E2E),
                            border: Border.all(color: Color(0xffE76151), width: 2),
                            borderRadius: BorderRadius.all(Radius.circular(90)),
                          ),
                          child: Icon(
                            Icons.lock,
                            color: Colors.white,
                            size: 35,
                          ),
                        )
                      ],
                    ),
                    if(warningPassword)
                      SizedBox(height: 10),
                    if(warningPassword)
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '* Hasło musi zawierać co najmniej 6 znaków.',
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ),
                    SizedBox(height: 50),
                    MyElevatedButton(
                      width: double.infinity,
                      height: 60,
                      onPressed: () {
                        if(validateRegistration()){
                          registerWithEmailPassword(email.text, password.text, context);
                        };
                      },
                      borderRadius: BorderRadius.circular(25),
                      child: Text(
                        'STWÓRZ!',
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      ),
                    ),
                    SizedBox(height: 25,),
                    ElevatedButton(
                      onPressed: () {
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Zarejestruj przez   ',style: TextStyle(fontFamily: "Jaapokki")),
                          Image.asset('assets/login_panels/google.png'),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color(0xff414141), // Kolor tekstu przycisku
                        textStyle: TextStyle(fontSize: 25),
                        minimumSize: Size(double.infinity, 60), // Maksymalna szerokość i wysokość 70
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25), // Tu ustawiasz zaokrąglenie rogów
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: showSignAnimation,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Color(0x80000000),
                child: Center(
                  child: Lottie.asset('assets/animations/anim_login.json'),
                ),
              ),
            ),
            Visibility(
              visible: showFinalInfo,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Color(0x80000000),
                child: Center(
                  child: AlertDialog(
                    backgroundColor: Color(0xff100c08), // Tło dialogu
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(height: 15),
                        Padding(
                          padding: EdgeInsets.zero, // Zminimalizowanie przestrzeni wokół obrazu
                          child: Image.asset(
                            "assets/login_panels/accept.png",
                            // Możesz także użyć fit, aby kontrolować, jak obraz ma się dopasować
                            // fit: BoxFit.cover, // na przykład
                          ),
                        ),
                        SizedBox(height: 15), // Zmniejszony odstęp między obrazem a tekstem
                        Text(
                          'Pomyślnie utworzono konto ! Zweryfikuj adres email aby się zalogować.',
                          style: TextStyle(color: Colors.white, fontSize:18), // Biała czcionka
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      Center( // Wyśrodkowanie przycisku w poziomie
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Zamknięcie dialogu
                            setState(() {
                              showFinalInfo = false; // Ukrycie ciemnego tła
                            });
                          },
                          child: GradientText(
                            'Jasne !',
                            style: TextStyle(color: Colors.white,fontSize: 20),
                            colors: [Color(0xffD613E7), Color(0xffED8022)], // Biała czzionka dla przycisku
                          ),
                        ),
                      ),
                    ],
                  )
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
