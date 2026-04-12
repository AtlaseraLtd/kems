import 'card_model.dart';
import 'dart:math';

class DeckModel {
  List<CardModel> cards = [];

  DeckModel() {
    _buildDeck();
  }

  void _buildDeck() {
    cards = [];
    for (var suit in Suit.values) {
      for (var rank in Rank.values) {
        cards.add(CardModel(suit: suit, rank: rank));
      }
    }
  }

  void shuffle() => cards.shuffle(Random());

  List<CardModel> deal(int count) {
    if (cards.length < count) return [];
    final hand = cards.take(count).toList();
    cards.removeRange(0, count);
    return hand;
  }

  void reset() {
    _buildDeck();
    shuffle();
  }
}