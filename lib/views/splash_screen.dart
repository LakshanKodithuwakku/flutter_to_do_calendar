import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'event_calender.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            child: Image.asset("assets/icons/icon.png"),
          ),
          SizedBox(
            width: 30,
          ),
          Container(
            child: Text(
              "Event Calender",
              style: TextStyle(
                  color: textBlack, fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      nextScreen: EventCalenderScreen(),
      splashTransition: SplashTransition.fadeTransition,
    );
  }
}
