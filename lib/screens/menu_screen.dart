import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animated_button/animated_button.dart';
import 'package:kems/screens/settings_screen.dart';
import 'game_screen.dart';
import 'about_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade900,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('KEMS',
                style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 8)),
            const SizedBox(height: 60),
            _MenuButton(label: 'PLAY', onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const GameScreen()));
            }),
            _MenuButton(label: 'Settings', onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()));
            }),
            _MenuButton(label: 'ABOUT', onTap: () {Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AboutScreen()));}),
            _MenuButton(label: 'QUIT', onTap: () {
              SystemNavigator.pop();
            }),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _MenuButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final buttonWidth = MediaQuery.of(context).size.width * 0.7;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: AnimatedButton(
        onPressed: onTap,
        color: const Color(0xFFf64900),
        width: buttonWidth,
        height: 52,
        borderRadius: 8,
        shadowDegree: ShadowDegree.dark,
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}