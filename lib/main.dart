import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:journly/controllers/theme_controller.dart';
import 'package:journly/firebase_options.dart';
import 'package:journly/pages/welcome_page.dart';
import 'package:typewritertext/typewritertext.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const JournlyApp());
}

class JournlyApp extends StatelessWidget {
  const JournlyApp({super.key});

  static const Color primaryColor =
      Color.fromARGB(255, 102, 140, 84);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, child) {
        return MaterialApp(
          title: 'Journly',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeController.instance.themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            colorSchemeSeed: primaryColor,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorSchemeSeed: primaryColor,
            useMaterial3: true,
          ),
          home: const SplashPage(),
        );
      },
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _startSplashAnimation();
  }

  Future<void> _startSplashAnimation() async {
    await _animationController.forward();
    await Future<void>.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SliderPage(),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
    );

    const subtitleStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );

    const titleColors = [
      Color.fromARGB(255, 112, 202, 71),
      Colors.blue,
      Color.fromARGB(255, 209, 154, 71),
      Color.fromARGB(255, 209, 53, 42),
    ];

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Image.asset(
                        'assets/sp5.png',
                        height: constraints.maxHeight * 0.38,
                        fit: BoxFit.contain,
                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return const SizedBox(
                            height: 180,
                            child: Center(
                              child: Icon(
                                Icons.auto_stories,
                                size: 90,
                                color: JournlyApp.primaryColor,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedTextKit(
                      repeatForever: true,
                      animatedTexts: [
                        ColorizeAnimatedText(
                          'Journly',
                          textStyle: titleStyle,
                          colors: titleColors,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 245,
                      child: TypeWriter.text(
                        'Your Journaling Partner',
                        textAlign: TextAlign.center,
                        softWrap: true,
                        duration: const Duration(milliseconds: 50),
                        style: subtitleStyle,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}