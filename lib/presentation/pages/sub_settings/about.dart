import 'package:flutter/material.dart';
import 'package:how_much/util/intro_about.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            about(),
            const Spacer(),
            disclaimer(),
            const Padding(padding: EdgeInsets.all(24))
          ],
        ),
      ),
    );
  }
}
