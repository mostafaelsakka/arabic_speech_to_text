import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:speech_to_text_/screens/speech_to_text_screen.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _particleController;
  late AnimationController _glowController;
  late AnimationController _rotationController;
  late AnimationController _waveController;

  late Animation<double> _fadeIn;
  late Animation<double> _scaleUp;
  late Animation<Offset> _slideUp;
  late Animation<double> _glowPulse;

  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WakelockPlus.enable();
    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 20000),
    )..repeat();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleUp = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _slideUp = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _glowPulse = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  void _startSequence() async {
    setState(() => _currentStep = 0);
    _fadeController.forward();
    _scaleController.forward();
    _slideController.forward();
    await Future.delayed(const Duration(seconds: 8));

    _fadeController.reverse();
    await Future.delayed(const Duration(milliseconds: 1000));

    _fadeController.reset();
    _scaleController.reset();
    _slideController.reset();
    setState(() => _currentStep = 1);
    _fadeController.forward();
    _scaleController.forward();
    _slideController.forward();
    await Future.delayed(const Duration(seconds: 5));

    _fadeController.reverse();
    await Future.delayed(const Duration(milliseconds: 1000));

    _fadeController.reset();
    _scaleController.reset();
    _slideController.reset();
    setState(() => _currentStep = 2);
    _fadeController.forward();
    _scaleController.forward();
    _slideController.forward();
    await Future.delayed(const Duration(seconds: 5));

    _fadeController.reverse();
    await Future.delayed(const Duration(milliseconds: 1000));

    _fadeController.reset();
    _scaleController.reset();
    _slideController.reset();
    setState(() => _currentStep = 3);
    _fadeController.forward();
    _scaleController.forward();
    _slideController.forward();
    await Future.delayed(const Duration(seconds: 10));

    if (mounted) {
      WakelockPlus.disable();
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const SpeechToTextScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 1200),
        ),
      );
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _particleController.dispose();
    _glowController.dispose();
    _rotationController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          _buildAdvancedAnimatedBackground(),
          _buildParticleSystem(),
          _buildFloatingOrbs(),
          SizedBox.expand(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 1000),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.elasticOut,
                      ),
                    ),
                    child: child,
                  ),
                );
              },
              child: _buildCurrentStep(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildProjectTitle();
      case 1:
        return _buildSupervisor();
      case 2:
        return _buildFollowUp();
      case 3:
        return _buildTeamMembers();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAdvancedAnimatedBackground() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.3, -0.5),
              radius: 2.0,
              colors: [
                Color(0xFF1E1E2E),
                Color(0xFF16161F),
                Color(0xFF0D0D12),
                Color(0xFF080809),
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return CustomPaint(
              painter: AdvancedMeshPainter(
                animationValue: _rotationController.value,
              ),
              size: Size.infinite,
            );
          },
        ),
        AnimatedBuilder(
          animation: _waveController,
          builder: (context, child) {
            return CustomPaint(
              painter: WavePainter(animationValue: _waveController.value),
              size: Size.infinite,
            );
          },
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParticleSystem() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          painter: AdvancedParticleSystemPainter(
            animationValue: _particleController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildFloatingOrbs() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return CustomPaint(
          painter: FloatingOrbsPainter(animationValue: _glowController.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildProjectTitle() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final isSmallScreen = screenWidth < 360;
        final isMediumScreen = screenWidth >= 360 && screenWidth < 600;

        return FadeTransition(
          key: const ValueKey('title'),
          opacity: _fadeIn,
          child: ScaleTransition(
            scale: _scaleUp,
            child: SlideTransition(
              position: _slideUp,
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.08,
                      vertical: screenHeight * 0.02,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 1800),
                          curve: Curves.elasticOut,
                          builder: (context, titleValue, child) {
                            return Opacity(
                              opacity: titleValue.clamp(0.0, 1.0),
                              child: Transform.scale(
                                scale: (0.3 + (titleValue * 0.7)).clamp(
                                  0.3,
                                  1.0,
                                ),
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(screenWidth * 0.06),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                isSmallScreen ? 20 : 30,
                              ),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.08),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: const Color(0xFF06FFA5).withOpacity(0.6),
                                width: isSmallScreen ? 2 : 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF06FFA5,
                                  ).withOpacity(0.4),
                                  blurRadius: isSmallScreen ? 25 : 40,
                                  offset: Offset(0, isSmallScreen ? 10 : 15),
                                ),
                                BoxShadow(
                                  color: const Color(
                                    0xFF3A86FF,
                                  ).withOpacity(0.3),
                                  blurRadius: isSmallScreen ? 20 : 30,
                                  offset: Offset(0, isSmallScreen ? 8 : 10),
                                ),
                              ],
                            ),
                            child: ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Color(0xFF06FFA5),
                                  Color(0xFF3A86FF),
                                  Color(0xFF8338EC),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                              child: Text(
                                'Arabic Speech To Text',
                                style: TextStyle(
                                  fontSize: isSmallScreen
                                      ? 28
                                      : (isMediumScreen ? 38 : 46),
                                  fontWeight: FontWeight.w900,
                                  color: const Color.fromARGB(
                                    255,
                                    221,
                                    112,
                                    112,
                                  ),
                                  letterSpacing: isSmallScreen ? -1.0 : -1.5,
                                  height: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 2000),
                          curve: Curves.easeOutCubic,
                          builder: (context, contentValue, child) {
                            return FutureBuilder(
                              future: Future.delayed(
                                const Duration(milliseconds: 2000),
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState !=
                                    ConnectionState.done) {
                                  return const SizedBox.shrink();
                                }
                                return Opacity(
                                  opacity: contentValue.clamp(0.0, 1.0),
                                  child: Transform.translate(
                                    offset: Offset(0, 50 * (1 - contentValue)),
                                    child: Transform.scale(
                                      scale: 0.8 + (0.2 * contentValue),
                                      child: child,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Column(
                            children: [
                              SizedBox(height: isSmallScreen ? 30 : 50),
                              Container(
                                padding: EdgeInsets.all(
                                  isSmallScreen ? 18 : 28,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    isSmallScreen ? 18 : 28,
                                  ),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.18),
                                      Colors.white.withOpacity(0.08),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: isSmallScreen ? 1.5 : 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.4),
                                      blurRadius: isSmallScreen ? 20 : 30,
                                      offset: Offset(
                                        0,
                                        isSmallScreen ? 10 : 15,
                                      ),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (bounds) =>
                                          const LinearGradient(
                                            colors: [
                                              Color(0xFF06FFA5),
                                              Color(0xFF3A86FF),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ).createShader(bounds),
                                      child: Text(
                                        'مشروع تخرج طلاب',
                                        style: TextStyle(
                                          fontSize: isSmallScreen
                                              ? 20
                                              : (isMediumScreen ? 26 : 32),
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: isSmallScreen
                                              ? -0.5
                                              : -0.8,
                                          height: 1.3,
                                          shadows: const [
                                            Shadow(
                                              color: Colors.black26,
                                              blurRadius: 8,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(height: isSmallScreen ? 16 : 24),
                                    Container(
                                      height: isSmallScreen ? 1.5 : 2,
                                      width: isSmallScreen ? 80 : 120,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            Color(0xFF06FFA5),
                                            Color(0xFF3A86FF),
                                            Colors.transparent,
                                          ],
                                          stops: [0.0, 0.3, 0.7, 1.0],
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF06FFA5,
                                            ).withOpacity(0.5),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: isSmallScreen ? 16 : 24),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isSmallScreen ? 12 : 20,
                                        vertical: isSmallScreen ? 10 : 16,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          isSmallScreen ? 12 : 16,
                                        ),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.12),
                                            Colors.white.withOpacity(0.05),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        border: Border.all(
                                          color: const Color(
                                            0xFF06FFA5,
                                          ).withOpacity(0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Text(
                                        'المعهد العالي لتكنولوجيا المعلومات',
                                        style: TextStyle(
                                          fontSize: isSmallScreen
                                              ? 16
                                              : (isMediumScreen ? 20 : 24),
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: isSmallScreen
                                              ? -0.4
                                              : -0.6,
                                          height: 1.4,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(height: isSmallScreen ? 12 : 16),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isSmallScreen ? 12 : 16,
                                        vertical: isSmallScreen ? 8 : 10,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          isSmallScreen ? 16 : 20,
                                        ),
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(
                                              0xFF3A86FF,
                                            ).withOpacity(0.2),
                                            const Color(
                                              0xFF8338EC,
                                            ).withOpacity(0.1),
                                          ],
                                        ),
                                        border: Border.all(
                                          color: const Color(
                                            0xFF3A86FF,
                                          ).withOpacity(0.4),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(
                                              isSmallScreen ? 4 : 6,
                                            ),
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(0xFF3A86FF),
                                                  Color(0xFF8338EC),
                                                ],
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.location_on,
                                              color: Colors.white,
                                              size: isSmallScreen ? 12 : 16,
                                            ),
                                          ),
                                          SizedBox(
                                            width: isSmallScreen ? 6 : 10,
                                          ),
                                          Text(
                                            'بكفر الشيخ',
                                            style: TextStyle(
                                              fontSize: isSmallScreen
                                                  ? 14
                                                  : (isMediumScreen ? 17 : 20),
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF3A86FF),
                                              letterSpacing: -0.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: isSmallScreen ? 14 : 20),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isSmallScreen ? 18 : 28,
                                        vertical: isSmallScreen ? 10 : 14,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          isSmallScreen ? 14 : 18,
                                        ),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF8338EC),
                                            Color(0xFF6366F1),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF8338EC,
                                            ).withOpacity(0.4),
                                            blurRadius: isSmallScreen ? 12 : 16,
                                            spreadRadius: isSmallScreen ? 1 : 2,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.2),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(
                                              isSmallScreen ? 4 : 6,
                                            ),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white.withOpacity(
                                                0.2,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.school_rounded,
                                              color: Colors.white,
                                              size: isSmallScreen ? 14 : 18,
                                            ),
                                          ),
                                          SizedBox(
                                            width: isSmallScreen ? 8 : 12,
                                          ),
                                          Text(
                                            'شعبة علوم الحاسب',
                                            style: TextStyle(
                                              fontSize: isSmallScreen
                                                  ? 14
                                                  : (isMediumScreen ? 17 : 20),
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                              letterSpacing: -0.4,
                                              shadows: const [
                                                Shadow(
                                                  color: Colors.black26,
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSupervisor() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isSmallScreen = screenWidth < 360;
        final isMediumScreen = screenWidth >= 360 && screenWidth < 600;

        return FadeTransition(
          key: const ValueKey('supervisor'),
          opacity: _fadeIn,
          child: ScaleTransition(
            scale: _scaleUp,
            child: SlideTransition(
              position: _slideUp,
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _build3DPhotoFrame(
                        color: const Color(0xFF06FFA5),
                        icon: Icons.person_rounded,
                        imagePath: 'assets/img/shora.jpg',
                        screenWidth: screenWidth,
                      ),
                      SizedBox(height: isSmallScreen ? 30 : 50),
                      _buildGlassContainer(
                        screenWidth: screenWidth,
                        gradient: true,
                        padding: EdgeInsets.all(isSmallScreen ? 20 : 30),
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color(0xFF06FFA5), Color(0xFF3A86FF)],
                              ).createShader(bounds),
                              child: Text(
                                'الإشراف ورئيس القسم',
                                style: TextStyle(
                                  fontSize: isSmallScreen
                                      ? 20
                                      : (isMediumScreen ? 26 : 32),
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 16 : 24),
                            Container(
                              height: 2,
                              width: isSmallScreen ? 60 : 100,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Color(0xFF06FFA5),
                                    Color(0xFF3A86FF),
                                    Colors.transparent,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 16 : 24),
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Color(0xFF06FFA5),
                                  Color(0xFF3A86FF),
                                  Color(0xFF8338EC),
                                ],
                              ).createShader(bounds),
                              child: Text(
                                'ا.د : عمرو ابراهيم الشورى',
                                'د : أحمد الطوخى',
                                style: TextStyle(
                                  fontSize: isSmallScreen
                                      ? 22
                                      : (isMediumScreen ? 28 : 36),
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: isSmallScreen ? -0.6 : -1.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFollowUp() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isSmallScreen = screenWidth < 360;
        final isMediumScreen = screenWidth >= 360 && screenWidth < 600;

        return FadeTransition(
          key: const ValueKey('followup'),
          opacity: _fadeIn,
          child: ScaleTransition(
            scale: _scaleUp,
            child: SlideTransition(
              position: _slideUp,
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _build3DPhotoFrame(
                          color: const Color(0xFFFF006E),
                          icon: Icons.engineering_rounded,
                          screenWidth: screenWidth,
                        ),
                        SizedBox(height: isSmallScreen ? 40 : 60),
                        _buildGlassContainer(
                          screenWidth: screenWidth,
                          gradient: true,
                          padding: EdgeInsets.all(isSmallScreen ? 24 : 36),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                      colors: [
                                        Color(0xFFFF006E),
                                        Color(0xFFFF5E78),
                                      ],
                                    ).createShader(bounds),
                                child: Text(
                                  'المتابعة',
                                  style: TextStyle(
                                    fontSize: isSmallScreen
                                        ? 22
                                        : (isMediumScreen ? 28 : 36),
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 16 : 24),
                              Container(
                                height: 2,
                                width: isSmallScreen ? 60 : 100,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Color(0xFFFF006E),
                                      Color(0xFFFF5E78),
                                      Colors.transparent,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 16 : 24),
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                      colors: [
                                        Color(0xFF8338EC),
                                        Color(0xFFFF006E),
                                        Color(0xFFFF5E78),
                                      ],
                                    ).createShader(bounds),
                                child: Text(
                                  'المهندسه : روان',
                                  style: TextStyle(
                                    fontSize: isSmallScreen
                                        ? 24
                                        : (isMediumScreen ? 32 : 40),
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: isSmallScreen ? -0.6 : -1.0,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTeamMembers() {
    final teamMembers = [
      'منصور مبروك شحاته',
      'اسامه محمد جاويش',
      'حازم فتحي الغندور',
      'مصطفي السيد السقا',
      'يوسف محمد صبيحه',
      'اسماء السيد عيسي',
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isSmallScreen = screenWidth < 360;
        final isMediumScreen = screenWidth >= 360 && screenWidth < 600;

        return FadeTransition(
          key: const ValueKey('team'),
          opacity: _fadeIn,
          child: ScaleTransition(
            scale: _scaleUp,
            child: SlideTransition(
              position: _slideUp,
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.08,
                    ),
                    child: _buildGlassContainer(
                      screenWidth: screenWidth,
                      gradient: true,
                      padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Color(0xFFFF006E),
                                Color(0xFF8338EC),
                                Color(0xFF3A86FF),
                                Color(0xFF06FFA5),
                              ],
                            ).createShader(bounds),
                            child: Text(
                              'إعداد المهندسين',
                              style: TextStyle(
                                fontSize: isSmallScreen
                                    ? 20
                                    : (isMediumScreen ? 25 : 30),
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: isSmallScreen ? -0.6 : -1.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 20 : 28),
                          Container(
                            height: 2,
                            width: isSmallScreen ? 80 : 120,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Color(0xFF06FFA5),
                                  Color(0xFF3A86FF),
                                  Colors.transparent,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 20 : 28),
                          ...teamMembers.asMap().entries.map((entry) {
                            final index = entry.key;
                            final name = entry.value;
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: isSmallScreen ? 12 : 16,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: isSmallScreen ? 8 : 10,
                                    height: isSmallScreen ? 8 : 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          [
                                            const Color(0xFFFF006E),
                                            const Color(0xFF8338EC),
                                            const Color(0xFF3A86FF),
                                            const Color(0xFF06FFA5),
                                            const Color(0xFFFF5E78),
                                            const Color(0xFF9D4EDD),
                                          ][index],
                                          Colors.white,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: [
                                            const Color(0xFFFF006E),
                                            const Color(0xFF8338EC),
                                            const Color(0xFF3A86FF),
                                            const Color(0xFF06FFA5),
                                            const Color(0xFFFF5E78),
                                            const Color(0xFF9D4EDD),
                                          ][index].withOpacity(0.6),
                                          blurRadius: isSmallScreen ? 6 : 8,
                                          spreadRadius: isSmallScreen ? 1 : 1.5,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: isSmallScreen ? 12 : 16),
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: isSmallScreen
                                            ? 20
                                            : (isMediumScreen ? 22 : 24),
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: -0.3,
                                        height: 1.3,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _build3DPhotoFrame({
    required Color color,
    required IconData icon,
    String? imagePath,
    required double screenWidth,
  }) {
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;

    final photoSize = isSmallScreen ? 225.0 : (isMediumScreen ? 215.0 : 245.0);
    final iconSize = isSmallScreen ? 55.0 : (isMediumScreen ? 65.0 : 75.0);
    final borderWidth = isSmallScreen ? 2.0 : 4.0;

    return AnimatedBuilder(
      animation: Listenable.merge([_glowController, _rotationController]),
      builder: (context, child) {
        final safeGlow = _glowPulse.value.clamp(0.0, 1.0);

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(math.sin(_rotationController.value * 2 * math.pi) * 0.08)
            ..rotateX(math.cos(_rotationController.value * 2 * math.pi) * 0.08),
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [color, color.withOpacity(0.6)]),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity((0.7 * safeGlow).clamp(0.0, 1.0)),
                  blurRadius: (isSmallScreen ? 35 : 50) * safeGlow,
                  spreadRadius: (isSmallScreen ? 7 : 10) * safeGlow,
                ),
              ],
            ),
            child: Container(
              width: photoSize,
              height: photoSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A1A2E),
                border: Border.all(
                  color: const Color(0xFF0A0A0F),
                  width: borderWidth,
                ),
              ),
              child: ClipOval(
                child: imagePath != null
                    ? Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            icon,
                            size: iconSize,
                            color: Colors.white.withOpacity(0.9),
                            shadows: [
                              Shadow(
                                color: color.withOpacity(0.5),
                                blurRadius: isSmallScreen ? 15 : 20,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          );
                        },
                      )
                    : Icon(
                        icon,
                        size: iconSize,
                        color: Colors.white.withOpacity(0.9),
                        shadows: [
                          Shadow(
                            color: color.withOpacity(0.5),
                            blurRadius: isSmallScreen ? 15 : 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassContainer({
    required Widget child,
    required double screenWidth,
    bool gradient = false,
    EdgeInsets? padding,
  }) {
    final isSmallScreen = screenWidth < 360;

    final defaultPadding = EdgeInsets.symmetric(
      horizontal: screenWidth * 0.08,
      vertical: isSmallScreen ? 16 : 24,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding ?? defaultPadding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 28),
            gradient: LinearGradient(
              colors: gradient
                  ? [
                      Colors.white.withOpacity(0.25),
                      Colors.white.withOpacity(0.10),
                    ]
                  : [
                      Colors.white.withOpacity(0.18),
                      Colors.white.withOpacity(0.08),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: isSmallScreen ? 2 : 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: isSmallScreen ? 30 : 40,
                offset: Offset(0, isSmallScreen ? 15 : 20),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ============== CUSTOM PAINTERS ==============

class AdvancedMeshPainter extends CustomPainter {
  final double animationValue;
  AdvancedMeshPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final colors = [
      const Color(0xFFFF006E),
      const Color(0xFF8338EC),
      const Color(0xFF3A86FF),
      const Color(0xFF06FFA5),
    ];

    for (int i = 0; i < 4; i++) {
      final xOffset = math.cos(animationValue * 2 * math.pi + i) * 120;
      final yOffset = math.sin(animationValue * 2 * math.pi + i) * 120;

      paint.shader =
          RadialGradient(
            colors: [
              colors[i].withOpacity(0.35),
              colors[i].withOpacity(0.15),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(
                size.width * (0.25 + (i % 2) * 0.5) + xOffset,
                size.height * (0.25 + (i ~/ 2) * 0.5) + yOffset,
              ),
              radius: 220,
            ),
          );

      canvas.drawCircle(
        Offset(
          size.width * (0.25 + (i % 2) * 0.5) + xOffset,
          size.height * (0.25 + (i ~/ 2) * 0.5) + yOffset,
        ),
        220,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(AdvancedMeshPainter oldDelegate) => true;
}

class WavePainter extends CustomPainter {
  final double animationValue;
  WavePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 5; i++) {
      final path = Path();
      final yPos = size.height * (0.2 + i * 0.15);

      path.moveTo(0, yPos);

      for (double x = 0; x <= size.width; x += 5) {
        final y =
            yPos +
            30 *
                math.sin(
                  (x / size.width) * 3 * math.pi +
                      animationValue * 2 * math.pi +
                      i * 0.5,
                );
        path.lineTo(x, y);
      }

      paint.color = const Color(0xFF06FFA5).withOpacity(0.15 * (1 - i / 5));

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}

class AdvancedParticleSystemPainter extends CustomPainter {
  final double animationValue;
  AdvancedParticleSystemPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final particleCount = 60;
    final colors = [
      const Color(0xFFFF006E),
      const Color(0xFF8338EC),
      const Color(0xFF3A86FF),
      const Color(0xFF06FFA5),
    ];

    for (int i = 0; i < particleCount; i++) {
      final seed = i * 7919;
      final baseX = (seed % size.width.toInt()).toDouble();
      final baseY = (seed % size.height.toInt()).toDouble();

      final x =
          (baseX + math.sin(animationValue * 2 * math.pi + i * 0.1) * 50) %
          size.width;
      final y =
          (baseY +
              animationValue * size.height * 0.6 +
              i * (size.height / particleCount)) %
          size.height;

      final color = colors[i % colors.length];
      final particleSize = 2.5 + math.sin(animationValue * math.pi + i) * 1.5;

      paint.color = color.withOpacity(0.4);
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(AdvancedParticleSystemPainter oldDelegate) => true;
}

class FloatingOrbsPainter extends CustomPainter {
  final double animationValue;
  FloatingOrbsPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final orbs = [
      {'color': const Color(0xFFFF006E), 'x': 0.15, 'y': 0.25, 'size': 200.0},
      {'color': const Color(0xFF8338EC), 'x': 0.85, 'y': 0.75, 'size': 180.0},
      {'color': const Color(0xFF06FFA5), 'x': 0.5, 'y': 0.5, 'size': 220.0},
    ];

    for (var orb in orbs) {
      final x =
          size.width * (orb['x'] as double) +
          math.cos(animationValue * 2 * math.pi) * 80;
      final y =
          size.height * (orb['y'] as double) +
          math.sin(animationValue * 2 * math.pi) * 80;

      paint.shader =
          RadialGradient(
            colors: [
              (orb['color'] as Color).withOpacity(0.4),
              (orb['color'] as Color).withOpacity(0.2),
              (orb['color'] as Color).withOpacity(0.1),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(x, y),
              radius: orb['size'] as double,
            ),
          );

      canvas.drawCircle(Offset(x, y), orb['size'] as double, paint);
    }
  }

  @override
  bool shouldRepaint(FloatingOrbsPainter oldDelegate) => true;
}
