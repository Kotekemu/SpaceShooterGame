import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    // Создаем эмиттер частиц starfield для фона звездного поля.
    var starfield: SKEmitterNode!
    // Создаем спрайт player, представляющий космический корабль игрока.
    var player: SKSpriteNode!
    // Создаем метку scoreLabel для отображения счета игрока.
    var scoreLabel: SKLabelNode!
    // Переменная score отслеживает счет игрока и обновляет метку scoreLabel при изменении.
    var score:Int = 0 {
        didSet {
            scoreLabel.text = "Счёт: \(score)"
        }
    }
    // Создаем таймер gameTimer для периодического добавления врагов.
    var gameTimer:Timer!
    // Массив aliens содержит имена спрайтов, используемых для врагов.
    var aliens = ["alien", "alien2", "alien3"]
    // Категории физики alienCategory и bulletCategory используются для обработки столкновений между пришельцами и пулями.
    let alienCategory:UInt32 = 0x1 << 1
    let bulletCategory:UInt32 = 0x1 << 0

    // Создаем менеджер движения motionManager для получения данных об ускорении устройства.
    let motionManager = CMMotionManager()
    // Переменная xAccelerate используется для хранения данных об ускорении по оси x.
    var xAccelerate:CGFloat = 0

    // Функция didMove(to:) вызывается, когда сцена загружается в представление.
    override func didMove(to view: SKView) {
        // Добавляем starfield в сцену.
        starfield = SKEmitterNode(fileNamed: "Starfield")
        starfield.position = CGPoint(x: 0, y: 1472)
        starfield.advanceSimulationTime(10)
        starfield.zPosition = -1
        
        // Добавляем player в сцену.
        player = SKSpriteNode(imageNamed: "shuttle")
        player.position = CGPoint(x: UIScreen.main.bounds.width / 2, y: 40)
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        // Добавляем scoreLabel в сцену.
        scoreLabel = SKLabelNode(text: "Счёт: 0")
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = UIColor.white
        scoreLabel.position = CGPoint(x: 100, y: UIScreen.main.bounds.height - 100)
        scoreLabel.zPosition = 100
        score = 0
        
        // Настраиваем gameTimer для добавления врагов с заданным интервалом.
        var timeInterval = 0.75
        
        if UserDefaults.standard.bool(forKey: "hard") { // Проверяем, включен ли сложный режим.
            timeInterval = 0.3
        }
        
        gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
        
        // Добавляем игровые объекты в сцену.
        self.addChild(starfield)
        self.addChild(player)
        self.addChild(scoreLabel)
        
        // Настраиваем менеджер движения для получения данных об ускорении.
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data: CMAccelerometerData?, error: Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xAccelerate = CGFloat(acceleration.x) * 0.75 + self.xAccelerate * 0.25
            }
        }
    }
    
    override func didSimulatePhysics() {
            // Обновление позиции игрока в зависимости от ускорения
            player.position.x += xAccelerate * 50
            // Проверка выхода игрока за пределы экрана
            if player.position.x < 0 {
                // Если игрок вышел за левый край, переместить его на правый край
                player.position = CGPoint(x: UIScreen.main.bounds.width - player.size.width, y: player.position.y)
            } else if player.position.x > UIScreen.main.bounds.width {
                // Если игрок вышел за правый край, переместить его на левый край
                player.position = CGPoint(x: 20, y: player.position.y)
            }
        }
        
        func didBegin(_ contact: SKPhysicsContact) {
            // Инициализация пули и пришельца
            var alienBody:SKPhysicsBody
            var bulletBody:SKPhysicsBody
            
            // Определение, какое тело является пришельцем, а какое - пулей
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
                bulletBody = contact.bodyA
                alienBody = contact.bodyB
            } else {
                bulletBody = contact.bodyB
                alienBody = contact.bodyA
            }
            // Проверка, столкнулись ли пришелец и пуля
            if (alienBody.categoryBitMask & alienCategory) != 0 && (bulletBody.categoryBitMask & bulletCategory) != 0 {
                // Проверка на то, чтобы игра не вылетала
                guard let bulletNode = bulletBody.node as? SKSpriteNode, let alienNode = alienBody.node as? SKSpriteNode else {
                    return
                }
                // Вызов метода обработки столкновения
                collisionElements(bulletNode: bulletNode, alienNode: alienNode)
            }
        }
        
        func collisionElements(bulletNode:SKSpriteNode, alienNode:SKSpriteNode) {
            // Создание эффекта взрыва
            let explosion = SKEmitterNode(fileNamed: "Vzriv")
            explosion?.position = alienNode.position
            self.addChild(explosion!)
            // Воспроизведение звука взрыва
            self.run(SKAction.playSoundFileNamed("vzriv.mp3", waitForCompletion: false))
            // Удаление пули и пришельца из сцены
            bulletNode.removeFromParent()
            alienNode.removeFromParent()
            // Удаление эффекта взрыва через 2 секунды
            self.run(SKAction.wait(forDuration: 2)) {
                explosion?.removeFromParent()
            }
            // Увеличение счета
            score += 5
        }
        
        @objc func addAlien() {
            // Перемешивание массива пришельцев
            aliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: aliens) as! [String]
            // Создание спрайта пришельца
            let alien = SKSpriteNode(imageNamed: aliens[0])
            // Генерация случайной позиции по горизонтали
            let randomPos = GKRandomDistribution(lowestValue: 20, highestValue: Int(UIScreen.main.bounds.size.width - 20))
            let pos = CGFloat(randomPos.nextInt())
            // Длительность анимации движения пришельца
            let animDuration:TimeInterval = 6
            // Массив действий для пришельца
            var actions = [SKAction]()
            // Количество очков за уничтожение пришельца
            var points = 50
            if UserDefaults.standard.bool(forKey: "hard") {
                points = 100
            }
            
            // Начальная позиция пришельца
            alien.position = CGPoint(x: pos, y: UIScreen.main.bounds.size.height + alien.size.height)
            // Добавление физического тела пришельцу
            alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
            // Настройка свойств физического тела
            alien.physicsBody?.isDynamic = true
            alien.physicsBody?.categoryBitMask = alienCategory
            alien.physicsBody?.contactTestBitMask = bulletCategory
            alien.physicsBody?.collisionBitMask = 0
            
            // Добавление действий в массив
            actions.append(SKAction.move(to: CGPoint(x: pos, y: 0 - alien.size.height), duration: animDuration))
            actions.append(SKAction.removeFromParent())
            actions.append(SKAction.run {
                self.score -= points
            })
            // Выполнение последовательности действий
            alien.run(SKAction.sequence(actions))
                    
            // Добавление пришельца на сцену
            self.addChild(alien)
        }
        
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            // Выстрел пулей
            fireBullet();
        }
        
        func fireBullet() {
            // Воспроизведение звука выстрела
            self.run(SKAction.playSoundFileNamed("vzriv.mp3", waitForCompletion: false))
            // Создание спрайта пули
            let bullet = SKSpriteNode(imageNamed: "torpedo")
            // Длительность анимации движения пули
            let animDuration:TimeInterval = 0.3
            // Массив действий для пули
            var actions = [SKAction]()
            // Начальная позиция пули
            bullet.position = player.position
            bullet.position.y += 5
            // Добавление физического тела пуле
            bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width / 2)
            // Настройка свойств физического тела
            bullet.physicsBody?.isDynamic = true
            bullet.physicsBody?.categoryBitMask = bulletCategory
            bullet.physicsBody?.contactTestBitMask = alienCategory
            bullet.physicsBody?.collisionBitMask = 0
            bullet.physicsBody?.usesPreciseCollisionDetection = true
            // Добавление действий в массив
            actions.append(SKAction.move(to: CGPoint(x: player.position.x, y: UIScreen.main.bounds.size.height + bullet.size.height), duration: animDuration))
            actions.append(SKAction.removeFromParent())
            // Выполнение последовательности действий
            bullet.run(SKAction.sequence(actions))
            // Добавление пули на сцену
            self.addChild(bullet)
        }
    
    override func update(_ currentTime: TimeInterval) {
            // Проверка, стал ли счет отрицательным
            if score < 0 {
                // При отрицательном счете игра приостанавливается
                self.isPaused = true
                
                // Создание надписи "GAME OVER"
                let gameOverLabel = SKLabelNode(text: "GAME OVER")
                // Позиционирование надписи по центру экрана
                gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY)
                gameOverLabel.fontSize = 50
                gameOverLabel.fontColor = UIColor.white
                gameOverLabel.fontName = "AvenirNext-Bold"
                // Установка позиции надписи по оси z (для перекрытия других объектов)
                gameOverLabel.zPosition = 101
                // Добавление надписи на сцену
                addChild(gameOverLabel)
                // Выход из игры через 5 секунд
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    exit(0)
                }
            }
        }
}
