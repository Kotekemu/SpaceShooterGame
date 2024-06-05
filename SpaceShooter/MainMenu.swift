import SpriteKit

class MainMenu: SKScene {
    var starfield:SKEmitterNode!
    var newGameBtnNode:SKSpriteNode!
    var levelBtnNode:SKSpriteNode!
    var labelLevelNode:SKLabelNode!
    
    override func didMove(to view: SKView) {
        starfield = self.childNode(withName: "starfield_anim") as? SKEmitterNode
        starfield.advanceSimulationTime(10)
        
        newGameBtnNode = self.childNode(withName: "newGameBtn") as? SKSpriteNode
        newGameBtnNode.texture = SKTexture(imageNamed: "newGameBtn")
        levelBtnNode = self.childNode(withName: "levelBtn") as? SKSpriteNode
        levelBtnNode.texture = SKTexture(imageNamed: "levelBtn")
        labelLevelNode = self.childNode(withName: "labelLevelBtn") as? SKLabelNode
        let userLevel = UserDefaults.standard
        
        if userLevel.bool(forKey: "hard") {
            labelLevelNode.text = "Hard Mode"
        } else {
            labelLevelNode.text = "Easy Mode"
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            if nodesArray.first?.name == "newGameBtn" {
                let transition = SKTransition.flipVertical(withDuration: 0.5)
                let gameScene = GameScene(size: UIScreen.main.bounds.size)
                self.view?.presentScene(gameScene, transition: transition)
            } else if nodesArray.first?.name == "levelBtn" {
                changeLevel()
            }
        }
    }
    func changeLevel() {
        let userLevel = UserDefaults.standard
        if labelLevelNode.text == "Easy Mode" {
            labelLevelNode.text = "Hard Mode"
            userLevel.set(true, forKey: "hard")
        } else {
            labelLevelNode.text = "Easy Mode"
            userLevel.set(false, forKey: "hard")
        }
        userLevel.synchronize()
    }
}
