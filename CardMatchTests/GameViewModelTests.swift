import XCTest
@testable import CardMatch

@MainActor
final class GameViewModelTests: XCTestCase {

   /// Fixed deck: indices 0,1 = "a" pair, indices 2,3 = "b" pair.
   private struct FixedDeck: CardProviding {
      func getCard() -> [Card] {
         [Card(cardName: "a"), Card(cardName: "a"),
          Card(cardName: "b"), Card(cardName: "b")]
      }
   }

   private func makeSUT() -> GameViewModel {
      GameViewModel(cardProvider: FixedDeck())
   }

   func test_match_marksBothCardsMatched() {
      let sut = makeSUT()
      XCTAssertEqual(sut.flip(at: 0), .firstFlip(0))
      XCTAssertEqual(sut.flip(at: 1), .match(0, 1))
      XCTAssertTrue(sut.cards[0].isMatched)
      XCTAssertTrue(sut.cards[1].isMatched)
   }

   func test_mismatch_flipsBothCardsBackAndKeepsThemUnmatched() {
      let sut = makeSUT()
      _ = sut.flip(at: 0)
      XCTAssertEqual(sut.flip(at: 2), .mismatch(0, 2))
      XCTAssertFalse(sut.cards[0].isFliped)
      XCTAssertFalse(sut.cards[2].isFliped)
      XCTAssertFalse(sut.cards[0].isMatched)
      XCTAssertFalse(sut.cards[2].isMatched)
   }

   func test_flippingAlreadyFlippedCard_isIgnored() {
      let sut = makeSUT()
      _ = sut.flip(at: 0)
      XCTAssertEqual(sut.flip(at: 0), .ignored)
   }

   func test_flippingMatchedCard_isIgnored() {
      let sut = makeSUT()
      _ = sut.flip(at: 0)
      _ = sut.flip(at: 1)
      XCTAssertEqual(sut.flip(at: 0), .ignored)
   }

   func test_outOfRangeIndex_isIgnored() {
      XCTAssertEqual(makeSUT().flip(at: 99), .ignored)
   }

   func test_hasWon_onlyWhenAllCardsMatched() {
      let sut = makeSUT()
      XCTAssertFalse(sut.hasWon)
      _ = sut.flip(at: 0); _ = sut.flip(at: 1)
      XCTAssertFalse(sut.hasWon)
      _ = sut.flip(at: 2); _ = sut.flip(at: 3)
      XCTAssertTrue(sut.hasWon)
   }

   func test_restart_resetsStateAndPendingFirstFlip() {
      let sut = makeSUT()
      _ = sut.flip(at: 0)
      sut.restart()
      XCTAssertTrue(sut.cards.allSatisfy { !$0.isFliped && !$0.isMatched })
      // the half-finished pair from before must not leak into the new game
      XCTAssertEqual(sut.flip(at: 2), .firstFlip(2))
   }

   func test_cardsAreValueTypes_copyDoesNotSeeLaterChanges() {
      let sut = makeSUT()
      let snapshot = sut.cards          // struct array: independent copy
      _ = sut.flip(at: 0)
      XCTAssertFalse(snapshot[0].isFliped)
      XCTAssertTrue(sut.cards[0].isFliped)
   }
}
