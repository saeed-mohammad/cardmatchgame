//
//  CardCollectionViewCell.swift
//  CardMatch
//
//  Created by saeed shaikh on 28/01/26.
//

import UIKit

class CardCollectionViewCell: UICollectionViewCell {
    
   @IBOutlet weak var frontImageView: UIImageView!
   @IBOutlet weak var backImageView: UIImageView!
   
   var card: Card?
   
   func configureCell(card: Card){
      
      //tack the card status
      self.card = card
      // set the front card image of the represent
      frontImageView.image = UIImage(named: card.cardName)
      
      // reset the state of the cell to show appropiate front and back image
      if self.card?.isFliped == true {
         flipUp(speed: 0)
      }else{
         flipDown(speed: 0, delay: 0)
      }
      
      // reset the cell visibility
      if self.card?.isMatched == true {
         remove()
      }else {
         display()
      }
   }
   
   func flipUp(speed: TimeInterval = 0.3){
      UIView.transition(from: backImageView, to: frontImageView, duration: speed, options: [.showHideTransitionViews,.transitionFlipFromLeft]) { _ in
//          updated the card status
//         self.card?.isFliped = true
      }
//      card?.isFliped = true
      
   }
   func flipDown(speed: TimeInterval = 0.3, delay: TimeInterval = 0.3){
      DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
         UIView.transition(from: self.frontImageView, to: self.backImageView, duration: speed, options: [.showHideTransitionViews,.transitionFlipFromLeft]) { _ in
            // updated the card status
//            self.card?.isFliped = false
         }
      })
      // updated the card status
//      card?.isFliped = false
   }
   
   func remove(){
      // make image invisible
      backImageView.alpha = 0
      
      // remove front image by using animation
      UIView.animate(withDuration: 0.3, delay: 0.5) {
         self.frontImageView.alpha = 0
      }
      
   }
   
   // visible for reusable of cell
   func display(){
      // make image invisible
      backImageView.alpha = 1
      frontImageView.alpha = 1
   }
   
}

