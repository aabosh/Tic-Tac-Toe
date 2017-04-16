import UIKit
import PlaygroundSupport
import AVFoundation

var xTurn = true // Declare xTurn, holds the current turn
var player: AVAudioPlayer? // Declare optional of AVAudioPlayer

// Plays a sound, taken from http://stackoverflow.com/a/32036291
func playSound(soundName: String, fileType: String) {
    let url = Bundle.main.url(forResource: soundName, withExtension: fileType)!
    
    do {
        player = try AVAudioPlayer(contentsOf: url)
        guard let player = player else { return }
        
        player.prepareToPlay()
        player.play()
    } catch let error {
        print(error.localizedDescription)
    }
}

class GameController: UIView {
    
    var board = Array(repeating: Array(repeating: Tile(), count: 3), count: 3)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        let viewFrame = CGRect(x: 0, y: 0, width: 500, height: 500)
        self.init(frame: viewFrame)
        
        self.backgroundColor = .white
        resetBoard(initial: true)
    }
    
    func resetBoard(initial: Bool) {
        
        if !initial {
            playSound(soundName: "Page Flip", fileType: "wav")
        }
        
        for view in self.subviews {
            
            UIView.transition(with: self, duration: 0.5, options: [.transitionCurlUp, .curveEaseOut], animations: {
                view.removeFromSuperview()
            }, completion: nil )
        }
        
        for row in 0...2 {
            for col in 0...2 {
                board[row][col] = Tile(boardWidth: self.frame.width, row: row, col: col)
                self.addSubview(board[row][col])
            }
        }
    }
    
    func checkForWin(row: Int, col: Int) {
        
        var winningSpots = [[Int]]()
        var fullCount = 0
        
            // Vertical win
        if board[row][0].getSelection() == board[row][1].getSelection() && board[row][1].getSelection() == board[row][2].getSelection() && board[row][0].getSelection() != "empty" {
            winningSpots += [[row, 0], [row, 1], [row, 2]]
        }
            // Horizontal win
        else if board[0][col].getSelection() == board[1][col].getSelection() && board[1][col].getSelection() == board[2][col].getSelection() && board[0][col].getSelection() != "empty" {
            winningSpots += [[0, col], [1, col], [2, col]]
        }
            // Diagonal win (left to right)
        else if board[0][0].getSelection() == board[1][1].getSelection() && board[1][1].getSelection() == board[2][2].getSelection() && board[0][0].getSelection() != "empty" {
            winningSpots += [[0, 0], [1, 1], [2, 2]]
        }
            // Diagonal win (left to right)
        else if board[2][0].getSelection() == board[1][1].getSelection() && board[1][1].getSelection() == board[0][2].getSelection() && board[2][0].getSelection() != "empty" {
            winningSpots += [[2, 0], [1, 1], [0, 2]]
        }
            // Draw
        else {
            for tiles in board {
                for tile in tiles {
                    if tile.getSelection() == "x" || tile.getSelection() == "o" {
                        fullCount += 1
                    }
                }
            }
        }
        
        for spot in winningSpots {
            board[spot[0]][spot[1]].setWin(x: !xTurn)
        }
        
        if !winningSpots.isEmpty || fullCount == 9 {
            
            Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(resetBoard), userInfo: nil, repeats: false)
            
            for tiles in board {
                for tile in tiles {
                    tile.isUserInteractionEnabled = false
                }
            }
            
            if fullCount == 9 {
                playSound(soundName: "Snap", fileType: "wav")
            }
            else {
                playSound(soundName: "Ding", fileType: "wav")
            }
            
        }
    }
}

class Tile: UIView {
    
    var selection = "empty"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(boardWidth: CGFloat, row: Int, col: Int) {
        let width = boardWidth / 3
        let x = CGFloat(row) * width
        let y = CGFloat(col) * width
        let frame = CGRect(x: x, y: y, width: width, height: width)
        self.init(frame: frame)
        setupTile(row: row, col: col)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(Tile.didTap(_:)))
        self.addGestureRecognizer(tap)
    }
    
    func setupTile(row: Int, col: Int) {
        if row % 2 == col % 2 {
            self.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        else {
            self.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9725490196, blue: 0.9843137255, alpha: 1)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    func setSelection(change: String) {
        
        if selection == "empty" {
            let selectionFrame = CGRect(x: self.frame.width / 4, y: self.frame.width / 4, width: self.frame.width / 2, height: self.frame.height / 2)
            
            let selectionView = UIView(frame: selectionFrame)
            
            if change == "x" {
                selection = "x"
                selectionView.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
                selectionView.layer.cornerRadius = selectionFrame.width / 6
                playSound(soundName: "Pop", fileType: "wav")
            }
            else {
                selection = "o"
                selectionView.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
                selectionView.layer.cornerRadius = selectionFrame.width / 2
                playSound(soundName: "Pop 2", fileType: "wav")
            }
            
            xTurn = !xTurn
            
            UIView.transition(with: self, duration: 0.30, options: [.transitionFlipFromTop, .curveEaseOut], animations: {
                self.addSubview(selectionView)
            }, completion: nil )
            
        }
        else {
            print("Slot is taken!")
        }
        
    }
    
    func setWin(x: Bool) {
        let selectionFrame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        
        let winFrame = UIView(frame: selectionFrame)
        
        if (x) {
            winFrame.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 0.5)
        }
        else {
            winFrame.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 0.5)
        }
        
        UIView.transition(with: self, duration: 0.30, options: [.transitionFlipFromTop, .curveEaseOut], animations: {
            self.addSubview(winFrame)
        }, completion: nil )
        
        
    }
    
    func getSelection() -> String {
        return selection
    }
    
    func didTap(_ sender: UITapGestureRecognizer) {
        let controller = PlaygroundPage.current.liveView as! GameController
        
        let row = Int(sender.location(in: controller).x / self.frame.width)
        let col = Int(sender.location(in: controller).y / self.frame.width)
        
        if xTurn {
            setSelection(change: "x")
        }
        else {
            setSelection(change: "o")
        }
        
        controller.checkForWin(row: row, col: col)
        
    }
    
}

PlaygroundPage.current.liveView = GameController()
