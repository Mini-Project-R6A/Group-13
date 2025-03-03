// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:nyaymitra1/screens/home_screen.dart';
// import 'auth_screen.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _navtologin();
//   }
//
//   void _navtologin() async {
//     await Future.delayed(const Duration(seconds: 2)); //show splash for 2s
//     User? user = FirebaseAuth.instance.currentUser;
//     // The "?" means the user variable can be null if no one is signed in.
//     if (mounted) {
//       //to say widget in still alive(mounted)
//       Navigator.of(context).pushReplacement(
//         // Replaces the current screen with a new one without keeping the previous screen in the stack.
//         MaterialPageRoute(
//           builder: (context) =>
//               user == null ? const AuthScreen() : const HomeScreen(),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 0, 0, 0),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.asset('assets/images/logo.png', height: 100), // Add your logo
//             const SizedBox(height: 20),
//             const Text("Nyay Mitra",
//                 style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Color.fromARGB(255, 0, 0, 0))),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'package:flutter/material.dart';
import 'auth_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navtologin();
  }

  void _navtologin() async {
    await Future.delayed(const Duration(seconds: 2)); //show splash for 2s
    // Directly navigate to AuthScreen without Firebase authentication check
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', height: 100), // Add your logo
            const SizedBox(height: 20),
            const Text(
              "Nyay Mitra",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
