import 'dart:math';
import '../models/card_model.dart';
import '../models/deck_model.dart';

class GameLogic {
  static bool hasFourOfAKind(List<CardModel> hand) {
    if (hand.length < 4) return false;
    final rank = hand[0].rank;
    return hand.every((c) => c.rank == rank);
  }

  static void revealComputerHand(List<CardModel> computerHand) {
    for (var c in computerHand) {
      c.isFaceUp = true;
    }
  }

  // Called once at the start of each round
  static Rank pickTargetRank(List<CardModel> computerHand) {
    return computerHand[Random().nextInt(computerHand.length)].rank;
  }

  // Called after initial deal and after every player Deal press
  static void computerScanAndSwap({
    required List<CardModel> computerHand,
    required List<CardModel> tableCards,
    required Rank targetRank,
  }) {
    // Find all target rank cards on the table
    for (int ti = 0; ti < tableCards.length; ti++) {
      if (tableCards[ti].rank == targetRank) {
        // Find a non-target card in computer hand to swap out
        final ci = computerHand.indexWhere((c) => c.rank != targetRank);
        if (ci == -1) break; // computer hand is all target rank — done

        final temp = computerHand[ci];
        computerHand[ci] = tableCards[ti]..isFaceUp = false;
        tableCards[ti] = temp..isFaceUp = true;
      }
    }
  }

  static void reshuffleIfNeeded({
    required DeckModel deck,
    required List<CardModel> playerHand,
    required List<CardModel> computerHand,
    required List<CardModel> tableCards,
  }) {
    if (deck.cards.length < 4) {
      final inPlay = [...playerHand, ...computerHand, ...tableCards]
          .map((c) => '${c.suit}-${c.rank}')
          .toSet();

      for (var suit in Suit.values) {
        for (var rank in Rank.values) {
          final key = '$suit-$rank';
          if (!inPlay.contains(key)) {
            deck.cards.add(CardModel(suit: suit, rank: rank));
          }
        }
      }
      deck.shuffle();
    }
  }
}