import 'dart:async';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final List<String> _bgImages = [
    "assets/images/welcome1.jpg",
    "assets/images/welcome2.jpg",
    "assets/images/welcome3.jpg",
    "assets/images/welcome4.jpg",
  ];

  int _currentPage = 0;
  late PageController _pageController;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < _bgImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// Background Image Slider
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _bgImages.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return Image.asset(
                    _bgImages[index],
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),

          /// Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              /// Logo Ziarat
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.orangeAccent, width: 2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.explore_outlined,
                      color: Colors.orangeAccent,
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "ZIARAT",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                    ),
                  ),
                  Container(height: 3, width: 40, color: Colors.orangeAccent),
                ],
              ),

              const Spacer(flex: 2),

              /// Bottom Section
              Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_bgImages.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: _currentPage == index ? 20 : 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index ? Colors.orangeAccent : Colors.white38,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      }),
                    ),
                    
                    const SizedBox(height: 30),
                    const Text(
                      "Explorez le Maroc autrement",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => Navigator.pushNamed(context, "/signup"),
                        child: const Text("COMMENCER", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, "/login"),
                      child: const Text("Se connecter", style: TextStyle(color: Colors.orangeAccent)),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}