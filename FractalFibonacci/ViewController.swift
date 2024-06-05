import UIKit

class ViewController: UIViewController {
    var canvas = Canvas()
    override func viewDidLoad() {
        super.viewDidLoad()
        canvas.frame = view.frame
        view.addSubview(canvas)
        
    }


}

extension UIView {
    func setAnchorPoint(point:CGPoint) {
        let oldPoint = CGPoint(x: self.bounds.width*layer.anchorPoint.x, y: self.bounds.height*layer.anchorPoint.y)
        let newPoint = CGPoint(x: self.bounds.width*point.x, y: self.bounds.height*point.y)
        var position = layer.position
        position.x -= oldPoint.x
        position.x += newPoint.x
        position.y -= oldPoint.y
        position.y += newPoint.y
        layer.position = position
        layer.anchorPoint = point
    }
}

class Canvas:UIView {
    lazy var Fibs:[Int] = Fibonacci(count: 25)
    var scale:CGFloat = 1
    var minScale:CGFloat = 0
    var Time = Timer()
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        for view in self.subviews {
            view.removeFromSuperview()
        }
        minScale = CGFloat(Fibs[Fibs.count - 5]) / CGFloat(Fibs[Fibs.count - 1])
        var arrayView:[UIView] = []
        let colors:[UIColor] = [.red,.brown,.link,.lightGray]
        let view1 = UIView(frame: CGRect(x: self.frame.width/2, y: self.frame.height/2, width: CGFloat(Fibs[0]), height: CGFloat(Fibs[0])))
        self.addSubview(view1)
        arrayView.append(view1)
        for i in 1...Fibs.count - 1 {
            let fib:CGFloat = CGFloat(Fibs[i])*scale
            let lastView = arrayView[arrayView.count - 1]
            let view = UIView(frame: CGRect(x: lastView.frame.width, y: lastView.frame.height, width: fib, height: fib))
            view.backgroundColor = colors[i%4]
            view.layer.borderColor = UIColor.black.cgColor
            view.layer.borderWidth = 2
            view.setAnchorPoint(point: CGPoint(x: 0, y: 0))
            lastView.addSubview(view)
            view.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
            arrayView.append(view)
            let shap = CAShapeLayer()
            let path = UIBezierPath(arcCenter: CGPoint(x: fib, y: 0), radius: fib, startAngle: CGFloat.pi/2, endAngle: CGFloat.pi, clockwise: true)
            shap.path = path.cgPath
            shap.strokeColor = UIColor.black.cgColor
            shap.fillColor = UIColor.clear.cgColor
            view.layer.addSublayer(shap)
        }
        update()
    }
    
    func update() {
        Time.invalidate()
        Time = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateMinScale), userInfo: nil, repeats: true)
    }
    
    @objc func updateMinScale() {
        if scale <= minScale {
            scale = 1
        }
        else {
            scale *= 0.99
        }
        setNeedsDisplay()
    }
    
    func Fibonacci(count:Int) -> [Int] {
        var newCount = count
        var n1 = 0
        var n2 = 1
        var n3 = 1
        var arr:[Int] = [n1, n2, n3]
        while newCount >= 2 {
            n1 = n2
            n2 = n3
            n3 = n1 + n2
            arr.append(n3)
            newCount -= 1
        }
        return arr
    }
}
