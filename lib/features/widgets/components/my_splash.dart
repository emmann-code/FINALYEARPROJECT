// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';


// class SplashScreenUI extends StatefulWidget {
//   const SplashScreenUI({super.key});


//   @override
//   State<SplashScreenUI> createState() => _SplashScreenUIState();
// }

// class _SplashScreenUIState extends State<SplashScreenUI> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 63, 60, 71), // Dark theme background
//       body: Stack(
//         children: [
//           Align(
//             alignment: Alignment.center,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Image.asset(
//                   'assets/tst.png', 
//                   width: 150,
//                   height: 150,
//                 ),
//                 const SizedBox(height: 20),
//                 // 'M T U  C O N N E C T  H U B'
//                 ShaderMask(
//                     shaderCallback: (bounds) => const LinearGradient(
//                       colors: [Colors.blueAccent, Colors.white],
//                     ).createShader(bounds),
//                     child: Text(
//                       'M T U C O N N E C T H U B',
//                       style: GoogleFonts.aDLaMDisplay(
//                         fontSize: 36,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                         letterSpacing: 1.2,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Image.asset(
//               'assets/MTU_LOGO-removebg-preview.png', // mtu logo
//                width:50,
//                height:50,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreenUI extends StatefulWidget {
  const SplashScreenUI({super.key});

  @override
  State<SplashScreenUI> createState() => _SplashScreenUIState();
}

class _SplashScreenUIState extends State<SplashScreenUI>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 63, 60, 71), // Dark theme background
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/tst.png',
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 20),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.blueAccent, Colors.white],
                          ).createShader(bounds),
                          child: Text(
                            'MTU CONNECT-HUB',
                            style: GoogleFonts.orbitron(
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              'assets/MTU_LOGO-removebg-preview.png',
              width: 50,
              height: 50,
            ),
          ),
        ],
      ),
    );
  }
}
