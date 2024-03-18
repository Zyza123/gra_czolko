import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:gra_czolko/user_panels/play_page.dart';
import 'package:gra_czolko/user_panels/profile_page.dart';

import 'home_page.dart';

class ScreensPanel extends StatefulWidget {
  const ScreensPanel({super.key});

  @override
  State<ScreensPanel> createState() => _ScreensPanelState();
}

class _ScreensPanelState extends State<ScreensPanel> {

  int currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    _screens = [
      const HomePage(),
      const PlayPage(),
      const ProfilePage(),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2E2E2E),
      body: SafeArea(
        child: IndexedStack(
          index: currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Container(

        color: const Color(0xff2E2E2E),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: GNav(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            color: Colors.grey.shade300,
            activeColor: Color(0xff2E2E2E),
            tabBackgroundColor: Colors.grey.shade300,
            duration: Duration(milliseconds: 300),
            gap: 8,
            iconSize: 23,
            padding: EdgeInsets.symmetric(vertical: 8,horizontal: 12),
            onTabChange: (index){
              setState(() {
                currentIndex = index;
              });
            },
            tabs: const [
              GButton(
                icon: Icons.home_filled,
                text: 'Dom',
                textStyle: TextStyle(fontSize: 20,),
              ),
              GButton(
                icon: Icons.videogame_asset_sharp,
                text: 'Gra',
                textStyle: TextStyle(fontSize: 20,),
              ),
              GButton(
                icon: Icons.person_rounded,
                text: 'Profil',
                textStyle: TextStyle(fontSize: 20,),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
