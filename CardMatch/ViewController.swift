//
//  ViewController.swift
//  CardMatch
//
//  Created by saeed shaikh on 10/01/26.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
   
   
   @IBOutlet weak var collectionView: UICollectionView!
   @IBOutlet weak var timerLabel: UILabel!
   
   let cardModel = CardModel()
   var cardsArray = [Card]()
   var firstCardFlipedIndex:IndexPath?
   
   var timer: Timer?
   var milliSecond: Int = 10 * 1000 // 10 second
   var isTimerRunning = false
   
   override func viewDidLoad() {
      super.viewDidLoad()
      // Do any additional setup after loading the view.
      collectionView.delegate = self
      collectionView.dataSource = self
      
      // hide scroll bar from collection
      collectionView.showsVerticalScrollIndicator = false
      
      cardsArray = cardModel.getCard()
      

      // intializing timer
      timerLabel.text = "Remaining Time: 10.00"
      timerLabel.textColor = .black
      
   }
   
   // MARK: - Timer method
   @objc func timerFired() {
      // decres the timer
      milliSecond -= 1
      
      // update the ui
      let seconds: Double = Double(milliSecond)/1000.0
      timerLabel.text = String(format: "Remaining Time: %.2f", seconds)
      
      // stop the timer if it reach the zero
      if milliSecond == 0 {
         timerLabel.textColor = UIColor.red
         timer?.invalidate()
         isTimerRunning = false
         // check user completed game or not
         checkForGameEnd()
         
      }
   }
   
   @objc func resetTimer() {
       timer?.invalidate()
       timer = nil
       isTimerRunning = false
       milliSecond = 10 * 1000
       timerLabel.textColor = .black
       timerLabel.text = "Remaining Time: 10.00"
   }
   
   @objc func startTimer() {

       isTimerRunning = true
       timer = Timer.scheduledTimer(
           timeInterval: 0.001,
           target: self,
           selector: #selector(timerFired),
           userInfo: nil,
           repeats: true
       )
      RunLoop.main.add(timer!, forMode: .common)
   }
   
   //   MARK: - collection view delagete and protocols
   func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return cardsArray.count
   }
   
   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCollectionViewCell
      
      cell.configureCell(card: cardsArray[indexPath.row])
      return cell
   }
   
   func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      // timer start only on first tap
      if !isTimerRunning {
         startTimer()
      }
      
      // ignore matched or already flipped card
      if cardsArray[indexPath.row].isMatched ||
         cardsArray[indexPath.row].isFliped {
         return
      }
      
      let cell = collectionView.cellForItem(at: indexPath) as? CardCollectionViewCell
      
      // update the model
      cardsArray[indexPath.row].isFliped = true
      
      // Handle animation according to card status
      cell?.flipUp()
      
      if(firstCardFlipedIndex == nil){
         // track the first card index
         firstCardFlipedIndex = indexPath
      }else{
         // compare the match from first card to second
         checkForMatch(indexPath)
      }
      
   }
   
   // MARK: - Game logic
   
   func checkForMatch(_ secondCardFlipedIndex: IndexPath){
      
      // get cells
      let cellOne = collectionView.cellForItem(at: firstCardFlipedIndex!) as? CardCollectionViewCell
      let cellTwo = collectionView.cellForItem(at: secondCardFlipedIndex) as? CardCollectionViewCell
      
      if (cardsArray[firstCardFlipedIndex!.row].cardName == cardsArray[secondCardFlipedIndex.row].cardName){
         
         // update the model
         cardsArray[firstCardFlipedIndex!.row].isMatched = true
         cardsArray[secondCardFlipedIndex.row].isMatched = true
         
         // remove user select card
         cellOne?.remove()
         cellTwo?.remove()
         
         // check if the all pairs clear or not
         checkForGameEnd()
         
      }else{
         
         // not match
         cardsArray[firstCardFlipedIndex!.row].isFliped = false
         cardsArray[secondCardFlipedIndex.row].isFliped = false
         
         // flip back both card
         cellOne?.flipDown()
         cellTwo?.flipDown()
         
      }
      
      // reset the first card index
      firstCardFlipedIndex = nil
      
   }
   
   func checkForGameEnd() {
      var hasWon = false
      // check if there any card in not match
      for card in cardsArray {
         if card.isMatched == false{
            hasWon = false
            break
         }
      }
      
      if hasWon {
         // user won, show alert
         alertPopup(title: "Congratulation!",message: "You have won the game")
      }else {
         // user hasn't won yet
         if milliSecond == 0 {
            alertPopup(title: "Time's up", message: "Sorry, better luck next time")
         }
         // check if there timer left
      }
      
   }
   
   func alertPopup(title: String, message: String) {
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      let action = UIAlertAction(title: "Again", style: .default) { [weak self] _ in
         guard let self = self else { return }
         
         // reset game state
         self.resetTimer()
         self.cardsArray = self.cardModel.getCard()
         self.firstCardFlipedIndex = nil
         // reload UI
         self.collectionView.reloadData()
      }
      let cancel = UIAlertAction(title: "Cancel", style: .cancel)
      
      alert.addAction(action)
//      alert.addAction(cancel)
      present(alert, animated: true)
      
   }

}

