import 'dart:async';
import 'package:animated_button/animated_button.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/card_model.dart';
import '../models/deck_model.dart';
import '../utils/game_logic.dart';
import '../widgets/playing_card.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  final DeckModel _deck = DeckModel();
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<CardModel> _playerHand   = [];
  List<CardModel> _computerHand = [];
  List<CardModel> _tableCards   = [];
  int? _selectedPlayerIndex;
  late bool _isPaused = false;
  bool? _lastRoundPlayerWon;

  // Scoring
  int _playerWins   = 0;
  int _computerWins = 0;
  int _currentRound = 1;
  Timer? _dealTimer;
  int _countdown = 5;
  static const int totalRounds = 5;
  static const int winsNeeded  = 3;

  // Computer AI
  Rank? _computerTargetRank;

  // Win animation
  late AnimationController _winAnimController;
  late Animation<double> _winScaleAnim;
  String _winMessage  = '';
  bool _showWinOverlay = false;

  @override
  void initState() {
    super.initState();
    _winAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _winScaleAnim = CurvedAnimation(
      parent: _winAnimController,
      curve: Curves.elasticOut,
    );
    _dealAll();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _dealTimer?.cancel();
    _winAnimController.dispose();
    super.dispose();
  }

  /* This method is responsible for playing the swap sound.
  * */
  void _playSound(String soundName) async {
    await _audioPlayer.play(AssetSource(soundName));
  }

  void _startDealTimer() {
    _dealTimer?.cancel();
    setState(() => _countdown = 5);

    _dealTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_showWinOverlay || _isPaused) return;
      setState(() => _countdown--);
      if (_countdown <= 0) {
        timer.cancel();
        _dealCenter();
      }
    });
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
  }

  void _resetDealTimer() {
    _startDealTimer();
  }

  // ── Deal all cards (new round) ───────────────────────────────
  void _dealAll() {
    _deck.reset();
    setState(() {
      _computerHand = _deck.deal(4);
      _playerHand   = _deck.deal(4);
      _tableCards   = _deck.deal(4);
      for (var c in _computerHand) {
        c.isFaceUp = false;
      }
      _selectedPlayerIndex = null;
      _lastRoundPlayerWon = null;
      _showWinOverlay      = false;

      // Pick target rank then immediately scan table
      _computerTargetRank = GameLogic.pickTargetRank(_computerHand);
      GameLogic.computerScanAndSwap(
        computerHand: _computerHand,
        tableCards: _tableCards,
        targetRank: _computerTargetRank!,
      );
    });
    _playSound('sounds/deal-cards.mp3');
    _checkWin();
    _startDealTimer();
  }

  // ── Deal center only ─────────────────────────────────────────
  void _dealCenter() {
    GameLogic.reshuffleIfNeeded(
      deck: _deck,
      playerHand: _playerHand,
      computerHand: _computerHand,
      tableCards: _tableCards,
    );
    setState(() {
      _tableCards          = _deck.deal(4);
      _selectedPlayerIndex = null;
      GameLogic.computerScanAndSwap(
        computerHand: _computerHand,
        tableCards: _tableCards,
        targetRank: _computerTargetRank!,
      );
    });
    _playSound('sounds/deal-cards.mp3');
    _checkWin();
    _startDealTimer();
  }

  // ── Player card interactions ─────────────────────────────────
  void _onPlayerCardTap(int index) {
    setState(() {
      _selectedPlayerIndex =
      (_selectedPlayerIndex == index) ? null : index;
    });
    _resetDealTimer();
  }

  void _onTableCardTap(int index) {
    if (_selectedPlayerIndex == null) return;
    setState(() {
      final temp = _playerHand[_selectedPlayerIndex!];
      _playerHand[_selectedPlayerIndex!] = _tableCards[index];
      _tableCards[index] = temp;
      _selectedPlayerIndex = null;
    });
    _playSound('sounds/swap-cards.wav');
    _checkWin();
    _resetDealTimer();
  }

  void _deselect() {
    if (_selectedPlayerIndex != null) {
      setState(() => _selectedPlayerIndex = null);
    }
  }

  // ── Win detection ────────────────────────────────────────────
  void _checkWin() {
    if (_showWinOverlay) return;
    if (GameLogic.hasFourOfAKind(_playerHand)) {
      _triggerWin(playerWon: true);
    } else if (GameLogic.hasFourOfAKind(_computerHand)) {
      _triggerWin(playerWon: false);
    }
  }

  void _triggerWin({required bool playerWon}) {
    setState(() {
      _lastRoundPlayerWon = playerWon;
      if (playerWon) {
        _playerWins++;
        _winMessage = '🎉 You got Kems!';
      } else {
        _computerWins++;
        _winMessage = '💻 Computer got Kems!';
        GameLogic.revealComputerHand(_computerHand);
      }
      _showWinOverlay = true;
    });

    _winAnimController.forward(from: 0);

    final gameOver = _playerWins >= winsNeeded ||
        _computerWins >= winsNeeded ||
        _currentRound >= totalRounds;

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (gameOver) {
        _showGameOverSafe();
      } else {
        setState(() => _currentRound++);
        _dealAll();
      }
    });
  }

  void _showGameOverSafe() {
    if (!mounted) return;
    final ctx = context; // capture before async gap
    final playerWon = _playerWins > _computerWins;
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white70,
        title: Text(
          playerWon ? '🏆 You Win!' : '💻 Computer Wins!',
          style: const TextStyle(color: Colors.white, fontSize: 24),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'Final Score\nYou $_playerWins — $_computerWins Computer',
          style: const TextStyle(color: Colors.white70, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade700),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _playerWins   = 0;
                _computerWins = 0;
                _currentRound = 1;
              });
              _dealAll();
            },
            child: const Text('Play Again',
                style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(ctx);
            },
            child: const Text('Quit',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          // ── Main layout ──
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableHeight = constraints.maxHeight;
                final scoreBarHeight = MediaQuery.of(context).padding.top + 70.0;
                final remainingHeight = availableHeight - scoreBarHeight;
                final zoneHeight = (remainingHeight - 30) * 0.30;
                final barHeight  = (remainingHeight - 30) * 0.10;
                final cardWidth  = (screenWidth - (3 * 6) - 32) / 4;
                final cardHeight =
                (cardWidth * 1.4).clamp(0.0, zoneHeight * 0.80);

                return GestureDetector(
                  onTap: _deselect,
                  behavior: HitTestBehavior.translucent,
                  child: Column(
                    children: [

                      // ── Score bar (black, no background image) ──
                      _ScoreBar(
                        round: _currentRound,
                        totalRounds: totalRounds,
                        playerWins: _playerWins,
                        computerWins: _computerWins,
                        countdown: _countdown,
                        lastRoundPlayerWon: _lastRoundPlayerWon,
                      ),

                      // ── Game area with poker table background ──
                      Expanded(
                        child: Stack(
                          children: [
                            // Background only covers this area
                            Positioned.fill(
                              child: Image.asset(
                                'assets/images/poker-table-background.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                  color: Colors.black.withValues(alpha: 0.25)),
                            ),

                            // Card zones
                            Column(
                              children: [
                                _StaticCardZone(
                                  height: zoneHeight,
                                  width: screenWidth,
                                  cards: _computerHand,
                                  cardWidth: cardWidth,
                                  cardHeight: cardHeight,
                                ),
                                _TappableCardZone(
                                  height: zoneHeight,
                                  width: screenWidth,
                                  cards: _tableCards,
                                  cardWidth: cardWidth,
                                  cardHeight: cardHeight,
                                  onCardTap: _selectedPlayerIndex != null
                                      ? _onTableCardTap
                                      : null,
                                ),
                                _PlayerCardZone(
                                  height: zoneHeight,
                                  width: screenWidth,
                                  cards: _playerHand,
                                  cardWidth: cardWidth,
                                  cardHeight: cardHeight,
                                  selectedIndex: _selectedPlayerIndex,
                                  onCardTap: _onPlayerCardTap,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ── Bottom bar (black, no background image) ──
                      _BottomBar(
                        height: barHeight,
                        isPaused: _isPaused,
                        onPause: _togglePause,
                        onQuit: () => Navigator.pop(context),
                      ),

                    ],
                  ),
                );
              },
            ),
          ),

          // ── Win overlay ──
          if (_showWinOverlay)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.45),
                  child: Center(
                    child: ScaleTransition(
                      scale: _winScaleAnim,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 24),
                        decoration: BoxDecoration(
                          color: Colors.green.shade800,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.grey, width: 3),
                        ),
                        child: Text(
                          _winMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ── Pause overlay ──
          if (_isPaused)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.6),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Paused',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFf64900),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        // Resume button
                        onPressed: _togglePause,
                        child: const Text(
                          'RESUME',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

        ],
      ),
    );
  }
}

// ── Score Bar ───────────────────────────────────────────────────

class _ScoreBar extends StatelessWidget {
  final int round, totalRounds, playerWins, computerWins;
  final int countdown;
  final bool? lastRoundPlayerWon;

  const _ScoreBar({
    required this.round,
    required this.totalRounds,
    required this.playerWins,
    required this.computerWins,
    required this.countdown,
    this.lastRoundPlayerWon,
  });

  Widget _dot(bool filled, Color fillColor) => Container(
    width: 14,
    height: 14,
    margin: const EdgeInsets.symmetric(horizontal: 3),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: filled ? fillColor : Colors.white24,
      border: Border.all(color: Colors.white38),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('You',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Row(children: List.generate(3, (i) {
                final isLastWin = i == playerWins - 1;
                final color = (isLastWin && lastRoundPlayerWon == true)
                    ? const Color(0xFF269E03)
                    : (isLastWin && lastRoundPlayerWon == false)
                    ? const Color(0xFFFA0505)
                    : const Color(0xFF269E03);
                return _dot(i < playerWins, color);
              })),
            ],
          ),
          Column(
            children: [
              Text(
                'Round $round',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '$countdown',
                style: TextStyle(
                  color: countdown <= 2
                      ? const Color(0xFFFA0505)
                      : countdown == 5
                      ? Colors.white54
                      : const Color(0xFFFAC105),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Computer',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Row(children: List.generate(3, (i) {
                final isLastWin = i == computerWins - 1;
                final color = (isLastWin && lastRoundPlayerWon == false)
                    ? const Color(0xFF269E03)
                    : (isLastWin && lastRoundPlayerWon == true)
                    ? const Color(0xFFFA0505)
                    : const Color(0xFF269E03);
                return _dot(i < computerWins, color);
              })),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Static Card Zone (Computer) ─────────────────────────────────

class _StaticCardZone extends StatelessWidget {
  final double height, width, cardWidth, cardHeight;
  final List<CardModel> cards;

  const _StaticCardZone({
    required this.height,
    required this.width,
    required this.cards,
    required this.cardWidth,
    required this.cardHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: cards.map((card) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: PlayingCard(
              key: ValueKey('${card.suit}-${card.rank}'),
              card: card,
              width: cardWidth,
              height: cardHeight,
            ),
          ),
        )).toList(),
      ),
    );
  }
}

// ── Tappable Card Zone (Table) ──────────────────────────────────

class _TappableCardZone extends StatelessWidget {
  final double height, width, cardWidth, cardHeight;
  final List<CardModel> cards;
  final void Function(int index)? onCardTap;

  const _TappableCardZone({
    required this.height,
    required this.width,
    required this.cards,
    required this.cardWidth,
    required this.cardHeight,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(cards.length, (i) {
          final isSwappable = onCardTap != null;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => onCardTap?.call(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: isSwappable
                    ? BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.yellowAccent
                          .withValues(alpha: 0.6),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                )
                    : null,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child:
                    FadeTransition(opacity: animation, child: child),
                  ),
                  child: PlayingCard(
                    key: ValueKey('${cards[i].suit}-${cards[i].rank}'),
                    card: cards[i],
                    width: cardWidth,
                    height: cardHeight,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Player Card Zone ────────────────────────────────────────────

class _PlayerCardZone extends StatelessWidget {
  final double height, width, cardWidth, cardHeight;
  final List<CardModel> cards;
  final int? selectedIndex;
  final void Function(int index) onCardTap;

  const _PlayerCardZone({
    required this.height,
    required this.width,
    required this.cards,
    required this.cardWidth,
    required this.cardHeight,
    required this.selectedIndex,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(cards.length, (i) {
          final isSelected = selectedIndex == i;
          return GestureDetector(
            onTap: () => onCardTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              margin: EdgeInsets.only(
                left: 3,
                right: 3,
                bottom: isSelected ? 18 : 0,
                top: isSelected ? 0 : 18,
              ),
              decoration: isSelected
                  ? BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              )
                  : null,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: PlayingCard(
                  key: ValueKey('${cards[i].suit}-${cards[i].rank}'),
                  card: cards[i],
                  width: cardWidth,
                  height: cardHeight,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Bottom Bar ──────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final double height;
  final bool isPaused;
  final VoidCallback onPause, onQuit;

  const _BottomBar({
    required this.height,
    required this.isPaused,
    required this.onPause,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final buttonWidth = (MediaQuery.of(context).size.width - 12 - 12 - 8) / 2;
    return Container(
      color: Colors.black,
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 6,
        bottom: bottomPadding + 6,
      ),
      height: height + bottomPadding,
      child: Row(
        children: [
          AnimatedButton(
            onPressed: onQuit,
            color: const Color(0xFFf64900),
            width: buttonWidth,
            child: const Text('QUIT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedButton(
            onPressed: onPause,
            color: const Color(0xFFf64900),
            width: buttonWidth,
            child: Text('PAUSE',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BarButton(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label,
          style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}