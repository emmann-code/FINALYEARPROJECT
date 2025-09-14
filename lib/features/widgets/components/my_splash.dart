// ignore_for_file: prefer_const_constructors_in_immutables, prefer_final_fields, unused_field, deprecated_member_use, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class SplashScreenUI extends StatefulWidget {
  SplashScreenUI({super.key});

  @override
  State<SplashScreenUI> createState() => _SplashScreenUIState();
}

class _SplashScreenUIState extends State<SplashScreenUI>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _bgController;
  bool _isDisposed = false;

  String _displayedText = '';
  int _textIndex = 0;
  final String _fullText = 'MTU CONNECT HUB';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();

    _glowController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _bgController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 6),
    )..repeat();

    _startTypewriter();
  }

  void _startTypewriter() async {
    for (int i = 0; i <= _fullText.length; i++) {
      await Future.delayed(Duration(milliseconds: 70));
      if (!mounted || _isDisposed) return;
      setState(() {
        _displayedText = _fullText.substring(0, i);
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    _glowController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted || _isDisposed) return Container();
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          if (!mounted || _isDisposed) return Container();
          return CustomPaint(
            painter: _AnimatedBackgroundPainter(_bgController.value),
            child: child,
          );
        },
        child: Stack(
          children: [
            // Floating circles for depth
            ...List.generate(
                3, (i) => _FloatingCircle(index: i, controller: _bgController)),
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _glowController,
                    builder: (context, child) {
                      if (!mounted || _isDisposed) return Container();
                      return Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent
                                  .withOpacity(0.5 * _glowAnimation.value),
                              blurRadius: 32 * _glowAnimation.value,
                              spreadRadius: 8 * _glowAnimation.value,
                            ),
                          ],
                          shape: BoxShape.circle,
                        ),
                        child: child,
                      );
                    },
                    child: Image.asset(
                      'assets/tst.png',
                      width: 120,
                      height: 120,
                    ),
                  ),
                  SizedBox(height: 28),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      if (!mounted || _isDisposed) return Container();
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Opacity(
                          opacity: _opacityAnimation.value,
                          child: Column(
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    Colors.blueAccent,
                                    Color(0xFFCEABAB),
                                  ],
                                ).createShader(bounds),
                                child: Text(
                                  _displayedText,
                                  style: GoogleFonts.orbitron(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Empowering Campus Connections',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 18),
                              // Micro-interaction: animated dots
                              _AnimatedDots(isParentDisposed: _isDisposed),
                            ],
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
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 32,
                      child: CustomPaint(
                        size: Size(180, 32),
                        painter: _WavyDividerPainter(),
                      ),
                    ),
                    SizedBox(height: 8),
                    Image.asset(
                      'assets/MTU_LOGO-removebg-preview.png',
                      width: 48,
                      height: 48,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Animated background painter
class _AnimatedBackgroundPainter extends CustomPainter {
  final double value;
  _AnimatedBackgroundPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(Color(0xFF0F2027), Color(0xFF2C5364),
            0.5 + 0.5 * sin(value * 2 * pi))!,
        Color.lerp(Color(0xFF2C5364), Color(0xFF0F2027),
            0.5 + 0.5 * cos(value * 2 * pi))!,
      ],
    );
    final rect = Offset.zero & size;
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _AnimatedBackgroundPainter oldDelegate) => true;
}

// Floating circles for depth
class _FloatingCircle extends StatelessWidget {
  final int index;
  final AnimationController controller;
  const _FloatingCircle({required this.index, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final double t = controller.value;
        final double dx = 60.0 + 80.0 * index + 30.0 * sin(t * 2 * pi + index);
        final double dy =
            120.0 + 60.0 * index + 20.0 * cos(t * 2 * pi + index * 2);
        return Positioned(
          left: dx,
          top: dy,
          child: Opacity(
            opacity: 0.10 + 0.08 * index,
            child: Container(
              width: 60 + 10.0 * index,
              height: 60 + 10.0 * index,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.08),
                    blurRadius: 24,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Animated dots for micro-interaction
class _AnimatedDots extends StatefulWidget {
  final bool isParentDisposed;
  const _AnimatedDots({this.isParentDisposed = false});
  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted || _isDisposed || widget.isParentDisposed) return Container();
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (!mounted || _isDisposed || widget.isParentDisposed)
          return Container();
        int active = (_controller.value * 3).floor() % 3;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.5),
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: i == active ? Colors.blueAccent : Colors.white24,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// Wavy divider painter
class _WavyDividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path();
    for (double x = 0; x <= size.width; x += 1) {
      double y = 8 * sin(2 * pi * x / size.width * 2);
      if (x == 0) {
        path.moveTo(x, size.height / 2 + y);
      } else {
        path.lineTo(x, size.height / 2 + y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
