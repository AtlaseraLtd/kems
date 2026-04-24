import 'package:animated_button/animated_button.dart';
import 'package:flutter/material.dart';
import '../utils/settings_manager.dart';
import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled    = true;
  int _timerDuration    = 5;
  String _cardBack      = 'back-blue';
  String _playerName    = 'Player';
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _loadSettings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final sound      = await SettingsManager.getSoundEnabled();
    final timer      = await SettingsManager.getTimerDuration();
    final cardBack   = await SettingsManager.getCardBack();
    final playerName = await SettingsManager.getPlayerName();
    setState(() {
      _soundEnabled  = sound;
      _timerDuration = timer;
      _cardBack      = cardBack;
      _playerName    = playerName;
      _nameController.text = playerName;
    });
  }

  Future<void> _savePlayerName() async {
    await SettingsManager.setPlayerName(_nameController.text.trim());
    setState(() => _playerName = _nameController.text.trim());
    FocusScope.of(context).unfocus();
    _showSnack('Name saved!');
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFFf64900),
      ),
    );
  }

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
                    'SETTINGS',
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

            // ── Settings list ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [

                  // ── Player Name ──
                  _SectionHeader(title: 'PROFILE'),
                  _SettingsCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Player Name',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _nameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Enter your name',
                                  hintStyle: const TextStyle(
                                      color: Colors.white30),
                                  filled: true,
                                  fillColor: Colors.white10,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            AnimatedButton(
                              onPressed: _savePlayerName,
                              color: const Color(0xFFf64900),
                              width: 70,
                              height: 44,
                              borderRadius: 8,
                              child: const Text('SAVE',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Sound ──
                  _SectionHeader(title: 'AUDIO'),
                  _SettingsCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Sound Effects',
                            style: TextStyle(
                                color: Colors.white, fontSize: 15)),
                        Switch(
                          value: _soundEnabled,
                          activeColor: const Color(0xFFf64900),
                          onChanged: (val) async {
                            setState(() => _soundEnabled = val);
                            await SettingsManager.setSoundEnabled(val);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Timer ──
                  _SectionHeader(title: 'GAMEPLAY'),
                  _SettingsCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Deal Timer',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15)),
                            Text('$_timerDuration seconds',
                                style: const TextStyle(
                                    color: Color(0xFFf64900),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Slider(
                          value: _timerDuration.toDouble(),
                          min: 3,
                          max: 10,
                          divisions: 7,
                          activeColor: const Color(0xFFf64900),
                          inactiveColor: Colors.white24,
                          onChanged: (val) async {
                            setState(() => _timerDuration = val.toInt());
                            await SettingsManager.setTimerDuration(val.toInt());
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Card Back ──
                  _SectionHeader(title: 'APPEARANCE'),
                  _SettingsCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Card Back',
                            style: TextStyle(
                                color: Colors.white, fontSize: 15)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _CardBackOption(
                              assetPath: 'assets/cards/back-blue.png',
                              label: 'Blue',
                              isSelected: _cardBack == 'back-blue',
                              onTap: () async {
                                setState(() => _cardBack = 'back-blue');
                                await SettingsManager.setCardBack('back-blue');
                              },
                            ),
                            const SizedBox(width: 24),
                            _CardBackOption(
                              assetPath: 'assets/cards/back-red.png',
                              label: 'Red',
                              isSelected: _cardBack == 'back-red',
                              onTap: () async {
                                setState(() => _cardBack = 'back-red');
                                await SettingsManager.setCardBack('back-red');
                              },
                            ),
                            const SizedBox(width: 24),
                            _CardBackOption(
                              assetPath: 'assets/cards/back-red.png',
                              label: 'Green',
                              isSelected: _cardBack == 'back-red',
                              onTap: () async {
                                setState(() => _cardBack = 'back-red');
                                await SettingsManager.setCardBack('back-red');
                              },
                            ),
                            const SizedBox(width: 24),
                            _CardBackOption(
                              assetPath: 'assets/cards/back-red.png',
                              label: 'Yellow',
                              isSelected: _cardBack == 'back-red',
                              onTap: () async {
                                setState(() => _cardBack = 'back-red');
                                await SettingsManager.setCardBack('back-red');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Info ──
                  _SectionHeader(title: 'INFO'),
                  _SettingsCard(
                    child: Column(
                      children: [
                        _InfoRow(
                          label: 'Terms of Use',
                          onTap: () {
                            // TODO: open terms URL or screen
                          },
                        ),
                        const Divider(color: Colors.white12),
                        _InfoRow(
                          label: 'Support',
                          onTap: () {
                            // TODO: open support URL or email
                          },
                        ),
                        const Divider(color: Colors.white12),
                        _InfoRow(
                          label: 'About',
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const AboutScreen()));
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section Header ───────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFf64900),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

// ── Settings Card ────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final Widget child;
  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

// ── Card Back Option ─────────────────────────────────────────────

class _CardBackOption extends StatelessWidget {
  final String assetPath, label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CardBackOption({
    required this.assetPath,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFf64900)
                    : Colors.transparent,
                width: 3,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                assetPath,
                width: 60,
                height: 85,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFFf64900)
                  : Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Row ─────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _InfoRow({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontSize: 15)),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white38, size: 14),
          ],
        ),
      ),
    );
  }
}