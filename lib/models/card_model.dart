import 'package:flutter/material.dart';

enum Suit { spades, hearts, diamonds, clubs }

enum Rank { one, two, three, four, five, six, seven,
  eight, nine, ten, jack, queen, king }

class CardModel {
  final Suit suit;
  final Rank rank;
  bool isFaceUp;

  CardModel({required this.suit, required this.rank, this.isFaceUp = true});

  // Matches filenames like: spades-1.png, hearts-13.png, diamonds-4.png
  String get assetPath {
    final suitName = suit.name;        // 'spades', 'hearts', 'diamonds', 'clubs'
    final number   = rank.index + 1;   // 1–13
    return 'assets/cards/$suitName-$number.png';
  }

  static String get backAssetPath => 'assets/cards/back.png';

  String get suitSymbol {
    switch (suit) {
      case Suit.hearts:   return '♥';
      case Suit.diamonds: return '♦';
      case Suit.clubs:    return '♣';
      case Suit.spades:   return '♠';
    }
  }

  Color get suitColor =>
      (suit == Suit.hearts || suit == Suit.diamonds)
          ? Colors.red
          : Colors.black;

  String get rankLabel {
    switch (rank) {
      case Rank.one:   return 'A';
      case Rank.jack:  return 'J';
      case Rank.queen: return 'Q';
      case Rank.king:  return 'K';
      default:         return (rank.index + 1).toString();
    }
  }
}