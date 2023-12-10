import 'package:flutter/material.dart';
import 'package:how_much/presentation/ui/colours.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frequently Asked Questions'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(32.0),
        child: SingleChildScrollView(child: FAQContent()),
      ),
    );
  }
}

class FAQContent extends StatelessWidget {
  const FAQContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        RichText(
          text: TextSpan(
            children: [
              _buildQuestionAnswerSpan(
                "Q: Why do I have to wait for 6 hours between each update?\n",
                "A: Because you are using it for free, and API calls are not free. Be grateful.\n",
              ),
              _buildQuestionAnswerSpan(
                "Q: Do you support precious metals?\n",
                "A: Yes, Gold and Silver can be found under `Forex` type.\n",
              ),
              _buildQuestionAnswerSpan(
                "Q: What happens if I add an asset to HowMuch that I do not own in real-life?\n",
                "A: Bad things. I wouldn't risk it if I were you.\n",
              ),
              _buildQuestionAnswerSpan(
                "Q: Why does my portfolio value drop every time I check it?\n",
                "A: It's just practicing its limbo skills. How low can you go?\n",
              ),
              _buildQuestionAnswerSpan(
                "Q: Is it possible to integrate my bank accounts and crypto wallets in here?\n",
                "A: You really want to enter your sensitive data to a 3rd party app? You shouldn't be investing in the first place imo.\n",
              ),
            ],
          ),
        ),
        const Text(
          "Have more questions? Save it to yourself 👍🏻",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: howBlack,
          ),
        ),
        const Padding(padding: EdgeInsets.all(24)),
      ],
    );
  }
}

TextSpan _buildQuestionAnswerSpan(String question, String answer) {
  return TextSpan(
    style: const TextStyle(fontSize: 16),
    children: [
      TextSpan(
        text: question,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: howBlack,
        ),
      ),
      const TextSpan(
          text: '\n',
          style: TextStyle(fontSize: 8)), // Extra space after each answer
      TextSpan(text: answer, style: const TextStyle(color: howBlack)),
      const TextSpan(text: '\n\n'), // Extra space after each answer
    ],
  );
}
