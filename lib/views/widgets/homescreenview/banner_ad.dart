import 'package:flutter/material.dart';

class BannerAd extends StatelessWidget {
  const BannerAd({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Container(
      margin: const EdgeInsets.all(16),
      height: size.height * 0.08,
      decoration: BoxDecoration(
        color: const Color(0xFF2D3748),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Image.asset('assets/images/advert.png', height: 60),
      ),
    );
  }
}