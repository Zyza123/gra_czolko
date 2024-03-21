import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gra_czolko/user_panels/screens_panel.dart';
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

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(uidProvider);
    // Używamy userDataProvider z uid, aby pobrać dane użytkownika
    final userDataAsyncValue = ref.watch(userDataProvider(uid!));
    final baseDataAsyncValue = ref.watch(baseDataProvider(uid));

    return userDataAsyncValue.when(
      data: (userData) {
        // Budujemy UI na podstawie odczytanych danych
        return Scaffold(
          backgroundColor : const Color(0xff2E2E2E),
          body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 25.0,left: 10,right: 10,bottom: 10),
                child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text('Witaj, ${userData['username']}!',style: TextStyle(fontSize: 26,color: Colors.white),),
                      ],
                    )
                ),
              )
          ),
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Wystąpił błąd: $err'),
    );
  }
}
