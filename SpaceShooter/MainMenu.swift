import SpriteKit

class MainMenu: SKScene {
    // Объявляем переменные для сцены
    var starfield:SKEmitterNode!
    var newGameBtnNode:SKSpriteNode!
    var levelBtnNode:SKSpriteNode!
    var labelLevelNode:SKLabelNode!
    
    override func didMove(to view: SKView) {
        starfield = self.childNode(withName: "starfield_anim") as? SKEmitterNode
        // Продвигаем симуляцию звездного поля на 10 секунд вперед, чтобы оно выглядело более оживленным
        starfield.advanceSimulationTime(10)
        // Получаем спрайт кнопки новой игры по имени и приводим его к типу SKSpriteNode
        newGameBtnNode = self.childNode(withName: "newGameBtn") as? SKSpriteNode
        // Задаем текстуру кнопки новой игры
        newGameBtnNode.texture = SKTexture(imageNamed: "newGameBtn")
        // Получаем спрайт кнопки уровня по имени и приводим его к типу SKSpriteNode
        levelBtnNode = self.childNode(withName: "levelBtn") as? SKSpriteNode
        // Задаем текстуру кнопки уровня
        levelBtnNode.texture = SKTexture(imageNamed: "levelBtn")
        // Получаем метку кнопки уровня по имени и приводим его к типу SKLabelNode
        labelLevelNode = self.childNode(withName: "labelLevelBtn") as? SKLabelNode
        // Получаем уровень сложности пользователя из UserDefaults
        let userLevel = UserDefaults.standard
        
        // Проверяем, находится ли пользователь в сложном режиме
        if userLevel.bool(forKey: "hard") {
            // Если да, устанавливаем текст метки уровня на "Hard Mode"
            labelLevelNode.text = "Hard Mode"
        } else {
            // Если нет, устанавливаем текст метки уровня на "Easy Mode"
            labelLevelNode.text = "Easy Mode"
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Получаем первое касание
        let touch = touches.first
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            // Если первым элементом массива является кнопка новой игры
            if nodesArray.first?.name == "newGameBtn" {
                // Создаем переход с переворачиванием по вертикали
                let transition = SKTransition.flipVertical(withDuration: 0.5)
                // Создаем сцену игры с размером экрана
                let gameScene = GameScene(size: UIScreen.main.bounds.size)
                // Переключаемся на сцену игры с переходом
                self.view?.presentScene(gameScene, transition: transition)
            } else if nodesArray.first?.name == "levelBtn" {
                // Вызываем метод смены уровня
                changeLevel()
            }
        }
    }
    // Метод смены уровня
    func changeLevel() {
        // Получаем уровень сложности пользователя из UserDefaults
        let userLevel = UserDefaults.standard
        // Если текст метки уровня равен "Easy Mode"
        if labelLevelNode.text == "Easy Mode" {
            // Устанавливаем текст метки уровня на "Hard Mode"
            labelLevelNode.text = "Hard Mode"
            // Устанавливаем сложный режим игры для пользователя
            userLevel.set(true, forKey: "hard")
        } else {
            // Устанавливаем текст метки уровня на "Easy Mode"
            labelLevelNode.text = "Easy Mode"
            // Устанавливаем простой режим игры для пользователя
            userLevel.set(false, forKey: "hard")
        }
        // Синхронизируем UserDefaults
        userLevel.synchronize()
    }
}
