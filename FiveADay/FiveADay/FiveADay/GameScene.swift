//
//  GameScene.swift
//  FiveADay
//
//  Created by TørK on 18/12/2017.
//  Copyright © 2017 Tørk Egeberg. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var selectedNode = SKSpriteNode()
    var nodeNameArray = [""]
    let monster = SKSpriteNode(imageNamed: "closeMonster")
    var currentDay: Bool?
    var label: UILabel?
    var count: Int = 0
    let userDefaults = UserDefaults.standard
    
    override func didMove(to view: SKView) {
        
        self.backgroundColor = SKColor.white
        let date = Date()
        monster.size = CGSize(width: monster.size.width/2, height: monster.size.height/2)
        monster.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        monster.zPosition = -1
        monster.name = "monster"
        self.addChild(monster)
        addCarrot()
        addFruit()
        label = UILabel()
        label?.translatesAutoresizingMaskIntoConstraints = false
        label?.textAlignment = .center
        if let countlabel = label {
            self.view?.addSubview(countlabel)
        }
        label?.bottomAnchor.constraint(equalTo: (self.view?.bottomAnchor)!, constant: -50).isActive = true
        label?.centerXAnchor.constraint(equalTo: (self.view?.centerXAnchor)!).isActive = true
        dayDifference(from: userDefaults.double(forKey: "Date"))

        userDefaults.set(date.timeIntervalSince1970, forKey: "Date")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        selectNodeForTouch(touchLocation: touchLocation)
    }
    
    func degToRad(degree: Double) -> CGFloat {
        return CGFloat(Double(degree) / 180.0 * Double.pi)
    }
    
    func selectNodeForTouch(touchLocation: CGPoint) {

        guard let touchedNode = self.atPoint(touchLocation) as? SKSpriteNode else {
            return
        }
    
        if !selectedNode.isEqual(touchedNode) {
            selectedNode.removeAllActions()
            selectedNode.run(SKAction.rotate(toAngle: 0.0, duration: 0.1))
            selectedNode = touchedNode
            if let name = touchedNode.name {
                if nodeNameArray.contains(name) {
                    let sequence = SKAction.sequence([SKAction.rotate(byAngle: degToRad(degree: -6.0), duration: 0.1), SKAction.rotate(byAngle: 0.0, duration: 0.1), SKAction.rotate(byAngle: degToRad(degree: 6.0), duration: 0.1)])
                    selectedNode.run(SKAction.repeatForever(sequence))
                }
            }
        }
    }
    
    func panForTranslation(translation: CGPoint) {
        let position = selectedNode.position
        if let name = selectedNode.name {
            if nodeNameArray.contains(name){
                selectedNode.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
            }
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        let previousPosition = touch.previousLocation(in: self)
        let translation = CGPoint(x: touchLocation.x - previousPosition.x, y: touchLocation.y - previousPosition.y)
        panForTranslation(translation: translation)
        let isPointInFrame = monster.frame.contains(touchLocation)
        
        if isPointInFrame == true {
            monster.texture = SKTexture(imageNamed: "openMonster")
        } else {
            monster.texture = SKTexture(imageNamed: "closeMonster")
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        let isPointInFrame = monster.frame.contains(touchLocation)

        if isPointInFrame == true {
    
            switch self.selectedNode.name {
                case "banana"?:
                    delay(time: 2, closure: {
                       self.addFruit()
                    })
                    selectedNode.removeFromParent()
                    count += 1
                case "carrot"?:
                    delay(time: 2, closure: {
                        self.addCarrot()
                    })
                    selectedNode.removeFromParent()
                    count += 1
                default:
                    break
                }
            
            label?.text = "Today count: \(count) "
            userDefaults.set(count ,forKey: "eaten")

            if count >= 5 {
                label?.text = "YOU HAVE REACHED 5ADAY!"
                label?.sizeToFit()
                //label?.center.x = (self.view?.center.x)!
            }
            
            monster.texture = SKTexture(imageNamed: "closeMonster")
        }
    }
    
    func addCarrot() {
        let carrot = SKSpriteNode(imageNamed: "carrot")
        carrot.size = CGSize(width: carrot.frame.width/3, height: carrot.frame.height/3)
        carrot.position = CGPoint(x: self.frame.maxX - carrot.frame.width/3 - 50, y: monster.frame.maxY + 50)
        carrot.name = "carrot"
        if let name = carrot.name {
            nodeNameArray.append(name)
        }
        self.addChild(carrot)
    }
    
    func addFruit() {
        let banana = SKSpriteNode(imageNamed: "banana")
        banana.size = CGSize(width: banana.frame.width/3, height: banana.frame.height/3)
        banana.position = CGPoint(x: self.frame.minX + banana.frame.width/5 + 50, y: monster.frame.maxY + 50)
        banana.name = "banana"
        if let name = banana.name {
            nodeNameArray.append(name)
        }
        self.addChild(banana)
    }
    
    func delay(time: Double, closure:@escaping ()->()) {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
            closure()
        }
    }
    
    func dayDifference(from interval : TimeInterval)
    {
        let calendar = NSCalendar.current
        let date = Date(timeIntervalSince1970: interval)
        if calendar.isDateInToday(date) {
            currentDay = true
            count = userDefaults.integer(forKey: "eaten")
            if count >= 5 {
                label?.text = "YOU HAVE REACHED 5ADAY!"
                label?.sizeToFit()
                //label?.center.x = (self.view?.center.x)!
            } else {
                label?.text = "Today count: \(count) "
                label?.sizeToFit()
                //label?.center.x = (self.view?.center.x)!
            }
        } else {
            currentDay = false
            print("not Today")
            label?.text = "Today count: \(count) "
            label?.sizeToFit()
        }
    }
}
