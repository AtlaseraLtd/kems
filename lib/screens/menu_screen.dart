import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game_screen.dart';

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
            _MenuButton(label: 'Play', onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const GameScreen()));
            }),
            _MenuButton(label: 'Settings', onTap: () {}),
            _MenuButton(label: 'About', onTap: () {}),
            _MenuButton(label: 'Quit', onTap: () {
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.green.shade900,
          minimumSize: const Size(220, 52),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }
}