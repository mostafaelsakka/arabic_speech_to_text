import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'dart:io';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

class SpeechToTextScreen extends StatefulWidget {
  const SpeechToTextScreen({Key? key}) : super(key: key);

  @override
  State<SpeechToTextScreen> createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen>
    with TickerProviderStateMixin {
  late stt.SpeechToText _speech;

  // Animation Controllers
  late AnimationController _micPulseController;
  late AnimationController _entryAnimationController;
  late AnimationController _progressController;
  late AnimationController _floatingController;
  late AnimationController _rippleController;
  late AnimationController _shimmerController;
  late AnimationController _particleController;
  late AnimationController _waveController;
  late AnimationController _breathingController;
  late AnimationController _glowController;
  late AnimationController _morphController;

  // Animations
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _breathingAnimation;
  late Animation<double> _glowAnimation;

  final Dio _dio = Dio();
  CancelToken? _cancelToken;

  bool _isListening = false;
  bool _isInitialized = false;
  bool _isUploading = false;
  String _recognizedText = '';
  double _confidence = 0.0;
  String? _selectedFilePath;
  String? _selectedFileName;
  Timer? _recordingTimer;
  int _recordingDuration = 0;
  Timer? _countdownTimer;
  int _countdownSeconds = 180;

  static const int maxDuration = 300;

  String _selectedLocale = 'ar-EG';
  final Map<String, String> _availableLocales = {
    'ar-SA': '🇸🇦 السعودية',
    'ar-EG': '🇪🇬 مصر',
    'ar-AE': '🇦🇪 الإمارات',
    'ar-JO': '🇯🇴 الأردن',
    'ar-LB': '🇱🇧 لبنان',
    'ar-MA': '🇲🇦 المغرب',
    'ar-TN': '🇹🇳 تونس',
    'ar-DZ': '🇩🇿 الجزائر',
    'ar-IQ': '🇮🇶 العراق',
    'ar-KW': '🇰🇼 الكويت',
    'ar-YE': '🇾🇪 اليمن',
    'ar-SY': '🇸🇾 سوريا',
  };

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    // تفعيل منع غلق الشاشة
    WakelockPlus.enable();
    _initializeSpeech();
    _setupAdvancedAnimations();
  }

  void _setupAdvancedAnimations() {
    _micPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _entryAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )..repeat();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _micPulseController, curve: Curves.elasticOut),
    );

    _floatingAnimation = Tween<double>(begin: -20, end: 20).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOutSine),
    );

    _shimmerAnimation = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _breathingAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _entryAnimationController.forward();
  }

  @override
  void dispose() {
    // إيقاف منع غلق الشاشة
    WakelockPlus.disable();
    _recordingTimer?.cancel();
    _countdownTimer?.cancel();
    _micPulseController.dispose();
    _entryAnimationController.dispose();
    _progressController.dispose();
    _floatingController.dispose();
    _rippleController.dispose();
    _shimmerController.dispose();
    _particleController.dispose();
    _waveController.dispose();
    _breathingController.dispose();
    _glowController.dispose();
    _morphController.dispose();
    super.dispose();
  }

  Future<void> _initializeSpeech() async {
    bool available = await _speech.initialize(
      onError: (error) =>
          _showSnackBar('خطأ: ${error.errorMsg}', isError: true),
      onStatus: (status) {
        if (status == 'done' && _isListening) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && _isListening) {
              _stopListening();
            }
          });
        }
      },
    );
    if (mounted) {
      setState(() => _isInitialized = available);
    }
    if (!available) {
      _showSnackBar('خدمة التعرف على الصوت غير متاحة', isError: true);
    }
  }

  Future<void> _startListening() async {
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      _showSnackBar('يجب السماح بالوصول للميكروفون', isError: true);
      return;
    }

    if (!_isInitialized) {
      _showSnackBar('الخدمة غير جاهزة، يرجى الانتظار', isError: true);
      return;
    }

    // تفعيل wakelock عند بدء التسجيل
    WakelockPlus.enable();

    setState(() {
      _recognizedText = '';
      _confidence = 0.0;
      _recordingDuration = 0;
    });

    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _recordingDuration++);
      }
      if (_recordingDuration >= maxDuration) {
        _stopListening();
        _showSnackBar('تم الوصول للحد الأقصى (5 دقائق)', isError: true);
      }
    });

    await _speech.listen(
      onResult: (result) {
        if (mounted) {
          setState(() {
            _recognizedText = result.recognizedWords;
            if (result.finalResult) {
              _confidence = result.confidence;
            }
          });
        }
      },
      listenFor: const Duration(minutes: 5),
      pauseFor: const Duration(seconds: 10),
      partialResults: true,
      localeId: _selectedLocale,
      cancelOnError: false,
      listenMode: stt.ListenMode.dictation,
    );

    setState(() => _isListening = true);
    _micPulseController.repeat(reverse: true);
    _morphController.forward();
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    _recordingTimer?.cancel();
    if (mounted) {
      setState(() => _isListening = false);
      _micPulseController.stop();
      _micPulseController.value = 0.0;
      _morphController.reverse();
    }
  }

  Future<void> _pickAudioFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        String filePath = result.files.single.path!;
        String fileName = result.files.single.name;
        File audioFile = File(filePath);

        int fileSize = await audioFile.length();
        if (fileSize > 25 * 1024 * 1024) {
          _showSnackBar(
            'حجم الملف كبير جداً. يرجى اختيار ملف أقل من 25 ميجابايت',
            isError: true,
          );
          return;
        }

        setState(() {
          _selectedFilePath = filePath;
          _selectedFileName = fileName;
        });

        _showSnackBar('تم اختيار الملف: $fileName');
        await _uploadAndTranscribe();
      }
    } catch (e) {
      _showSnackBar('خطأ في اختيار الملف: $e', isError: true);
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _countdownSeconds = 180);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_countdownSeconds > 0) {
          _countdownSeconds--;
        } else {
          _countdownSeconds = 180;
        }
      });
    });
  }

  Future<void> _uploadAndTranscribe() async {
    if (_selectedFilePath == null) return;

    const apiUrl =
        'https://010mansour-arabic-speech-to-text-api.hf.space/transcribe';
    _cancelToken = CancelToken();

    // تفعيل wakelock عند بدء الرفع
    WakelockPlus.enable();

    setState(() {
      _isUploading = true;
      _recognizedText = '';
      _confidence = 0.0;
    });

    _startCountdown();
    _morphController.forward();

    try {
      String fileName = _selectedFileName ?? 'audio.tmp';
      FormData formData = FormData.fromMap({
        "audio": await MultipartFile.fromFile(
          _selectedFilePath!,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        apiUrl,
        data: formData,
        cancelToken: _cancelToken,
        options: Options(receiveTimeout: const Duration(minutes: 5)),
      );

      if (response.statusCode == 200) {
        if (response.data is Map<String, dynamic>) {
          final jsonResponse = response.data as Map<String, dynamic>;
          final originalText = jsonResponse['text']?.toString() ?? '';

          if (mounted) {
            setState(() {
              _recognizedText = originalText;
              _confidence = 0.95;
            });
            _showSnackBar('تم التحويل بنجاح ✓', isSuccess: true);
          }
        } else {
          throw Exception('استجابة غير متوقعة من الخادم');
        }
      } else {
        throw Exception('فشل في تحويل الملف: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        _showSnackBar('تم إلغاء العملية');
        return;
      }
      String errorMessage = "حدث خطأ في الشبكة.";
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        final errorData = e.response!.data as Map<String, dynamic>;
        errorMessage = "خطأ من الخادم: ${errorData['error'] ?? e.message}";
      } else if (e.response != null) {
        errorMessage = "خطأ من الخادم: ${e.response?.statusCode}";
      } else {
        errorMessage = "خطأ في الاتصال بالخادم: ${e.message}";
      }
      _showSnackBar(errorMessage, isError: true);
    } catch (e) {
      _showSnackBar('خطأ غير متوقع: $e', isError: true);
    } finally {
      _countdownTimer?.cancel();
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        _morphController.reverse();
      }
    }
  }

  void _cancelUpload() {
    _cancelToken?.cancel();
    _countdownTimer?.cancel();
  }

  void _clearText() {
    setState(() {
      _recognizedText = '';
      _confidence = 0.0;
      _selectedFilePath = null;
      _selectedFileName = null;
    });
  }

  void _copyToClipboard() {
    if (_recognizedText.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _recognizedText));
      _showSnackBar('تم نسخ النص بنجاح ✓', isSuccess: true);
    }
  }

  void _showLocaleDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Locale Selection',
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          child: FadeTransition(
            opacity: animation,
            child: _buildLocaleDialogContent(),
          ),
        );
      },
    );
  }

  Widget _buildLocaleDialogContent() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;

    return Center(
      child: _buildAdvancedGlassContainer(
        padding: EdgeInsets.all(
          isSmallScreen ? 20 : (isMediumScreen ? 26 : 32),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _buildGlowingIcon(
                    icon: Icons.language_rounded,
                    colors: const [Color(0xFF667EEA), Color(0xFF764BA2)],
                    size: isSmallScreen ? 40 : (isMediumScreen ? 45 : 50),
                  ),
                  SizedBox(width: isSmallScreen ? 12 : 20),
                  Expanded(
                    child: Text(
                      'اختر اللهجة',
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? 22
                            : (isMediumScreen ? 28 : 32),
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: isSmallScreen ? -0.6 : -1.0,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 16 : 28),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _availableLocales.length,
                  itemBuilder: (context, index) {
                    String localeCode = _availableLocales.keys.elementAt(index);
                    String localeName = _availableLocales[localeCode]!;
                    bool isSelected = localeCode == _selectedLocale;

                    return _buildStaggeredLocaleItem(
                      index: index,
                      localeCode: localeCode,
                      localeName: localeName,
                      isSelected: isSelected,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStaggeredLocaleItem({
    required int index,
    required String localeCode,
    required String localeName,
    required bool isSelected,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 60)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(60 * (1 - value), 0),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedLocale = localeCode);
          Navigator.of(context).pop();
          _showSnackBar('تم اختيار لهجة: $localeName', isSuccess: true);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          margin: EdgeInsets.only(bottom: isSmallScreen ? 10 : 16),
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16 : (isMediumScreen ? 20 : 24),
            vertical: isSmallScreen ? 14 : (isMediumScreen ? 17 : 20),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 24),
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.white.withOpacity(0.08),
            border: Border.all(
              color: isSelected
                  ? Colors.white.withOpacity(0.4)
                  : Colors.white.withOpacity(0.15),
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF667EEA).withOpacity(0.7),
                      blurRadius: isSmallScreen ? 15 : 25,
                      offset: Offset(0, isSmallScreen ? 6 : 10),
                      spreadRadius: isSmallScreen ? 2 : 3,
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localeName,
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : (isMediumScreen ? 18 : 20),
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
              ),
              AnimatedScale(
                scale: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.elasticOut,
                child: Container(
                  padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: isSmallScreen ? 18 : 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(
    String message, {
    bool isError = false,
    bool isSuccess = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isError
                    ? Icons.error_outline_rounded
                    : (isSuccess
                          ? Icons.check_circle_outline_rounded
                          : Icons.info_outline_rounded),
                color: Colors.white,
                size: isSmallScreen ? 20 : 28,
              ),
            ),
            SizedBox(width: isSmallScreen ? 12 : 18),
            Expanded(
              child: Text(
                message,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError
            ? const Color(0xFFEB3678)
            : (isSuccess ? const Color(0xFF06D6A0) : const Color(0xFF667EEA)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 24),
        ),
        margin: EdgeInsets.all(isSmallScreen ? 16 : 24),
        duration: const Duration(seconds: 3),
        elevation: 15,
      ),
    );
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0F),
        body: Stack(
          children: [
            _buildAdvancedAnimatedBackground(),
            _buildAdvancedParticleSystem(),
            SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildProHeader()),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen
                          ? 16
                          : (isMediumScreen ? 20 : 24),
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate.fixed([
                        SizedBox(
                          height: isSmallScreen
                              ? 16
                              : (isMediumScreen ? 28 : 40),
                        ),
                        _buildStaggeredItem(0, _buildProLocaleCard()),
                        SizedBox(
                          height: isSmallScreen
                              ? 12
                              : (isMediumScreen ? 18 : 24),
                        ),
                        _buildStaggeredItem(1, _buildRecordingStatusCard()),
                        SizedBox(
                          height: isSmallScreen
                              ? 12
                              : (isMediumScreen ? 18 : 24),
                        ),
                        _buildStaggeredItem(2, _buildProControlButtons()),
                        SizedBox(
                          height: isSmallScreen
                              ? 16
                              : (isMediumScreen ? 24 : 32),
                        ),
                        _buildStaggeredItem(3, _buildProTextOutputCard()),
                        SizedBox(
                          height: isSmallScreen
                              ? 12
                              : (isMediumScreen ? 18 : 24),
                        ),
                        if (_recognizedText.isNotEmpty)
                          _buildStaggeredItem(4, _buildProActionButtons()),
                        SizedBox(
                          height: isSmallScreen
                              ? 24
                              : (isMediumScreen ? 36 : 50),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaggeredItem(int index, Widget child) {
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryAnimationController,
        curve: Interval(
          (0.08 * index).clamp(0.0, 1.0),
          (0.4 + 0.08 * index).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - animation.value)),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
      child: child,
    );
  }

  Widget _buildAdvancedAnimatedBackground() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1E), Color(0xFF0A0A0F)],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _floatingController,
          builder: (context, child) {
            return CustomPaint(
              painter: SimpleOrbsPainter(
                animationValue: _floatingController.value,
              ),
              size: Size.infinite,
            );
          },
        ),
        if (_isListening)
          AnimatedBuilder(
            animation: _rippleController,
            builder: (context, child) {
              return CustomPaint(
                painter: SimpleSoundWavesPainter(
                  animationValue: _rippleController.value,
                ),
                size: Size.infinite,
              );
            },
          ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
          child: Container(color: Colors.transparent),
        ),
      ],
    );
  }

  Widget _buildAdvancedParticleSystem() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          painter: AdvancedParticlesPainter(
            animationValue: _particleController.value,
            isListening: _isListening,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildProHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        screenWidth * 0.05,
        isSmallScreen ? 16 : (isMediumScreen ? 24 : 32),
        screenWidth * 0.05,
        isSmallScreen ? 12 : 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedBuilder(
                  animation: _shimmerAnimation,
                  builder: (context, child) {
                    return ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: const [
                          Color(0xFFFF006E),
                          Color(0xFF8338EC),
                          Color(0xFF3A86FF),
                          Color(0xFF06FFA5),
                        ],
                        stops: [
                          (_shimmerAnimation.value - 0.4).clamp(0.0, 1.0),
                          (_shimmerAnimation.value - 0.2).clamp(0.0, 1.0),
                          _shimmerAnimation.value.clamp(0.0, 1.0),
                          (_shimmerAnimation.value + 0.2).clamp(0.0, 1.0),
                        ],
                      ).createShader(bounds),
                      child: Text(
                        'تحويل الصوت',
                        style: TextStyle(
                          fontSize: isSmallScreen
                              ? 28
                              : (isMediumScreen ? 36 : 42),
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: isSmallScreen ? -1.0 : -1.5,
                          height: 1.1,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Row(
                      children: [
                        Container(
                          width: isSmallScreen ? 8 : 12,
                          height: isSmallScreen ? 8 : 12,
                          decoration: BoxDecoration(
                            color: const Color(0xFF06FFA5),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF06FFA5,
                                ).withOpacity(_glowAnimation.value),
                                blurRadius: 15 * _glowAnimation.value,
                                spreadRadius: 3 * _glowAnimation.value,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 8 : 12),
                        Text(
                          'مدعوم بالذكاء الاصطناعي',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 16,
                            color: const Color(0xFFB8B8D1),
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _breathingAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _breathingAnimation.value,
                child: _buildGlowingIcon(
                  icon: Icons.language_rounded,
                  colors: const [Color(0xFF8338EC), Color(0xFFFF006E)],
                  size: isSmallScreen ? 40 : (isMediumScreen ? 48 : 56),
                  onTap: _showLocaleDialog,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGlowingIcon({
    required IconData icon,
    required List<Color> colors,
    required double size,
    VoidCallback? onTap,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.35),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.6),
            blurRadius: size * 0.4,
            offset: Offset(0, size * 0.18),
            spreadRadius: size * 0.04,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(size * 0.35),
          child: Center(
            child: Icon(icon, color: Colors.white, size: size * 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildProLocaleCard() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;

    return AnimatedSize(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, -0.3),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
        child: (_isListening || _isUploading || _recognizedText.isNotEmpty)
            ? const SizedBox.shrink(key: ValueKey('hidden_locale'))
            : AnimatedBuilder(
                key: const ValueKey('locale_card'),
                animation: _floatingAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatingAnimation.value * 0.5),
                    child: child,
                  );
                },
                child: GestureDetector(
                  onTap: _showLocaleDialog,
                  child: _buildAdvancedGlassContainer(
                    child: Row(
                      children: [
                        _buildGlowingIcon(
                          icon: Icons.flag_rounded,
                          colors: const [Color(0xFFFF006E), Color(0xFFFF5E78)],
                          size: isSmallScreen ? 48 : (isMediumScreen ? 56 : 64),
                        ),
                        SizedBox(width: isSmallScreen ? 16 : 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'اللهجة المختارة',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 11 : 14,
                                  color: Colors.white.withOpacity(0.6),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 4 : 8),
                              Text(
                                _availableLocales[_selectedLocale]!,
                                style: TextStyle(
                                  fontSize: isSmallScreen
                                      ? 18
                                      : (isMediumScreen ? 21 : 24),
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.7,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _breathingAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _breathingAnimation.value,
                              child: Container(
                                padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white70,
                                  size: isSmallScreen ? 16 : 20,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildRecordingStatusCard() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(
            scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: _isListening
            ? _buildAdvancedRecordingCard()
            : _isUploading
            ? _buildAdvancedUploadingCard()
            : const SizedBox.shrink(key: ValueKey('empty')),
      ),
    );
  }

  Widget _buildAdvancedRecordingCard() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;

    return GestureDetector(
      onTap: _stopListening,
      child: _buildAdvancedGlassContainer(
        key: const ValueKey('recording'),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: isSmallScreen ? 70 : (isMediumScreen ? 85 : 100),
                  height: isSmallScreen ? 70 : (isMediumScreen ? 85 : 100),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      for (int i = 0; i < 3; i++)
                        AnimatedBuilder(
                          animation: _rippleController,
                          builder: (context, child) {
                            final delayedValue =
                                ((_rippleController.value + (i * 0.33)) % 1.0);
                            final circleSize = isSmallScreen
                                ? 70 + (delayedValue * 40)
                                : (isMediumScreen
                                      ? 85 + (delayedValue * 50)
                                      : 100 + (delayedValue * 60));
                            return Container(
                              width: circleSize,
                              height: circleSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: [
                                    const Color(0xFFFF006E),
                                    const Color(0xFF8338EC),
                                    const Color(0xFF3A86FF),
                                  ][i].withOpacity(1 - delayedValue),
                                  width: 3,
                                ),
                              ),
                            );
                          },
                        ),
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          width: isSmallScreen
                              ? 60
                              : (isMediumScreen ? 75 : 90),
                          height: isSmallScreen
                              ? 60
                              : (isMediumScreen ? 75 : 90),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF006E), Color(0xFFFF5E78)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF006E).withOpacity(0.8),
                                blurRadius: isSmallScreen ? 25 : 40,
                                spreadRadius: isSmallScreen ? 5 : 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.mic,
                            color: Colors.white,
                            size: isSmallScreen
                                ? 32
                                : (isMediumScreen ? 38 : 45),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: isSmallScreen ? 16 : 28),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'جاري التسجيل...',
                        style: TextStyle(
                          fontSize: isSmallScreen
                              ? 18
                              : (isMediumScreen ? 22 : 26),
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.7,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 12),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 12 : 20,
                          vertical: isSmallScreen ? 8 : 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFF006E).withOpacity(0.2),
                              const Color(0xFF8338EC).withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(
                            isSmallScreen ? 12 : 16,
                          ),
                          border: Border.all(
                            color: const Color(0xFFFF006E).withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return Text(
                              '${_formatDuration(_recordingDuration)} / 05:00',
                              style: TextStyle(
                                fontSize: isSmallScreen
                                    ? 16
                                    : (isMediumScreen ? 19 : 22),
                                color: Colors.white.withOpacity(
                                  0.7 + (_glowAnimation.value * 0.3),
                                ),
                                fontWeight: FontWeight.w800,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                                letterSpacing: 1.0,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  color: Colors.white.withOpacity(0.5),
                  size: isSmallScreen ? 14 : 18,
                ),
                SizedBox(width: isSmallScreen ? 6 : 8),
                Text(
                  'اضغط هنا لإيقاف التسجيل',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : 14,
                    color: Colors.white.withOpacity(0.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedUploadingCard() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;

    return _buildAdvancedGlassContainer(
      key: const ValueKey('uploading'),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: isSmallScreen ? 50 : (isMediumScreen ? 60 : 70),
                height: isSmallScreen ? 50 : (isMediumScreen ? 60 : 70),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    RotationTransition(
                      turns: _progressController,
                      child: CustomPaint(
                        size: Size(
                          isSmallScreen ? 50 : (isMediumScreen ? 60 : 70),
                          isSmallScreen ? 50 : (isMediumScreen ? 60 : 70),
                        ),
                        painter: AdvancedProgressPainter(
                          progress: 1.0,
                          strokeWidth: isSmallScreen ? 4 : 6,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.cloud_upload_rounded,
                      color: Colors.white,
                      size: isSmallScreen ? 24 : (isMediumScreen ? 28 : 32),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isSmallScreen ? 16 : 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedFileName ?? 'ملف صوتي',
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? 16
                            : (isMediumScreen ? 18 : 20),
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: isSmallScreen ? 4 : 8),
                    Text(
                      'جاري المعالجة...',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 15,
                        color: const Color(0xFFB8B8D1),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 20,
                  vertical: isSmallScreen ? 8 : 12,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF06FFA5), Color(0xFF3A86FF)],
                  ),
                  borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF06FFA5).withOpacity(0.6),
                      blurRadius: isSmallScreen ? 12 : 20,
                      offset: Offset(0, isSmallScreen ? 5 : 8),
                    ),
                  ],
                ),
                child: Text(
                  _formatDuration(_countdownSeconds),
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : (isMediumScreen ? 19 : 22),
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 24),
          _buildProButton(
            onPressed: _cancelUpload,
            label: 'إلغاء العملية',
            icon: Icons.close_rounded,
            colors: const [Color(0xFFFF006E), Color(0xFFFF5E78)],
          ),
        ],
      ),
    );
  }

  Widget _buildProControlButtons() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.4),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
        child: (_isListening || _isUploading || _recognizedText.isNotEmpty)
            ? const SizedBox.shrink(key: ValueKey('hidden_buttons'))
            : _buildDefaultControlButtons(),
      ),
    );
  }

  Widget _buildDefaultControlButtons() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Row(
      key: const ValueKey('default_buttons'),
      children: [
        Expanded(
          child: _buildProButton(
            onPressed: _startListening,
            label: 'تسجيل',
            icon: Icons.mic_rounded,
            colors: const [Color(0xFFFF006E), Color(0xFF8338EC)],
          ),
        ),
        SizedBox(width: isSmallScreen ? 12 : 18),
        Expanded(
          child: _buildProButton(
            onPressed: _pickAudioFile,
            label: 'رفع ملف',
            icon: Icons.upload_file_rounded,
            colors: const [Color(0xFF06FFA5), Color(0xFF3A86FF)],
          ),
        ),
      ],
    );
  }

  Widget _buildProButton({
    Key? key,
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
    required List<Color> colors,
    bool fullWidth = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;

    return Container(
      key: key,
      height: isSmallScreen ? 56 : (isMediumScreen ? 66 : 76),
      width: fullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isSmallScreen ? 18 : 26),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.6),
            blurRadius: isSmallScreen ? 20 : 30,
            offset: Offset(0, isSmallScreen ? 10 : 15),
            spreadRadius: isSmallScreen ? 2 : 3,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(isSmallScreen ? 18 : 26),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 7 : 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: isSmallScreen ? 20 : (isMediumScreen ? 24 : 28),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 10 : 16),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : (isMediumScreen ? 18 : 20),
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProTextOutputCard() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;

    return _buildAdvancedGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.text_fields_rounded,
                    color: Colors.white70,
                    size: isSmallScreen ? 22 : (isMediumScreen ? 26 : 30),
                  ),
                  SizedBox(width: isSmallScreen ? 10 : 16),
                  Text(
                    'النص المحول',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 18 : (isMediumScreen ? 22 : 26),
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.7,
                    ),
                  ),
                ],
              ),
              if (_recognizedText.isNotEmpty)
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12 : 20,
                        vertical: isSmallScreen ? 8 : 14,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _confidence > 0.7
                              ? [
                                  const Color(0xFF06FFA5),
                                  const Color(0xFF3A86FF),
                                ]
                              : [
                                  const Color(0xFFFB8500),
                                  const Color(0xFFFF006E),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(
                          isSmallScreen ? 14 : 20,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (_confidence > 0.7
                                        ? const Color(0xFF06FFA5)
                                        : const Color(0xFFFB8500))
                                    .withOpacity(
                                      0.4 + (_glowAnimation.value * 0.3),
                                    ),
                            blurRadius: isSmallScreen ? 12 : 20,
                            offset: Offset(0, isSmallScreen ? 5 : 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: Colors.white,
                            size: isSmallScreen ? 16 : 22,
                          ),
                          SizedBox(width: isSmallScreen ? 6 : 10),
                          Text(
                            'دقة ${(_confidence * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 14 : 20),
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 24),
          Container(
            constraints: BoxConstraints(
              minHeight: isSmallScreen ? 120 : (isMediumScreen ? 150 : 180),
            ),
            padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 24),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: SelectableText(
              _recognizedText.isEmpty
                  ? 'ابدأ التسجيل أو اختر ملفاً صوتياً ليظهر النص المحول هنا ✨'
                  : _recognizedText,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : (isMediumScreen ? 18 : 21),
                height: 2.5,
                fontWeight: FontWeight.w600,
                color: _recognizedText.isEmpty
                    ? Colors.white.withOpacity(0.4)
                    : Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProActionButtons() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Row(
      children: [
        Expanded(
          child: _buildOutlinedButton(
            onPressed: _copyToClipboard,
            icon: Icons.copy_rounded,
            label: 'نسخ النص',
            color: const Color(0xFF06FFA5),
          ),
        ),
        SizedBox(width: isSmallScreen ? 12 : 18),
        Expanded(
          child: _buildOutlinedButton(
            onPressed: _clearText,
            icon: Icons.delete_outline_rounded,
            label: 'مسح الكل',
            color: const Color(0xFFFF006E),
          ),
        ),
      ],
    );
  }

  Widget _buildOutlinedButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;

    return Container(
      height: isSmallScreen ? 52 : (isMediumScreen ? 60 : 68),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 24),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.25), color.withOpacity(0.1)],
        ),
        border: Border.all(color: color.withOpacity(0.7), width: 2.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: isSmallScreen ? 22 : (isMediumScreen ? 26 : 30),
                color: color,
              ),
              SizedBox(width: isSmallScreen ? 8 : 14),
              Text(
                label,
                style: TextStyle(
                  fontSize: isSmallScreen ? 15 : (isMediumScreen ? 17 : 19),
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedGlassContainer({
    Key? key,
    required Widget child,
    EdgeInsets? padding,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;

    final defaultPadding = EdgeInsets.all(
      isSmallScreen ? 16 : (isMediumScreen ? 20 : 26),
    );

    return ClipRRect(
      key: key,
      borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: padding ?? defaultPadding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.18),
                Colors.white.withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 32),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: isSmallScreen ? 25 : 40,
                offset: Offset(0, isSmallScreen ? 12 : 20),
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

class SimpleOrbsPainter extends CustomPainter {
  final double animationValue;

  SimpleOrbsPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    final orbs = [
      {'color': const Color(0xFFFF006E), 'x': 0.2, 'y': 0.3, 'size': 220.0},
      {'color': const Color(0xFF8338EC), 'x': 0.7, 'y': 0.6, 'size': 200.0},
      {'color': const Color(0xFF06FFA5), 'x': 0.5, 'y': 0.8, 'size': 180.0},
    ];

    for (var orb in orbs) {
      final x =
          size.width * (orb['x'] as double) +
          math.cos(animationValue * 2 * math.pi) * 50;
      final y =
          size.height * (orb['y'] as double) +
          math.sin(animationValue * 2 * math.pi) * 50;
      final orbSize = orb['size'] as double;

      paint.shader = RadialGradient(
        colors: [
          (orb['color'] as Color).withOpacity(0.4),
          (orb['color'] as Color).withOpacity(0.2),
          (orb['color'] as Color).withOpacity(0.1),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: orbSize));

      canvas.drawCircle(Offset(x, y), orbSize, paint);
    }
  }

  @override
  bool shouldRepaint(SimpleOrbsPainter oldDelegate) => true;
}

class SimpleSoundWavesPainter extends CustomPainter {
  final double animationValue;

  SimpleSoundWavesPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (int i = 0; i < 4; i++) {
      final delayedValue = ((animationValue + i * 0.25) % 1.0);
      final radius = 80 + (delayedValue * 300);
      final opacity = (1 - delayedValue) * 0.4;

      final paint = Paint()
        ..color = const Color(0xFF06FFA5).withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawCircle(Offset(centerX, centerY), radius, paint);
    }

    final waveCount = 6;
    for (int i = 0; i < waveCount; i++) {
      final path = Path();
      final yPos = (size.height / waveCount) * i;
      final amplitude = 25.0;
      final frequency = 3.0;

      path.moveTo(0, yPos);

      for (double x = 0; x <= size.width; x += 8) {
        final y =
            yPos +
            amplitude *
                math.sin(
                  (x / size.width) * frequency * math.pi * 2 +
                      animationValue * math.pi * 3 +
                      i * 0.5,
                );
        path.lineTo(x, y);
      }

      final paint = Paint()
        ..color = const Color(0xFF06FFA5).withOpacity(0.2 * (1 - i / waveCount))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(SimpleSoundWavesPainter oldDelegate) => true;
}

class AdvancedParticlesPainter extends CustomPainter {
  final double animationValue;
  final bool isListening;

  AdvancedParticlesPainter({
    required this.animationValue,
    required this.isListening,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final particleCount = isListening ? 50 : 30;
    final particleColors = [
      const Color(0xFF00FFA3),
      const Color(0xFF00B4D8),
      const Color(0xFF9D4EDD),
      const Color(0xFFFF006E),
    ];

    for (int i = 0; i < particleCount; i++) {
      final seed = i * 7919;
      final baseX = (seed % size.width.toInt()).toDouble();
      final baseY = (seed % size.height.toInt()).toDouble();

      final x =
          (baseX + math.sin(animationValue * 2 * math.pi + i * 0.1) * 40) %
          size.width;
      final y =
          (baseY +
              animationValue * size.height * (isListening ? 0.7 : 0.4) +
              i * (size.height / particleCount)) %
          size.height;

      final color = particleColors[i % particleColors.length];
      final opacity = isListening ? 0.35 : 0.2;
      final particleSize = isListening
          ? 2.5 + math.sin(animationValue * math.pi + i) * 1.2
          : 2.0;

      paint.color = color.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(AdvancedParticlesPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.isListening != isListening;
}

class AdvancedProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  AdvancedProgressPainter({required this.progress, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const SweepGradient(
        colors: [
          Color(0xFF06FFA5),
          Color(0xFF3A86FF),
          Color(0xFF8338EC),
          Color(0xFF06FFA5),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
