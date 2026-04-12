import 'package:flutter/material.dart';
import '../models/card_model.dart';

class PlayingCard extends StatelessWidget {
  final CardModel card;
  final double width;
  final double height;

  const PlayingCard({
    super.key,
    required this.card,
    this.width = 60,
    this.height = 85,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          card.isFaceUp ? card.assetPath : CardModel.backAssetPath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}