//
//  GameViewModel.swift
//  CardMatch
//
//  Holds all game rules and state. No UIKit, so it is unit-testable.
//

import Foundation

/// Abstraction over where cards come from (random deck in the app, fixed deck in tests).
protocol CardProviding {
   func getCard() -> [Card]
}

extension CardModel: CardProviding {}

final class GameViewModel {

   /// What the view should animate after a flip.
   enum FlipResult: Equatable {
      case ignored
      case firstFlip(Int)
      case match(Int, Int)
      case mismatch(Int, Int)
   }

   // Card is a struct, so `cards` is a value: the view gets copies, never shared state.
   private(set) var cards: [Card]
   private var firstFlippedIndex: Int?
   private let cardProvider: CardProviding

   init(cardProvider: CardProviding = CardModel()) {
      self.cardProvider = cardProvider
      self.cards = cardProvider.getCard()
   }

   var hasWon: Bool {
      !cards.isEmpty && cards.allSatisfy { $0.isMatched }
   }

   func flip(at index: Int) -> FlipResult {
      guard cards.indices.contains(index),
            !cards[index].isMatched,
            !cards[index].isFliped else {
         return .ignored
      }

      cards[index].isFliped = true

      guard let first = firstFlippedIndex else {
         firstFlippedIndex = index
         return .firstFlip(index)
      }
      firstFlippedIndex = nil

      if cards[first].cardName == cards[index].cardName {
         cards[first].isMatched = true
         cards[index].isMatched = true
         return .match(first, index)
      } else {
         cards[first].isFliped = false
         cards[index].isFliped = false
         return .mismatch(first, index)
      }
   }

   func restart() {
      cards = cardProvider.getCard()
      firstFlippedIndex = nil
   }
}
