import 'package:flutter/material.dart';
import 'package:twitch_clone/screens/login_screen.dart';
import 'package:twitch_clone/screens/signup_screen.dart';
import 'package:twitch_clone/widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  static const routeName = "/onboarding";
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome to \n Twitch",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: CustomButton(
                  onTap: () {
                    Navigator.pushNamed(context, LoginScreen.routeName);
                  },
                  text: "Log in"),
            ),
            CustomButton(
                onTap: () {
                  Navigator.pushNamed(context, SignupScreen.routeName);
                },
                text: "Sign Up"),
          ],
        ),
      ),
    );
  }
}
