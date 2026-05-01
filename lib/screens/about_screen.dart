import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [

            // ── Header ──
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'ABOUT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),

            // ── Content ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [

                    // Logo
                    Image.asset(
                      'assets/images/logo.png',
                      width: 100,
                      height: 100,
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'KEMS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 6,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'Version 1.0.5',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 32),

                    _AboutCard(
                      title: 'THE GAME',
                      content:
                      'Kems is a classic card game where the goal is to collect four cards of the same rank from four different suits. '
                          'The first player to achieve this three times in five rounds is declared the winner.',
                    ),

                    const SizedBox(height: 16),

                    _AboutCard(
                      title: 'HOW TO PLAY',
                      content:
                      '1. Four cards are dealt to you, the computer, and the table.\n\n'
                          '2. Tap one of your cards to select it, then tap a table card to swap.\n\n'
                          '3. Every few seconds, the table cards are replaced automatically.\n\n'
                          '4. Collect four cards of the same rank to win the round.\n\n'
                          '5. First to win three rounds wins the game!',
                    ),

                    const SizedBox(height: 16),

                    _AboutCard(
                      title: 'DEVELOPED BY',
                      content: 'Atlasera, Ltd\n© 2026 All rights reserved.',
                    ),

                    const SizedBox(height: 40),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── About Card ───────────────────────────────────────────────────

class _AboutCard extends StatelessWidget {
  final String title, content;
  const _AboutCard({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFf64900),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}