import "package:flutter/material.dart";

import "ParticipantsFiles/CoordinatorDetailsScreen.dart";

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Delayed navigation after 5 seconds (3 seconds for splash screen + 2 seconds delay)
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MyAppwww(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // Slide in from right
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            // const duration = Duration(seconds: 5); // Adjust the duration for a slower slide

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
          transitionDuration:
              const Duration(seconds: 1), // Adjust transition duration
        ),
      );
    });

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/splash.jpg'),
          // Replace with your image path
          fit: BoxFit.cover, // You can adjust the fit as needed
        ),
      ),
    );
  }
}
