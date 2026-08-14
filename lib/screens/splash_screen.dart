import 'package:flutter/material.dart';
import 'todo_home_page.dart'; // Adjust import path as needed

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Staggered Animation Sequence
    _logoFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _textFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // Simulates initial setup/asset loading delay
    await Future.delayed(const Duration(milliseconds: 2800));

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const TodoHomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F8),
      body: Stack(
        children: [
          // Subtle Ambient Background Gradients
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF0055FF).withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF1B1C1C).withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Centered Content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    

                    // Animated Brand Logo Container
                    FadeTransition(
                      opacity: _logoFadeAnimation,
                      child: ScaleTransition(
                        scale: _logoScaleAnimation,
                        child: Image.asset('assets/icon/TaskFlow_transparent.png')
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Animated Text Elements
                    FadeTransition(
                      opacity: _textFadeAnimation,
                      child: SlideTransition(
                        position: _textSlideAnimation,
                        child: Column(
                          children: [
                            const Text(
                              'TASKFLOW',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 3.5,
                                color: Color(0xFF1B1C1C),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 16,
                                  height: 1,
                                  color: const Color(0xFFC4C7C7),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Text(
                                    'PRECISION PRODUCTIVITY',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.8,
                                      color: Color(0xFF747878),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 16,
                                  height: 1,
                                  color: const Color(0xFFC4C7C7),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Minimal Bottom Loading Indicator & Status
                    FadeTransition(
                      opacity: _textFadeAnimation,
                      child: Column(
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF0055FF),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Initializing workspace...',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF747878).withValues(alpha: 0.8),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}