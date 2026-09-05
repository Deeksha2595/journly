import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:journly/pages/login_page.dart';
import 'package:journly/pages/register_page.dart';

class SliderPage extends StatefulWidget {
  const SliderPage({super.key});

  @override
  State<SliderPage> createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage> {
  static const Color _primaryColor = Color.fromARGB(255, 102, 140, 84);

  static const List<String> _images = [
    'assets/1.png',
    'assets/2.png',
    'assets/3.png',
  ];

  int _currentImageIndex = 0;

  void _openLoginPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginDemo(),
      ),
    );
  }

  void _openRegisterPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Register(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    final carouselHeight = (screenHeight * 0.32).clamp(180.0, 280.0).toDouble();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: _primaryColor,
        title: const Text(
          'Welcome to Journly',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          child: Column(
            children: [
              const Text(
                'Your personal journaling and wellness companion',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: _primaryColor,
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: Center(
                  child: CarouselSlider.builder(
                    itemCount: _images.length,
                    itemBuilder: (context, index, realIndex) {
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            _images[index],
                            fit: BoxFit.cover,
                            errorBuilder: (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return const ColoredBox(
                                color: Color.fromARGB(255, 230, 238, 226),
                                child: Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    options: CarouselOptions(
                      height: carouselHeight,
                      viewportFraction: 0.88,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: true,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 3),
                      autoPlayAnimationDuration:
                          const Duration(milliseconds: 700),
                      autoPlayCurve: Curves.easeInOut,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Carousel indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _images.length,
                  (index) {
                    final isSelected = index == _currentImageIndex;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: isSelected ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? _primaryColor : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openLoginPage,
                      icon: const Icon(Icons.login),
                      label: const Text('Login'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primaryColor,
                        side: const BorderSide(
                          color: _primaryColor,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _openRegisterPage,
                      icon: const Icon(Icons.person_add),
                      label: const Text('Register'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
