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
   
   let viewModel = GameViewModel()

   var timer: Timer?
   var milliSecond: Int = 30 * 1000 // 30 second
   var isTimerRunning = false
   
   override func viewDidLoad() {
      super.viewDidLoad()
      // Do any additional setup after loading the view.
      collectionView.delegate = self
      collectionView.dataSource = self
      
      // hide scroll bar from collection
      collectionView.showsVerticalScrollIndicator = false
      
      // intializing timer
      timerLabel.text = "Remaining Time: 30.00"
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
       milliSecond = 30 * 1000
       timerLabel.textColor = .black
       timerLabel.text = "Remaining Time: 30.00"
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
      return viewModel.cards.count
   }
   
   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCollectionViewCell
      
      cell.configureCell(card: viewModel.cards[indexPath.row])
      return cell
   }
   
   func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      // timer start only on first tap
      if !isTimerRunning {
         startTimer()
      }
      
      // the view model owns the rules, the controller only animates the result
      switch viewModel.flip(at: indexPath.row) {
      case .ignored:
         break
      case .firstFlip(let index):
         cell(at: index)?.flipUp()
      case .match(let first, let second):
         cell(at: first)?.flipUp()
         cell(at: second)?.flipUp()
         cell(at: first)?.remove()
         cell(at: second)?.remove()
         checkForGameEnd()
      case .mismatch(let first, let second):
         cell(at: second)?.flipUp()
         cell(at: first)?.flipDown()
         cell(at: second)?.flipDown()
      }
   }
   
   // MARK: - Game end
   
   private func cell(at index: Int) -> CardCollectionViewCell? {
      collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? CardCollectionViewCell
   }
   
   func checkForGameEnd() {
      if viewModel.hasWon {
         timer?.invalidate()
         isTimerRunning = false
         alertPopup(title: "Congratulation!", message: "You have won the game")
      } else if milliSecond == 0 {
         alertPopup(title: "Time's up", message: "Sorry, better luck next time")
      }
   }
   
   func alertPopup(title: String, message: String) {
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      let action = UIAlertAction(title: "Again", style: .default) { [weak self] _ in
         guard let self = self else { return }
         
         // reset game state
         self.resetTimer()
         self.viewModel.restart()
         // reload UI
         self.collectionView.reloadData()
      }
      let cancel = UIAlertAction(title: "Cancel", style: .cancel)
      
      alert.addAction(action)
//      alert.addAction(cancel)
      present(alert, animated: true)
      
   }

}

