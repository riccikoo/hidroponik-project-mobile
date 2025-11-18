import 'package:flutter/material.dart';
import 'dart:async';
import '../services/shared_service.dart';
import 'login_page.dart';
import 'dashboard_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Color palette
  final Color darkGreen = const Color(0xFF456028);
  final Color mediumGreen = const Color(0xFF94A65E);
  final Color lightGreen = const Color(0xFFDDDDA1);
  final Color creamBackground = const Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();

    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(milliseconds: 3000));

    final isLoggedIn = await SharedService.isLoggedIn();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              isLoggedIn ? const DashboardPage() : const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBackground,
      body: Stack(
        children: [
          // Decorative Pattern Grid Background
          Positioned.fill(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
              ),
              itemCount: 21,
              itemBuilder: (context, index) {
                return _buildGridPattern(index);
              },
            ),
          ),

          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    creamBackground.withValues(alpha: 0.0),
                    creamBackground.withValues(alpha: 0.7),
                    creamBackground.withValues(alpha: 0.95),
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo Pattern Grid
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: darkGreen.withValues(alpha: 0.15),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    childAspectRatio: 1,
                                  ),
                              itemCount: 16,
                              itemBuilder: (context, index) {
                                return _buildLogoGridPattern(index);
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // App Title
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: darkGreen,
                              letterSpacing: -1,
                            ),
                            children: [
                              const TextSpan(text: 'Green'),
                              TextSpan(
                                text: 'Life',
                                style: TextStyle(color: mediumGreen),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Subtitle with Icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.eco_outlined,
                              color: mediumGreen,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Let's make the world green again",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 50),

                        // Loading Indicator
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              mediumGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Version Text at Bottom
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'Version 1.0.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridPattern(int index) {
    // Pattern colors and shapes
    final patterns = [
      {'color': darkGreen, 'icon': Icons.eco_outlined, 'hasIcon': true},
      {'color': lightGreen, 'hasIcon': false},
      {
        'color': mediumGreen,
        'icon': Icons.local_florist_outlined,
        'hasIcon': true,
      },
      {'color': lightGreen.withValues(alpha: 0.5), 'hasIcon': false},
      {
        'color': darkGreen.withValues(alpha: 0.7),
        'icon': Icons.water_drop_outlined,
        'hasIcon': true,
      },
      {'color': creamBackground, 'hasIcon': false},
      {
        'color': mediumGreen.withValues(alpha: 0.6),
        'icon': Icons.yard_outlined,
        'hasIcon': true,
      },
    ];

    final pattern = patterns[index % patterns.length];
    final hasIcon = pattern['hasIcon'] as bool;

    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: pattern['color'] as Color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: hasIcon
          ? Center(
              child: Icon(
                pattern['icon'] as IconData,
                color: Colors.white.withValues(alpha: 0.4),
                size: 30,
              ),
            )
          : null,
    );
  }

  Widget _buildLogoGridPattern(int index) {
    final colors = [
      darkGreen,
      lightGreen,
      mediumGreen,
      lightGreen.withValues(alpha: 0.5),
      Colors.white,
    ];

    final icons = [
      Icons.eco_outlined,
      Icons.water_drop_outlined,
      Icons.local_florist_outlined,
      Icons.yard_outlined,
      null,
    ];

    final color = colors[index % colors.length];
    final icon = icons[index % icons.length];

    // Specific patterns for some indices
    if (index == 0 || index == 3 || index == 12 || index == 15) {
      // Corner pieces - darker
      return Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: darkGreen,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Icon(
            Icons.eco_outlined,
            color: Colors.white.withValues(alpha: 0.7),
            size: 16,
          ),
        ),
      );
    } else if (index == 5 || index == 6 || index == 9 || index == 10) {
      // Center pieces - plant pot
      return Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: mediumGreen,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Icon(
            index == 5 || index == 6
                ? Icons.local_florist_outlined
                : Icons.grass_outlined,
            color: Colors.white.withValues(alpha: 0.8),
            size: 16,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: icon != null
          ? Center(
              child: Icon(
                icon,
                color: Colors.white.withValues(alpha: 0.6),
                size: 14,
              ),
            )
          : null,
    );
  }
}
