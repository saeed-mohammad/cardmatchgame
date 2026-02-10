//
//  CardModel.swift
//  CardMatch
//
//  Created by saeed shaikh on 28/01/26.
//

import Foundation

class CardModel {
   
   func getCard() -> [Card] {
      // create empty array
      var ramdomCards = [Card]()
      // create 8 of pair cards
//      for _ in 1...8 {
      var loop = 1
      while(loop <= 8){
         
         let randomNumber = Int.random(in: 1...13)
         let cardName = "card\(randomNumber)"
         
         // avoid duplicates
         let duplicate = ramdomCards.contains { card in
            card.cardName == cardName
         }
         
         if duplicate {
            continue  // skip the itration
         }
//         print(randomNumber)
         // create 2 object
         let cardOne = Card(cardName: cardName)
         let cardTwo = Card(cardName: cardName)
         
//         cardOne.cardName = cardName
//         cardTwo.cardName = cardName
         
         ramdomCards += [cardOne, cardTwo]
         loop += 1
      }
      
      // shuffle cards
      ramdomCards.shuffle()
      // return array
//      print("ramndomcard: ",ramdomCards.count)
      return ramdomCards
   }
}
