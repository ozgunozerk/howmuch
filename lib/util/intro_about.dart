import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Widget disclaimer() {
  return const Text(
    "Disclaimer: our service DOES NOT provide any financial services. "
    "All data contained in this website|application and via API is "
    "not necessarily real-time nor accurate. All CFDs (stocks, "
    "indices, mutual funds, ETFs), and Forex are not provided by "
    "exchanges but rather by market makers, and so prices may not "
    "be accurate and may differ from the actual market price, "
    "meaning prices are indicative and not appropriate for trading "
    "purposes. We are not using exchanges data feeds for commercial "
    "data, we are using OTC, peer to peer trades and trading "
    "platforms over 100+ sources, we are aggregating our data "
    "feeds via VWAP method.",
    style: TextStyle(fontSize: 14),
  );
}

Widget about() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text(
        "Welcome to HowMuch",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      const Text(
        "\n",
        style: TextStyle(fontSize: 4),
      ),
      const Text(
        "an open-source portfolio aggregator and report generator.\n"
        "\n"
        "Please note that price updates occur every 6 hours.\n"
        "\n"
        "If you have any feedback, feature requests, or bug reports, or if you wish to contribute, please visit the ",
        style: TextStyle(
          fontSize: 16,
        ),
      ),
      GestureDetector(
        onTap: () {
          launchUrl(Uri.parse('https://github.com/ozgunozerk/howmuch'));
        },
        child: const Text(
          "repository.",
          style: TextStyle(
            fontSize: 16,
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
      const Text(
        "\n\nThank you for being a part of this journey! 🚀",
        style: TextStyle(
          fontSize: 16,
        ),
      ),
    ],
  );
}
