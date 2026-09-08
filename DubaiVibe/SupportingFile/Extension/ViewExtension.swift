//
//  ViewExtension.swift
//  Auction
//
//  Created by mac on 10/12/20.
//

import Foundation
import UIKit



var isLeftTop = false
var isLeftBottom = false
var isRightTop = false
var isRightBottom = false


extension UIView {
    
  /*
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
  */
    @IBInspectable
    var leftTop: Bool {
        get {
            return isLeftTop
        }set {
            isLeftTop = newValue
            conrer()
        }
    }
    
    @IBInspectable
    var leftBottom: Bool {
        get {
            return isLeftBottom
        }set {
            isLeftBottom = newValue
            conrer()
        }
    }
    @IBInspectable
    var rightTop: Bool {
        get {
            return isRightTop
        }set {
            isRightTop = newValue
            conrer()
        }
    }
    
    @IBInspectable
    var rightBttom: Bool {
        get {
            return isRightBottom
        }set {
            isRightBottom = newValue
            conrer()
        }
    }
    
   func conrer() {
        var jjj = CACornerMask()
        
        if isLeftTop {
            jjj.insert(.layerMinXMinYCorner)
        }
        if isLeftBottom {
            jjj.insert(.layerMinXMaxYCorner)
            
        }
        if isRightTop {
            
            jjj.insert(.layerMaxXMinYCorner)
            
        }
        if isRightBottom {
            jjj.insert(.layerMaxXMaxYCorner)
        }
        self.layer.cornerRadius = cornerRadius
        self.layer.maskedCorners = jjj
    }
 /*
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue!.cgColor
        }
    }

    @IBInspectable var edgeInsetssss: UIEdgeInsets {
        get {
            return self.edgeInsetssss
        }
        set {
            self.edgeInsetssss = newValue
            //            self.edgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
        }
    }

    @IBInspectable var shadowColor: UIColor? {
        set {
            layer.shadowColor = newValue!.cgColor
        }
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor:color)
            }
            else {
                return nil
            }
        }
    }
    
    /* The opacity of the shadow. Defaults to 0. Specifying a value outside the
     * [0,1] range will give undefined results. Animatable. */
    @IBInspectable var shadowOpacity: Float {
        set {
            layer.shadowOpacity = newValue
        }
        get {
            return layer.shadowOpacity
        }
    }
    
    /* The shadow offset. Defaults to (0, -3). Animatable. */
    @IBInspectable var shadowOffset: CGPoint {
        set {
            layer.shadowOffset = CGSize(width: newValue.x, height: newValue.y)
        }
        get {
            return CGPoint(x: layer.shadowOffset.width, y:layer.shadowOffset.height)
        }
    }
    
    /* The blur radius used to create the shadow. Defaults to 3. Animatable. */
    @IBInspectable var shadowRadius: CGFloat {
        set {
            layer.shadowRadius = newValue
        }
        get {
            return layer.shadowRadius
        }
    }
    
    /** Loads instance from nib with the same name. */
    func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    func transformView(){
        self.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5.0, options: .curveEaseOut, animations: ({
            
            self.transform = CGAffineTransform.identity
        }), completion: nil)
    }
    */
}

extension UIView {
    
   

        func applyShadow(
            color: UIColor = UIColor(hex: "#102A43"),
            opacity: Float = 0.08,
            offset: CGSize = CGSize(width: 0, height: 4),
            radius: CGFloat = 10
        ) {
            layer.masksToBounds = false
            layer.shadowColor = color.cgColor
            layer.shadowOpacity = opacity
            layer.shadowOffset = offset
            layer.shadowRadius = radius
        }

    
    func applyCardShadow() {
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.borderWidth = 0
        layer.shadowOpacity = 0.17
        layer.shadowOffset = .zero
        layer.shadowRadius = 6
    }
    
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
    func addDashedBorder(
        color: UIColor = .lightGray,
        lineWidth: CGFloat = 1,
        dashPattern: [NSNumber] = [6, 3],
        cornerRadius: CGFloat = 0
    ) {
        
        // Remove existing dashed border if any
        layer.sublayers?.removeAll(where: { $0.name == "DashedBorderLayer" })
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.name = "DashedBorderLayer"
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineDashPattern = dashPattern
        shapeLayer.frame = bounds
        
        let path = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: cornerRadius
        )
        
        shapeLayer.path = path.cgPath
        layer.addSublayer(shapeLayer)
    }
    

    
    
    
}


extension UserDefaults {

    
    func setUserId(value: String) {
        set(value, forKey: UserDefaultsKeys.userId.rawValue)
        //synchronize()
    }
    
    func getUserId()-> String {
        return   value(forKey: UserDefaultsKeys.userId.rawValue) as! String  
    }
    
    
    
    
    //MARK: Check Login
    func setLoggedIn(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isLoggedIn.rawValue)
        //synchronize()
    }
    
    func isLoggedIn()-> Bool {
        return bool(forKey: UserDefaultsKeys.isLoggedIn.rawValue)
    }
    //
    func getUserData() -> Data {
        return data(forKey: UserDefaultsKeys.loginData.rawValue) ?? Data()
    }
    //MARK: Save User Data
    func setUserData(value: Data){
        set(value, forKey: UserDefaultsKeys.loginData.rawValue)
        //synchronize()
    }
    func removeAllUserdefault(){
        removeObject(forKey: UserDefaultsKeys.loginData.rawValue)
        removeObject(forKey: UserDefaultsKeys.isLoggedIn.rawValue)
        removeObject(forKey: "user_type")
        
        
    }

}

enum UserDefaultsKeys : String {
    case isLoggedIn
    case loginData
    case userId
}

// sigle tin class
class AppDataHelper {
    static let shard = AppDataHelper()
//    var logins: Details!

}




